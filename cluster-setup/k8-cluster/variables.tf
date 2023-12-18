variable "public_key" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "security_group_cidr" {
  description = "CIDR block for the security group allowing all TCP from this CIDR"
  type        = string
}
