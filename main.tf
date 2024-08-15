# Get the caller identity for the peer account
data "aws_caller_identity" "peer" {
  provider = aws.peer
}

# Create the root VPC
module "root_vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 5.12.1"
  name                 = var.vpc_name
  cidr                 = var.cidrs["root"]
  azs                  = var.availability_zones
  public_subnets       = var.public_subnets["root"]
  enable_dns_support   = true
  enable_dns_hostnames = true
  providers = {
    aws = aws.root
  }
  tags = {
    Terraform   = "true"
    Environment = "root"
  }
}

module "peer_vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = var.vpc_name
  cidr                 = var.cidrs["peer"]
  azs                  = var.availability_zones
  public_subnet_names = [var.acceptor_intra_subnet_names["peer"]]
  public_subnets       = var.public_subnets["peer"]
  enable_dns_support   = true
  enable_dns_hostnames = true
  providers = {
    aws = aws.peer
  }
  tags = {
    Terraform   = "true"
    Environment = "peer"
  }
}

# VPC Peering between root VPC (using my_tf profile) and peer VPC (using sigma_tf profile)
module "vpc_peering" {
  source                     = "./modules/vpc-peering"
  peer_region                = var.region
  vpc_id                     = module.root_vpc.vpc_id
  peer_vpc_id                = module.peer_vpc.vpc_id
  peer_owner_id              = data.aws_caller_identity.peer.account_id
  acceptor_cidr_block        = var.cidrs["peer"]
  requestor_cidr_block       = var.cidrs["root"]
  route_table_id             = module.root_vpc.public_route_table_ids[0]
  acceptor_intra_subnet_name = var.acceptor_intra_subnet_names["peer"]
  providers = {
    aws.root = aws.root
    aws.peer = aws.peer
  }
  depends_on = [module.root_vpc, module.peer_vpc]
}

# Generate an SSH key pair
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a file in the root folder
resource "local_file" "private_key" {
  filename = "${path.module}/id_rsa"
  content  = tls_private_key.example.private_key_pem
  file_permission = "0600"
}

# Create the SSH key pair in the root account
resource "aws_key_pair" "deployer_root" {
  provider   = aws.root
  key_name   = "deployer-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Create the SSH key pair in the peer account using the same public key
resource "aws_key_pair" "deployer_peer" {
  provider   = aws.peer
  key_name   = "deployer-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Security Group for the EC2 instance in the root VPC
resource "aws_security_group" "root_instance_sg" {
  provider    = aws.root
  vpc_id      = module.root_vpc.vpc_id
  name        = "root-instance-sg"
  description = "Allow SSH and ICMP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "root-instance-sg"
  }

  depends_on = [ module.root_vpc ]
}

# Security Group for the EC2 instance in the peer VPC
resource "aws_security_group" "peer_instance_sg" {
  provider    = aws.peer
  vpc_id      = module.peer_vpc.vpc_id
  name        = "peer-instance-sg"
  description = "Allow SSH and ICMP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "peer-instance-sg"
  }

  depends_on = [ module.peer_vpc ]
}

# EC2 instance in the root VPC
resource "aws_instance" "root_instance" {
  provider                = aws.root
  ami                     = "ami-0ac67c1f8689447a6"
  instance_type           = "t2.micro"
  subnet_id               = module.root_vpc.public_subnets[0]
  vpc_security_group_ids  = [aws_security_group.root_instance_sg.id]
  key_name                = aws_key_pair.deployer_root.key_name
  associate_public_ip_address = true

  tags = {
    Name = "root-instance"
  }

  depends_on = [aws_security_group.root_instance_sg]
}

# EC2 instance in the peer VPC
resource "aws_instance" "peer_instance" {
  provider                = aws.peer
  ami                     = "ami-0ac67c1f8689447a6"
  instance_type           = "t2.micro"
  subnet_id               = module.peer_vpc.public_subnets[0]
  vpc_security_group_ids  = [aws_security_group.peer_instance_sg.id]
  key_name                = aws_key_pair.deployer_peer.key_name
  associate_public_ip_address = true

  tags = {
    Name = "peer-instance"
  }

  depends_on = [aws_security_group.peer_instance_sg]
}
