variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = "vpc-0000000000000"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS  tasks"
  default     = ["subnet-0000000000000", "subnet-0000000000000", "subnet-0000000000000", "subnet-0000000000000"]
}
