variable "node_instance_count" {
  type    = number
  default = 1
}

variable "nginx_instance_count" {
  type    = number
  default = 1
}

variable "instance_type" {
  type        = string
  description = "Instance Type"
  default     = "t2.micro"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
  default     = "vpc-id"
}

variable "ami" {
  type        = string
  description = "AMI ID"
  default     = "ami-0e86e20dae9224db8"
}

variable "key_name" {
  type        = string
  description = "My Key Pair"
  default     = "MasterKey"
}

variable "subnet_id" {
  type        = string
  description = "My Subnet ID"
  default     = "subnet-0a94a58f8"
}

variable "subnet_ids" {
  type = map(string)
  default = {
    "subnet_a" = "subnet-0a94a58f8"
    "subnet_b" = "subnet-05059e6c"
    "subnet_c" = "subnet-01df4970"
    "subnet_e" = "subnet-0d4e5216"

  }
}
