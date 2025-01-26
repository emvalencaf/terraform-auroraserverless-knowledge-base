variable "cluster_name" {
  description = "The name of the Aurora Serverless database cluster"
  type        = string
}

variable "database_name" {
  description = "The name of the database to be created in the Aurora cluster"
  type        = string
}

variable "min_capacity" {
  description = "The minimum capacity for the Aurora Serverless cluster"
  type        = number
  default = 0
}

variable "max_capacity" {
  description = "The maximum capacity for the Aurora Serverless cluster"
  type        = number
  default = 2
}

variable "secret_manager_name" {
  description = "The name of the Secrets Manager secret storing database credentials"
  type        = string
}