# Output for the Private and Public IP addresses of the root instance
output "root_instance_private_ip" {
  value = aws_instance.root_instance.private_ip
  description = "The private IP address of the root instance."
}

output "root_instance_public_ip" {
  value = aws_instance.root_instance.public_ip
  description = "The public IP address of the root instance."
}

# Output for the Private and Public IP addresses of the peer instance
output "peer_instance_private_ip" {
  value = aws_instance.peer_instance.private_ip
  description = "The private IP address of the peer instance."
}

output "peer_instance_public_ip" {
  value = aws_instance.peer_instance.public_ip
  description = "The public IP address of the peer instance."
}
