variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where resources will be deployed"
  type        = list(string)
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "azure_devops_agent_pool" {
  description = "The name of the Azure DevOps agent pool"
  type        = string
}
