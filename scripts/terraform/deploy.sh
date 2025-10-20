#!/bin/bash

set -e

# Usage: ./scripts/terraform/deploy.sh <app-name>
# Example: ./scripts/terraform/deploy.sh python-flask

if [ $# -eq 0 ]; then
    echo "Usage: $0 <app-name>"
    echo ""
    echo "Available apps:"
    ls -1 infrastructure/ec2/terraform/config/*.tfvars 2>/dev/null | xargs -n1 basename | sed 's/.tfvars$//' || echo "  None found"
    exit 1
fi

APP_NAME=$1
CONFIG_FILE="infrastructure/ec2/terraform/config/${APP_NAME}.tfvars"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file $CONFIG_FILE not found"
    echo "Available apps:"
    ls -1 infrastructure/ec2/terraform/config/*.tfvars 2>/dev/null | xargs -n1 basename | sed 's/.tfvars$//' || echo "  None found"
    exit 1
fi

# Set AWS environment variables
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=$(aws configure get region || echo "us-east-1")

echo "Deploying to account: $AWS_ACCOUNT_ID"
echo "Deploying to region: $AWS_REGION"

echo "=================================================="
echo "Deploying Terraform App: $APP_NAME"
echo "=================================================="

cd infrastructure/ec2/terraform

# Initialize if needed
if [ ! -d ".terraform" ]; then
    terraform init
fi

# Apply with the specific config
terraform apply -var-file="config/${APP_NAME}.tfvars" -auto-approve

echo ""
echo "=================================================="
echo "Deployment complete!"
echo "=================================================="
echo ""
terraform output
