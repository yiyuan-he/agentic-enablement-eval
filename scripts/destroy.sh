#!/bin/bash

set -e

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
