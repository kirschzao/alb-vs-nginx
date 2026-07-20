variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Name prefix for all resources"
  type        = string
  default     = "alb-vs-nginx"
}

variable "app_image" {
  description = "Container image for the sample app. The default is a NON-WORKING placeholder — build alb-vs-nginx/app, push it to your ECR, and override this before apply."
  type        = string
  default     = "111111111111.dkr.ecr.us-east-1.amazonaws.com/sample-app:latest"
}
