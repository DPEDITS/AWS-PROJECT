<div align="center">

# 🚀 Automated CI/CD Pipeline for a Web Application using Terraform & AWS 🚀

</div>

> This project provisions a complete, automated CI/CD pipeline on AWS using Terraform. The pipeline automatically builds, tests, and deploys a sample web application from a GitHub repository to an EC2 instance. The entire infrastructure is defined as code, making it reproducible, version-controlled, and easy to manage.

---

## 📋 Table of Contents

-   [Architecture](#-architecture)
-   [Features](#-features)
-   [Prerequisites](#-prerequisites)
-   [Setup and Deployment](#-setup-and-deployment)
-   [Triggering the Pipeline](#-triggering-the-pipeline-github-actions)
-   [Automated Testing with Terratest](#-automated-testing-with-terratest)
-   [Destroying the Infrastructure](#-destroying-the-infrastructure)

---

## 🏗️ Architecture

The CI/CD pipeline follows a standard, event-driven workflow:

```
1. Developer Push (git push)
       │
       ▼
2. GitHub Actions (Detects push)
       │
       ▼
3. AWS CodePipeline (Manually started by GitHub Actions)
       │
       ├─ A. Source Stage (Pulls from GitHub) ───> S3 Artifact Store
       │
       ├─ B. Build Stage (AWS CodeBuild) ────────> S3 Artifact Store
       │
       └─ C. Deploy Stage (AWS CodeDeploy) ───────> EC2 Instance
```

---

## ✨ Features

-   **Infrastructure as Code:** All AWS resources are managed declaratively with Terraform.
-   **Automated CI/CD:** A fully configured pipeline using AWS CodePipeline, CodeBuild, and CodeDeploy.
-   **GitHub Integration:** Uses a GitHub repository as the source for application code.
-   **Event-Driven Trigger:** A GitHub Actions workflow automatically starts the pipeline on every push to the `main` branch.
-   **EC2 Deployment:** Deploys the application to a live Amazon Linux 2 EC2 instance.
-   **Automated Testing:** Includes an end-to-end infrastructure test suite written in Go using Terratest.

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed and configured:

1.  **Terraform:** [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2.  **AWS CLI:** [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) and [Configure Credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).
3.  **Go:** [Install Go](https://golang.org/doc/install) (required for running Terratest).
4.  **GitHub Account:** A personal GitHub account.
5.  **AWS Account:** An active AWS account with appropriate permissions to create resources.

---

## ⚙️ Setup and Deployment

### 1. Configure GitHub Connection

> A manual, one-time setup is required to connect AWS to your GitHub account.

-   Navigate to **AWS Developer Tools > Settings > Connections** in the AWS Console.
-   Click **Create connection**, select **GitHub**, and follow the prompts to authorize the AWS Connector app.
-   Once the connection is "Available", **copy its ARN**.

### 2. Configure Terraform Variables

-   Clone this repository to your local machine.
-   Create a file named `terraform.tfvars` in the `terraform/` directory.
-   Add the following variables to the file, replacing the placeholder values:

```hcl
# terraform/terraform.tfvars

project_name          = "my-web-app"
aws_region            = "us-east-1"
github_owner          = "your-github-username"
github_repo           = "your-repo-name"
github_branch         = "main"
codestar_connection_arn = "arn:aws:codestar-connections:..." # Paste the ARN from Step 1
```

### 3. Deploy the Infrastructure

-   Navigate to the `terraform/` directory in your terminal.
-   Initialize Terraform:
    ```bash
    terraform init
    ```
-   Apply the configuration to create the AWS resources:
    ```bash
    terraform apply
    ```
-   Review the plan and type `yes` when prompted.

---

## 🚀 Triggering the Pipeline (GitHub Actions)

> Due to a potential issue with automatic webhook creation, this project uses a GitHub Actions workflow to manually trigger the pipeline.

### 1. Setup IAM Role for GitHub Actions

-   Follow the [AWS guide to configure an OIDC provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html) for GitHub in your AWS account's IAM settings.
-   Create a new IAM Role that trusts this GitHub provider.
-   Attach a custom inline policy to this role that allows it to start your specific pipeline:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "codepipeline:StartPipelineExecution",
            "Resource": "arn:aws:codepipeline:us-east-1:ACCOUNT_ID:my-web-app-pipeline"
        }
    ]
}
```
>*(Replace `ACCOUNT_ID` and the pipeline name accordingly)*

### 2. Create the Workflow File

-   In your GitHub repository, create a file at `.github/workflows/trigger-pipeline.yml`.
-   Paste the following code, replacing the `role-to-assume` with the ARN of the IAM role you just created.

```yaml
# .github/workflows/trigger-pipeline.yml

name: Manually Trigger AWS CodePipeline

on:
  push:
    branches:
      - main

permissions:
  id-token: write
  contents: read

jobs:
  start-codepipeline:
    runs-on: ubuntu-latest
    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::ACCOUNT_ID:role/YourGitHubActionsRole # <-- CHANGE THIS
          aws-region: us-east-1

      - name: Start AWS CodePipeline Execution
        run: |
          aws codepipeline start-pipeline-execution --name my-web-app-pipeline # <-- CHANGE THIS if needed
```

Now, any `git push` to the `main` branch will automatically trigger your pipeline.

---

## 🧪 Automated Testing with Terratest

This project includes an end-to-end test to validate the entire deployment.

1.  **Navigate to the test directory:**
    ```bash
    cd ../test
    ```
2.  **Install dependencies:**
    ```bash
    go mod tidy
    ```
3.  **Run the test:**
    > *This command will deploy a fresh copy of the infrastructure, run tests, and automatically destroy it afterward. This can take 20-30 minutes.*
    ```bash
    go test -v -timeout 30m
    ```

The test will pass if the EC2 instance is reachable and returns a `200 OK` status code after the pipeline successfully deploys the application.

---

## 💣 Destroying the Infrastructure

> To tear down all resources created by this project, navigate to the `terraform/` directory and run:

```bash
terraform destroy
