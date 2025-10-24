variable "lambda_install_requirements" {
  description = "Whether to install the requirements.txt dependencies for the lambda function"
  type        = bool
  default     = true
}

variable "lambda_requirements_file_name" {
  description = "The name of the requirements file for the lambda function"
  type        = string
  default     = "requirements.txt"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}


variable "lambda_memory_size" {
  description = "Amount of memory in MB your Lambda function is given"
  type        = number
  default     = 128
}

variable "lambda_runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
  default     = "python3.11"
}


variable "lambda_code_path" {
  description = "Path to the Lambda function code"
  type        = string
}

variable "lambda_handler" {
  description = "The function entrypoint in your code (eg: file_name.function_name)"
  type        = string

}

variable "trigger_lambda_permissions" {
  type = map(object({
    source_arn = string
    principal  = string
  }))
  description = "A map of triggers to create permissions for the Lambda function"
  default     = {}
}

variable "lambda_environment_variables" {
  description = "A map of environment variables to set for the Lambda function"
  type        = map(string)
  default     = {}

}


variable "lambda_additional_policies_arns" {
  description = "A list of additional IAM policy ARNs to attach to the Lambda execution role"
  type        = map(string)
  default     = {}
}

variable "lambda_log_retention_in_days" {
  description = "Number of days to retain logs in CloudWatch Logs for the Lambda function"
  type        = number
  default     = 30
}
