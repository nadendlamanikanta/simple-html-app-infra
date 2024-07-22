output "web_server_public_ip" {
  description = "The public IP of the web server"
  value       = aws_instance.web_server.public_ip
}
