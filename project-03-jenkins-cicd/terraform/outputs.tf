output "jenkins_public_ip" {
  description = "Public IP of Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "Jenkins UI URL"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "jenkins_initial_password_command" {
  description = "Command to get initial admin password"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.jenkins.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}