# ------------------------------------------IAM Role for CodePipeline-------------------------------------------
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project_name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "codepipeline.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.project_name}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:GetObjectVersion", "s3:GetBucketVersioning", "s3:PutObject"],
        Resource = [aws_s3_bucket.codepipeline_artifacts.arn, "${aws_s3_bucket.codepipeline_artifacts.arn}/*"]
      },
      {
        Effect   = "Allow",
        Action   = ["codebuild:StartBuild", "codebuild:BatchGetBuilds"],
        Resource = aws_codebuild_project.build_project.arn
      },
      {
        Effect   = "Allow",
        Action   = ["codedeploy:CreateDeployment", "codedeploy:GetDeployment", "codedeploy:GetDeploymentConfig"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "codestar-connections:UseConnection",
        Resource = data.aws_codestarconnections_connection.github.arn
      }
    ]
  })
}

# ------------------------------------------------IAM Role for CodeBuild--------------------------------------------------------
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project_name}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject", "s3:GetObjectVersion", "s3:GetBucketAcl", "s3:GetBucketLocation"],
        Resource = [
          aws_s3_bucket.codepipeline_artifacts.arn,
          "${aws_s3_bucket.codepipeline_artifacts.arn}/*"   # <-- add this line
        ]
      }
    ]
  })
}

# -----------------------------------------------------IAM Role for CodeDeploy------------------------------------------------
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.project_name}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "codedeploy.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# ---------------------------------------- IAM Policy for CodeDeploy Role (permissions to EC2, ASG, Tags, etc.)------------------------------
resource "aws_iam_role_policy" "codedeploy_permissions" {
  name = "codedeploy-permissions"
  role = aws_iam_role.codedeploy_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "autoscaling:Describe*",
          "tag:Get*",
          "codedeploy:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codedeploy_register" {
  name = "codedeploy-access-policy"
  role = aws_iam_role.codepipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetApplicationRevision"
        ],
        Resource = "arn:aws:codedeploy:us-east-1:194644528937:application:${var.project_name}-app"
      }
    ]
  })
}


# ----------------------------------------------------------IAM Role for EC2 Instance---------------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole",
    }]
  })
}

resource "aws_iam_role_policy" "ec2_codedeploy_inline" {
  name = "ec2-codedeploy-inline-policy"
  role = aws_iam_role.ec2_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codedeploy:*",
          "s3:Get*",
          "s3:List*",
          "cloudwatch:*",
          "logs:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}