# 🚀 DevOps Project: CodePipeline Using Terraform

## 📄 Project Overview

This project demonstrates a fully automated **CI/CD pipeline** on AWS using **Terraform**, **CodePipeline**, **CodeBuild**, **CodeDeploy**, and **GitHub Actions**. The infrastructure is provisioned as code and validated using **Terratest**.

---

## 📌 Key Features

- ✅ Infrastructure as Code (IaC) using **Terraform**
- ✅ Continuous Integration & Deployment with **AWS CodePipeline**
- ✅ Build automation using **AWS CodeBuild**
- ✅ Deployment automation using **AWS CodeDeploy** to EC2
- ✅ GitHub Actions integration via **OpenID Connect (OIDC)**
- ✅ Infrastructure testing with **Terratest**
- ✅ IAM roles and least-privilege policies
- ✅ Centralized artifact storage using **S3**

---

## 🛠 Technologies Used

- AWS (EC2, S3, CodePipeline, CodeBuild, CodeDeploy, IAM)
- Terraform
- GitHub Actions
- Terratest (Golang)

---

## 📁 Terraform Module Structure

.
├── main.tf # Core AWS resource definitions
├── iam.tf # IAM roles and policies
├── variables.tf # Input variables
├── outputs.tf # Output values (e.g. EC2 IP, pipeline name)
├── terraform.tfvars # (Optional) Variable values
├── .github/
│ └── workflows/
│ └── trigger-pipeline.yml # GitHub Actions workflow
└── test/
└── pipeline_test.go # Terratest validation

markdown
Copy
Edit

---

## ✅ Pipeline Architecture

The CI/CD pipeline consists of:

1. **Source**: Connects to a GitHub repo using CodeStar connections.
2. **Build**: AWS CodeBuild compiles and packages the app.
3. **Deploy**: AWS CodeDeploy deploys the app to an EC2 instance.
4. **Trigger**: GitHub Actions triggers the pipeline on every push to `main`.

---

## ⚙️ Setup Instructions

### 📦 Prerequisites

- ✅ [Terraform](https://www.terraform.io/downloads)
- ✅ [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- ✅ [Go](https://go.dev/doc/install) (for running Terratest)
- ✅ AWS Account with admin access
- ✅ GitHub account

### 🔧 Deployment Steps

1. **Create a GitHub-AWS Connection**  
   Go to: https://console.aws.amazon.com/codesuite/settings/connections  
   - Click “Create connection” → GitHub → Authorize
   - Copy the connection ARN for Terraform

2. **Clone the Repository**

```bash
git clone https://github.com/your-username/devops-codepipeline-terraform.git
cd devops-codepipeline-terraform
Deploy Infrastructure

bash
Copy
Edit
terraform init
terraform plan
terraform apply
📦 S3 Artifact Store
Terraform provisions an S3 bucket to store:

Source ZIPs from GitHub

Build outputs from CodeBuild

This enables seamless stage transitions in the pipeline.

☁️ EC2 Instance & CodeDeploy
The EC2 instance is configured with:

CodeDeploy agent installation

Apache HTTPD server for simple web hosting

Auto-start scripts for deployment readiness

⚙️ GitHub Actions (OIDC Auth)
Due to webhook limitations, GitHub Actions with OIDC is used:

Configured an IAM Identity Provider

Created a trusted IAM role for GitHub

Authenticates via .github/workflows/trigger-pipeline.yml on every push

✅ Terratest Validation
test/pipeline_test.go ensures the infrastructure and pipeline are working:

Test Workflow:
Deploy resources (terraform apply)

Trigger the pipeline via AWS SDK

Monitor stages for success

Send HTTP request to deployed EC2 app

Validate HTTP 200 OK

Destroy resources

Run Test:
bash
Copy
Edit
go test -v -timeout 30m ./test
🧱 Challenges Overcome
❌ Webhook Error
✅ Solved via GitHub Actions OIDC Authentication

❌ Build Failure due to missing dist/
✅ Resolved with proper build output configuration

❌ IAM Permission Tuning
✅ Fine-tuned IAM policies for secure access

📚 Conclusion
This project delivers a secure, scalable, and automated CI/CD pipeline using modern DevOps practices:

🌐 All resources provisioned using Terraform

🔐 Secure access via IAM & OIDC

⚙️ Fully automated build and deploy workflow

🧪 Infrastructure tested end-to-end with Terratest

👤 Author
Debashish Parida
SIC: 23BCSD66
Silicon Institute of Technology, Bhubaneswar
Under the Guidance of: Sumit Sah

📅 Academic Year: 2024 – 2025

📬 Contact
📧 LinkedIn

📷 Instagram

📘 Facebook
