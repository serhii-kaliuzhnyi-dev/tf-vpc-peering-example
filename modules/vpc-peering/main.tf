terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [aws.root, aws.peer]
    }
  }
}

# Acceptor route table
data "aws_route_table" "acceptor_rtb" {
  provider = aws.peer
  vpc_id   = var.peer_vpc_id
  filter {
    name   = "tag:Name"
    values = ["trn-public"]
  }
}

# Requester's side of the connection
resource "aws_vpc_peering_connection" "requester_connection" {
  provider     = aws.root
  vpc_id       = var.vpc_id
  peer_vpc_id  = var.peer_vpc_id
  peer_owner_id = var.peer_owner_id
  peer_region  = var.peer_region
  auto_accept  = false
  tags = {
    Side = "Requester"
  }
}

# Accepter's side of the connection
resource "aws_vpc_peering_connection_accepter" "accepter_connection" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.requester_connection.id
  auto_accept               = true
  tags = {
    Side = "Accepter"
  }
}

# Requestor route
resource "aws_route" "requestor_route" {
  provider                  = aws.root
  route_table_id            = var.route_table_id
  destination_cidr_block    = var.acceptor_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester_connection.id
}

# Accepter route
resource "aws_route" "accepter_route" {
  provider                  = aws.peer
  route_table_id            = data.aws_route_table.acceptor_rtb.route_table_id
  destination_cidr_block    = var.requestor_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.requester_connection.id
}
