#!/bin/bash

set -e

# Usage: ./scripts/cloudformation/destroy.sh <app-name>
# Example: ./scripts/cloudformation/destroy.sh python-flask

if [ $# -eq 0 ]; then
    echo "Usage: $0 <app-name>"
    echo ""
    echo "Available apps:"
    ls -1 infrastructure/ec2/cloudformation/config/*.json 2>/dev/null | xargs -n1 basename | sed 's/.json$//' || echo "  None found"
    exit 1
fi

APP_NAME=$1
STACK_NAME="${APP_NAME}-cfn"

# Set AWS environment variables
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=$(aws configure get region || echo "us-east-1")

echo "Destroying from account: $AWS_ACCOUNT_ID"
echo "Destroying from region: $AWS_REGION"

echo "=================================================="
echo "Destroying CloudFormation Stack: $STACK_NAME"
echo "=================================================="

# Check if stack exists
if aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$AWS_REGION" > /dev/null 2>&1; then
    # Delete CloudFormation stack
    aws cloudformation delete-stack \
        --stack-name "$STACK_NAME" \
        --region "$AWS_REGION"

    echo "Waiting for stack deletion to complete..."
    aws cloudformation wait stack-delete-complete \
        --stack-name "$STACK_NAME" \
        --region "$AWS_REGION"

    echo ""
    echo "=================================================="
    echo "Teardown complete!"
    echo "=================================================="
else
    echo "Stack $STACK_NAME does not exist, nothing to destroy"
fi
