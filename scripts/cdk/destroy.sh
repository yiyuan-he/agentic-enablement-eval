#!/bin/bash

set -e

# Set CDK environment variables from AWS CLI config
export CDK_DEFAULT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
export CDK_DEFAULT_REGION=$(aws configure get region || echo "us-east-1")

echo "Destroying from account: $CDK_DEFAULT_ACCOUNT"
echo "Destroying from region: $CDK_DEFAULT_REGION"

cd infrastructure/ec2/cdk

echo "=================================================="
echo "Destroying CDK Stacks"
echo "=================================================="

# Check if specific stack name is provided
if [ $# -eq 1 ]; then
    STACK_NAME=$1
    echo "Destroying single stack: $STACK_NAME"
    npx cdk destroy $STACK_NAME --force
else
    echo "Destroying all stacks..."
    npx cdk destroy --all --force
fi

echo ""
echo "=================================================="
echo "Teardown complete!"
echo "=================================================="
