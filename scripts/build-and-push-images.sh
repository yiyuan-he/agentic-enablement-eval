#!/bin/bash

set -e

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region || echo "us-east-1")

echo "Building and pushing Docker images to ECR..."
echo "Account: $AWS_ACCOUNT_ID"
echo "Region: $AWS_REGION"
echo ""

# Authenticate Docker with ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Define apps to build
declare -A APPS
APPS["python-flask"]="sample-apps/python/flask"
APPS["nodejs-express"]="sample-apps/nodejs/express"
APPS["java-springboot"]="sample-apps/java/springboot"
APPS["dotnet-aspnetcore"]="sample-apps/dotnet/aspnetcore"

# Build and push each app
for APP_NAME in "${!APPS[@]}"; do
    APP_DIR="${APPS[$APP_NAME]}"
    ECR_REPO_NAME="$APP_NAME"
    ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME"

    echo "=================================================="
    echo "Processing: $APP_NAME"
    echo "Directory: $APP_DIR"
    echo "=================================================="

    # Create ECR repository if it doesn't exist
    if ! aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION > /dev/null 2>&1; then
        echo "Creating ECR repository: $ECR_REPO_NAME"
        aws ecr create-repository --repository-name $ECR_REPO_NAME --region $AWS_REGION
    else
        echo "ECR repository already exists: $ECR_REPO_NAME"
    fi

    # Build Docker image
    echo "Building Docker image..."
    docker build -t $ECR_REPO_NAME:latest $APP_DIR

    # Tag image for ECR
    echo "Tagging image for ECR..."
    docker tag $ECR_REPO_NAME:latest $ECR_URI:latest

    # Push to ECR
    echo "Pushing image to ECR..."
    docker push $ECR_URI:latest

    echo "✓ Successfully pushed $ECR_REPO_NAME to ECR"
    echo ""
done

echo "=================================================="
echo "All images built and pushed successfully!"
echo "=================================================="
