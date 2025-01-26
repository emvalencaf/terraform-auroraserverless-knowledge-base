variable "role_name" {
  description = "Nome da role IAM a ser criada"
  type        = string
}

variable "assume_role_services" {
  description = "Serviços que poderão assumir a role (exemplo: ec2.amazonaws.com)"
  type        = list(string)
}

variable "policy_name" {
  description = "Nome da política IAM"
  type        = string
}

variable "policy_description" {
  description = "Descrição da política IAM"
  type        = string
}

variable "policy_statements" {
  description = "Declarações da política em formato JSON"
  type        = string
}
