output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "EC2 Instance Public IP"
  value       = aws_instance.app.public_ip
}

output "health_check_url" {
  description = "${var.app_name} Health Endpoint"
  value       = "http://${aws_instance.app.public_ip}:${var.app_port}${var.health_check_path}"
}

output "buckets_api_url" {
  description = "${var.app_name} Buckets API Endpoint"
  value       = "http://${aws_instance.app.public_ip}:${var.app_port}/api/buckets"
}

output "ecr_image_uri" {
  description = "ECR image URI used"
  value       = local.image_uri
}

output "language" {
  description = "Application language"
  value       = var.language
}
