#!/bin/bash

set -e

# Set CDK environment variables from AWS CLI config
export CDK_DEFAULT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
export CDK_DEFAULT_REGION=$(aws configure get region || echo "us-east-1")

echo "Deploying to account: $CDK_DEFAULT_ACCOUNT"
echo "Deploying to region: $CDK_DEFAULT_REGION"

cd infrastructure/ec2/cdk

echo "=================================================="
echo "Deploying CDK Stacks"
echo "=================================================="

# Check if specific stack name is provided
if [ $# -eq 1 ]; then
    STACK_NAME=$1
    echo "Deploying single stack: $STACK_NAME"
    npx cdk deploy $STACK_NAME --require-approval never
else
    echo "Deploying all stacks..."
    npx cdk deploy --all --require-approval never
fi

echo ""
echo "=================================================="
echo "Deployment complete!"
echo "=================================================="
echo ""
echo "To check your deployed apps, run:"
echo "  aws ec2 describe-instances --filters 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]' --output table"
