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

# Set AWS environment variables
export CDK_DEFAULT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
export CDK_DEFAULT_REGION=$(aws configure get region || echo "us-east-1")

echo "Deploying to account: $CDK_DEFAULT_ACCOUNT"
echo "Deploying to region: $CDK_DEFAULT_REGION"

echo "=================================================="
echo "Deploying CDK Stack: $STACK_NAME"
echo "=================================================="

cd infrastructure/ec2/cdk
npx cdk deploy $STACK_NAME --require-approval never

echo ""
echo "=================================================="
echo "Deployment complete!"
echo "=================================================="
echo ""
echo "To check your deployed apps, run:"
echo "  aws ec2 describe-instances --filters 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]' --output table"
