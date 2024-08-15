variable "vpc_id" {
  description = "The ID of the requester's VPC"
}

variable "peer_vpc_id" {
  description = "The ID of the peer VPC"
}

variable "peer_owner_id" {
  description = "The AWS Account ID of the peer VPC owner"
}

variable "peer_region" {
  description = "The region of the peer VPC"
}

variable "acceptor_cidr_block" {
  description = "The CIDR block of the acceptor VPC"
}

variable "route_table_id" {
  description = "The route table ID for the requester's VPC"
}

variable "requestor_cidr_block" {
  description = "The CIDR block of the requestor VPC"
}

variable "acceptor_intra_subnet_name" {
  description = "The name of the intra subnet in the acceptor VPC"
}
