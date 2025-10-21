#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <app-name>"
    echo ""
    echo "Available apps:"
    echo "  python-flask"
    echo "  nodejs-express"
    echo "  java-springboot"
    echo "  dotnet-aspnetcore"
    echo ""
    echo "To destroy all stacks, use: ./scripts/cdk/destroy-all.sh"
    exit 1
fi

APP_NAME=$1

# Map app name to CDK stack name
case "$APP_NAME" in
    python-flask)
        STACK_NAME="PythonFlaskCdkStack"
        ;;
    nodejs-express)
        STACK_NAME="NodejsExpressCdkStack"
        ;;
    java-springboot)
        STACK_NAME="JavaSpringbootCdkStack"
        ;;
    dotnet-aspnetcore)
        STACK_NAME="DotnetAspnetcoreCdkStack"
        ;;
    *)
        echo "Error: Unknown app name: $APP_NAME"
        echo "Available apps: python-flask, nodejs-express, java-springboot, dotnet-aspnetcore"
        exit 1
        ;;
esac

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
