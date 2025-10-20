#!/bin/bash

set -e

# Detect if deploying CDK or Terraform based on argument pattern
# CDK stacks end with "Stack" (e.g., PythonFlaskStack)
# Terraform uses app names (e.g., python-flask)

if [ $# -eq 0 ]; then
    echo "Usage: $0 <stack-name-or-app-name>"
    echo ""
    echo "CDK Stacks (ends with 'Stack'):"
    echo "  ./scripts/deploy.sh PythonFlaskStack"
    echo "  ./scripts/deploy.sh JavaSpringbootStack"
    echo "  ./scripts/deploy.sh NodejsExpressStack"
    echo "  ./scripts/deploy.sh DotnetAspnetcoreStack"
    echo ""
    echo "Terraform Apps:"
    echo "  ./scripts/deploy.sh python-flask"
    echo "  ./scripts/deploy.sh java-springboot"
    echo "  ./scripts/deploy.sh nodejs-express"
    echo "  ./scripts/deploy.sh dotnet-aspnetcore"
    exit 1
fi

TARGET=$1

# Set AWS environment variables
export CDK_DEFAULT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
export CDK_DEFAULT_REGION=$(aws configure get region || echo "us-east-1")

echo "Deploying to account: $CDK_DEFAULT_ACCOUNT"
echo "Deploying to region: $CDK_DEFAULT_REGION"

# Check if this is a CDK stack (ends with "Stack")
if [[ "$TARGET" == *Stack ]]; then
    echo "=================================================="
    echo "Deploying CDK Stack: $TARGET"
    echo "=================================================="

    cd infrastructure/ec2/cdk
    npx cdk deploy $TARGET --require-approval never

else
    # This is a Terraform deployment
    CONFIG_FILE="infrastructure/ec2/terraform/config/${TARGET}.tfvars"

    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Terraform config file $CONFIG_FILE not found"
        echo "Available Terraform apps:"
        ls -1 infrastructure/ec2/terraform/config/*.tfvars 2>/dev/null | xargs -n1 basename | sed 's/.tfvars$//' || echo "  None found"
        exit 1
    fi

    echo "=================================================="
    echo "Deploying Terraform App: $TARGET"
    echo "=================================================="

    cd infrastructure/ec2/terraform

    # Initialize if needed
    if [ ! -d ".terraform" ]; then
        terraform init
    fi

    # Apply with the specific config
    terraform apply -var-file="config/${TARGET}.tfvars" -auto-approve
fi

echo ""
echo "=================================================="
echo "Deployment complete!"
echo "=================================================="
echo ""
echo "To check your deployed apps, run:"
echo "  aws ec2 describe-instances --filters 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]' --output table"
