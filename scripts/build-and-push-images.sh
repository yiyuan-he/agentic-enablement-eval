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

# Define apps to build (compatible with Bash 3.2+)
APPS=(
    "python-flask:sample-apps/python/flask"
    "nodejs-express:sample-apps/nodejs/express"
    "java-springboot:sample-apps/java/springboot"
    "dotnet-aspnetcore:sample-apps/dotnet/aspnetcore"
)

# Build and push each app
for APP_ENTRY in "${APPS[@]}"; do
    APP_NAME="${APP_ENTRY%%:*}"
    APP_DIR="${APP_ENTRY#*:}"
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

    # Build multi-platform Docker image and push to ECR
    echo "Building and pushing multi-platform Docker image..."
    docker buildx build --platform linux/amd64,linux/arm64 \
        -t $ECR_URI:latest \
        --push \
        $APP_DIR

    echo "✓ Successfully pushed $ECR_REPO_NAME to ECR"
    echo ""
done

echo "=================================================="
echo "All images built and pushed successfully!"
echo "=================================================="
