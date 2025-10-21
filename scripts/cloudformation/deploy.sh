#!/bin/bash

set -e

# Usage: ./scripts/cloudformation/deploy.sh <app-name>
# Example: ./scripts/cloudformation/deploy.sh python-flask

if [ $# -eq 0 ]; then
    echo "Usage: $0 <app-name>"
    echo ""
    echo "Available apps:"
    ls -1 infrastructure/ec2/cloudformation/config/*.json 2>/dev/null | xargs -n1 basename | sed 's/.json$//' || echo "  None found"
    exit 1
fi

APP_NAME=$1
CONFIG_FILE="infrastructure/ec2/cloudformation/config/${APP_NAME}.json"
TEMPLATE_FILE="infrastructure/ec2/cloudformation/template.yaml"
STACK_NAME="${APP_NAME}-cfn"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file $CONFIG_FILE not found"
    echo "Available apps:"
    ls -1 infrastructure/ec2/cloudformation/config/*.json 2>/dev/null | xargs -n1 basename | sed 's/.json$//' || echo "  None found"
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file $TEMPLATE_FILE not found"
    exit 1
fi

# Set AWS environment variables
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=$(aws configure get region || echo "us-east-1")

echo "Deploying to account: $AWS_ACCOUNT_ID"
echo "Deploying to region: $AWS_REGION"

echo "=================================================="
echo "Deploying CloudFormation Stack: $STACK_NAME"
echo "=================================================="

# Deploy CloudFormation stack
aws cloudformation deploy \
    --template-file "$TEMPLATE_FILE" \
    --stack-name "$STACK_NAME" \
    --parameter-overrides file://"$CONFIG_FILE" \
    --capabilities CAPABILITY_NAMED_IAM \
    --region "$AWS_REGION"

echo ""
echo "=================================================="
echo "Deployment complete!"
echo "=================================================="
echo ""

# Show stack outputs
aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$AWS_REGION" \
    --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
    --output table
