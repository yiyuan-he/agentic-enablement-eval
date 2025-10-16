#!/bin/bash

set -e

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
