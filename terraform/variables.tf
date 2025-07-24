variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A unique name for the project."
  type        = string
  default     = "webapp"
}

variable "github_owner" {
  description = "Your GitHub username or organization name."
  type        = string
}

variable "github_repo" {
  description = "The name of the GitHub repository."
  type        = string
}

variable "github_branch" {
  description = "The branch to trigger the pipeline from."
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub Personal Access Token (PAT) with 'repo' and 'admin:repo_hook' scopes."
  type        = string
  sensitive   = true
}

variable "codestar_connection_arn" {
  description = "The ARN of the existing AWS CodeStar Connection."
  type        = string
}