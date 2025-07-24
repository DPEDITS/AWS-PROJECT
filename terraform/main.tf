terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.39.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

# --------------------------------------------S3 Bucket for storing pipeline artifacts------------------------------------------------
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket        = "${var.project_name}-artifacts-${random_id.id.hex}"
  force_destroy = true # Use with caution in production
}

resource "aws_s3_bucket_versioning" "codepipeline_artifacts_versioning" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "random_id" "id" {
  byte_length = 8
}

# ----------------------------------------------------------------CodeBuild Project--------------------------------------------------------------
resource "aws_codebuild_project" "build_project" {
  name          = "${var.project_name}-build"
  description   = "Build project for the ${var.project_name} pipeline"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "5" # in minutes

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOT
      version: 0.2
      phases:
        build:
          commands:
            - echo "Preparing artifacts..."
      artifacts:
        # These paths are relative to the root of your repository
        files:
          - appspec.yml
          - 'app/**/*'
    EOT
  }
}

# --------------------------------------------------------CodeDeploy Application and Deployment Group------------------------------------
resource "aws_codedeploy_app" "deploy_app" {
  compute_platform = "Server"
  name             = "${var.project_name}-app"
}

resource "aws_codedeploy_deployment_group" "deploy_group" {
  app_name              = aws_codedeploy_app.deploy_app.name
  deployment_group_name = "${var.project_name}-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "${var.project_name}-instance"
  }

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
}

# ---------------------------------------------------------------CodePipeline---------------------------------------------------
resource "aws_codepipeline" "pipeline" {
  name          = "${var.project_name}-pipeline"
  role_arn      = aws_iam_role.codepipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch

      }
      run_order = 1
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["BuildArtifact"]

      configuration = {
        ApplicationName     = aws_codedeploy_app.deploy_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.deploy_group.deployment_group_name
      }
    }
  }
}



#-----------------------------------------------------github connection------------------------------------------------------
data "aws_codestarconnections_connection" "github" {
  arn = "arn:aws:codeconnections:eu-north-1:194644528937:connection/929f7894-82d4-488e-8c5d-5fb1eda94a01"
}


# -------------------------------------------------- Target EC2 Instance ---------------------------------------------------

# Find latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ---------------------------------------------------------Security Group for EC2-----------------------------------------------------
resource "aws_security_group" "instance_sg" {
  name = "${var.project_name}-instance-sg"
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # You can restrict this to your IP for better security
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#---------------------------------------------------------------EC2 Instance to deploy to-----------------------------------------
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = "tftest"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y ruby wget
              yum install -y httpd
              cd /home/ec2-user
              wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto
              systemctl start codedeploy-agent
              systemctl enable codedeploy-agent
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "${var.project_name}-instance"
  }
}