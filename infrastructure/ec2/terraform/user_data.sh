#!/bin/bash
set -e

# Update and install dependencies
yum update -y
yum install -y docker

# Start Docker service
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Authenticate with ECR
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin $(echo ${image_uri} | cut -d'/' -f1)

# Pull Docker image
docker pull ${image_uri}

# Run container
docker run -d --name ${app_name} \
  -p ${app_port}:${app_port} \
  -e PORT=${app_port} \
  -e SERVICE_NAME=${app_name} \
  -e AWS_REGION=${aws_region} \
  ${image_uri}

# Wait for application to start
sleep 10

# Start traffic generator inside container
docker exec -d ${app_name} bash /app/generate-traffic.sh

echo "Application deployed and traffic generation started"
