variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = "vpc-ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ECS  tasks"
  default     = ["subnet-0a9a58f8", "subnet-05059e6c", "subnet-01904970", "subnet-0d4ec216"]
}
