variable "environment_vars" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {
    VAR_1 = "value1"
    VAR_2 = "value2"
  }
}

variable "file_name" {
  description = "The name of the Lambda function deployment package file"
  type        = string
}

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the IAM role that the Lambda function assumes"
  type        = string
}

variable "timeout" {
  description = "The amount of time (in seconds) that Lambda allows a function to run before stopping it"
  type        = number
  default = 100
}

variable "memory_size" {
  description = "The amount of memory (in MB) allocated to the Lambda function"
  type        = number
  default = 128
}

