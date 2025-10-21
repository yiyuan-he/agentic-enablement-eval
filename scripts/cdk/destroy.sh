#!/bin/bash

set -e

# Usage: ./scripts/cdk/destroy.sh <stack-name>
# Example: ./scripts/cdk/destroy.sh PythonFlaskCdkStack

if [ $# -eq 0 ]; then
    echo "Usage: $0 <stack-name>"
    echo ""
    echo "Available stacks:"
    echo "  PythonFlaskCdkStack"
    echo "  NodejsExpressCdkStack"
    echo "  JavaSpringbootCdkStack"
    echo "  DotnetAspnetcoreCdkStack"
    echo ""
    echo "To destroy all stacks, use: ./scripts/cdk/destroy-all.sh"
    exit 1
fi

STACK_NAME=$1

# Set CDK environment variables from AWS CLI config
export CDK_DEFAULT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
export CDK_DEFAULT_REGION=$(aws configure get region || echo "us-east-1")

echo "Destroying from account: $CDK_DEFAULT_ACCOUNT"
echo "Destroying from region: $CDK_DEFAULT_REGION"

echo "=================================================="
echo "Destroying CDK Stack: $STACK_NAME"
echo "=================================================="

cd infrastructure/ec2/cdk

npx cdk destroy $STACK_NAME --force

echo ""
echo "=================================================="
echo "Teardown complete!"
echo "=================================================="
