# VPC Peering Example for Multi-Account Setup

This project demonstrates how to set up VPC peering between two AWS accounts using Terraform. The VPC peering connection allows instances in either VPC to communicate with each other as if they are within the same network. This example is designed to help you understand the process of configuring VPC peering in a multi-account AWS environment.


## Getting Started

### terraform.tfvars
Create a terraform.tfvars file to provide the necessary variable values:

### Initialize Terraform:
Run the following command to initialize the Terraform project and download the necessary providers.
```bash
terraform init
```
### Apply the Terraform Configuration:
To create the resources, run:
```bash
terraform apply
```
Alternatively, you can use terraform plan to preview the changes before applying:
```bash
terraform plan
```