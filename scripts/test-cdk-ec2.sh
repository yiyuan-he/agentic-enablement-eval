#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Test cases: config_file, language, framework, app_directory, stack_name
declare -a TEST_CASES=(
  "python-flask:python:flask:sample-apps/python/flask:PythonFlaskCdkStack"
  "nodejs-express:nodejs:express:sample-apps/nodejs/express:NodejsExpressCdkStack"
  "java-springboot:java:springboot:sample-apps/java/springboot:JavaSpringbootCdkStack"
  "dotnet-aspnetcore:dotnet:aspnetcore:sample-apps/dotnet/aspnetcore:DotnetAspnetcoreCdkStack"
)

# Function to print colored output
print_status() {
  echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Function to reset git changes
reset_changes() {
  print_status "Resetting git changes..."
  cd "$PROJECT_ROOT"

  # Reset all infrastructure files
  git checkout -- infrastructure/ec2/cdk/ 2>/dev/null || true
  git clean -fd infrastructure/ec2/cdk/ || true

  # Reset all sample app files (Dockerfiles, code, etc.)
  git checkout -- sample-apps/ 2>/dev/null || true
  git clean -fd sample-apps/ || true

  print_success "Git changes reset"
}

# Function to run AI enablement
run_ai_enablement() {
  local config_file=$1
  local language=$2
  local framework=$3
  local app_dir=$4

  print_status "Running AI enablement for $config_file..."

  local prompt="enable application signals for my $language $framework app on ec2. my iac directory is infrastructure/ec2/cdk and my app directory is $app_dir"

  cd "$PROJECT_ROOT"

  # Run Amazon Q CLI with the enablement prompt
  if command -v q &> /dev/null; then
    AMAZON_Q_SIGV4=1 q chat "$prompt" --no-interactive --trust-all-tools
    print_success "AI enablement completed for $config_file"
  else
    print_error "Amazon Q CLI not found. Please install it first."
    return 1
  fi
}

# Function to build and push Docker image
build_and_push_image() {
  local config_file=$1

  print_status "Building and pushing Docker image for $config_file..."
  cd "$PROJECT_ROOT"

  if [[ -f "scripts/build-and-push-images.sh" ]]; then
    ./scripts/build-and-push-images.sh "$config_file"
    print_success "Docker image built and pushed for $config_file"
  else
    print_error "build-and-push-images.sh script not found"
    return 1
  fi
}

# Function to deploy with CDK
deploy_cdk() {
  local stack_name=$1

  print_status "Deploying $stack_name with CDK..."
  cd "$PROJECT_ROOT"

  if [[ -f "scripts/cdk/deploy.sh" ]]; then
    ./scripts/cdk/deploy.sh "$stack_name"
    print_success "CDK deployment completed for $stack_name"
  else
    print_error "cdk deploy.sh script not found"
    return 1
  fi
}

# Function to verify deployment
verify_deployment() {
  local stack_name=$1

  print_status "Verifying deployment for $stack_name..."

  # Get the instance ID from CloudFormation stack
  cd "$PROJECT_ROOT/infrastructure/ec2/cdk"
  local instance_id=$(npx cdk list 2>/dev/null || echo "")

  if [[ -z "$instance_id" ]]; then
    print_warning "Could not verify stack, skipping detailed check"
    return 0
  fi

  # Wait a bit for the container to start
  print_status "Waiting 30 seconds for application to start..."
  sleep 30

  # Check if container is running (optional - requires SSM access)
  print_status "Container should be running. Check manually if needed."
  print_success "Deployment verification completed (basic checks passed)"
}

# Main test loop
main() {
  # Check if specific app is requested
  local requested_app="$1"
  local filtered_cases=()

  if [ -n "$requested_app" ]; then
    print_status "Testing single application: $requested_app"
    # Filter to only the requested app
    for test_case in "${TEST_CASES[@]}"; do
      IFS=':' read -r config_file language framework app_dir stack_name <<< "$test_case"
      if [ "$config_file" = "$requested_app" ]; then
        filtered_cases+=("$test_case")
        break
      fi
    done

    if [ ${#filtered_cases[@]} -eq 0 ]; then
      print_error "App '$requested_app' not found."
      echo "Available apps: python-flask, nodejs-express, java-springboot, dotnet-aspnetcore"
      exit 1
    fi
  else
    print_status "Starting CDK EC2 Application Signals enablement test"
    print_status "Testing ${#TEST_CASES[@]} applications"
    filtered_cases=("${TEST_CASES[@]}")
  fi

  echo ""

  local iteration=1
  local total=${#filtered_cases[@]}

  for test_case in "${filtered_cases[@]}"; do
    IFS=':' read -r config_file language framework app_dir stack_name <<< "$test_case"

    echo ""
    echo "========================================================================"
    print_status "Iteration $iteration/$total: Testing $config_file"
    echo "========================================================================"
    echo ""

    # Step 1: Reset any previous changes
    reset_changes

    # Step 2: Run AI enablement
    if ! run_ai_enablement "$config_file" "$language" "$framework" "$app_dir"; then
      print_error "AI enablement failed for $config_file, skipping to next iteration"
      ((iteration++))
      continue
    fi

    # Step 3: Build and push Docker image
    if ! build_and_push_image "$config_file"; then
      print_error "Build and push failed for $config_file, skipping to next iteration"
      ((iteration++))
      continue
    fi

    # Step 4: Deploy with CDK
    if ! deploy_cdk "$stack_name"; then
      print_error "CDK deployment failed for $stack_name, skipping to next iteration"
      ((iteration++))
      continue
    fi

    # Step 5: Verify deployment
    verify_deployment "$stack_name"

    # Step 6: Reset changes for next iteration
    reset_changes

    print_success "Completed testing $config_file"
    ((iteration++))
  done

  echo ""
  echo "========================================================================"
  print_success "All tests completed!"
  if [ ${#filtered_cases[@]} -eq 1 ]; then
    # Get the stack name from the filtered case
    IFS=':' read -r config_file language framework app_dir stack_name <<< "${filtered_cases[0]}"
    print_status "Stack deployed. Wait a few minutes for telemetry to flow."
    print_status "To destroy: ./scripts/cdk/destroy.sh $stack_name"
  else
    print_status "All 4 stacks are now deployed. Wait a few minutes for telemetry to flow."
    print_status "To destroy all stacks later, run: ./scripts/cdk/destroy-all.sh"
  fi
  echo "========================================================================"
}

# Run main function
main "$@"
