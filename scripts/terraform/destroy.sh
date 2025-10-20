#!/bin/bash

set -e

# Usage: ./scripts/terraform/destroy.sh <app-name>
# Example: ./scripts/terraform/destroy.sh python-flask

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

echo "Destroying from account: $AWS_ACCOUNT_ID"
echo "Destroying from region: $AWS_REGION"

echo "=================================================="
echo "Destroying Terraform App: $APP_NAME"
echo "=================================================="

cd infrastructure/ec2/terraform

# Destroy with the specific config
terraform destroy -var-file="config/${APP_NAME}.tfvars" -var="aws_region=$AWS_REGION" -auto-approve

echo ""
echo "=================================================="
echo "Teardown complete!"
echo "=================================================="
