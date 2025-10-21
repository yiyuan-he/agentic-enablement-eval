#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
  echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Set CDK environment variables from AWS CLI config
export CDK_DEFAULT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
export CDK_DEFAULT_REGION=$(aws configure get region || echo "us-east-1")

echo "========================================================================"
print_status "Destroying all CDK EC2 Application Signals stacks"
print_status "Account: $CDK_DEFAULT_ACCOUNT"
print_status "Region: $CDK_DEFAULT_REGION"
echo "========================================================================"
echo ""

cd infrastructure/ec2/cdk

npx cdk destroy --all --force

echo ""
echo "========================================================================"
print_success "All stacks destroyed!"
echo "========================================================================"
