output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.nginx_server.id
}

output "ami_id" {
  description = "AMI used (resolved by the data source)"
  value       = data.aws_ami.al2023.id
}

output "public_ip" {
  description = "Instance public IP"
  value       = aws_instance.nginx_server.public_ip
}

output "nginx_url" {
  description = "URL to test nginx (wait 1-2 minutes after apply)"
  value       = "http://${aws_instance.nginx_server.public_ip}"
}

output "ssh_command" {
  description = "Command to connect via SSH"
  value       = "ssh -i nginx-server.key ec2-user@${aws_instance.nginx_server.public_ip}"
}
