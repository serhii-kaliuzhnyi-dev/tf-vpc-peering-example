variable "vpc_name" {
  description = "Name of the VPC"
}

variable "region" {
  description = "AWS Region for VPC"
  default     = "eu-central-1"
}

variable "cidrs" {
  type = map(string)
  default = {
    root = "10.50.0.0/16"
    peer = "10.20.0.0/16"  # Example peer CIDR block
  }
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-central-1a"]
}

variable "public_subnets" {
  type = map(list(string))
  default = {
    root = ["10.50.0.0/24"]
    peer = ["10.20.0.0/24"]
  }
}

variable "acceptor_intra_subnet_names" {
  type = map(string)
  default = {
    peer = "peer-subnet"
  }
}
