variable aws_region {
  type        = string
  description = "AWS Region to deploy the infrastructure into."
}

variable env {
  type        = string
  description = "AWS Environment in which to deploy the infrastructure."
}

variable rds_password {
  type        = string
  description = "Password for RDS instance."
}