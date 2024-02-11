output "lb_endpoint" {
  value = "http://${aws_lb.sonarqube.dns_name}"
}

output "sonar_application_endpoint" {
  value = "http://${aws_lb.sonarqube.dns_name}"
}

output "asg_name" {
  value = aws_autoscaling_group.sonarqube.name
}
