#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# All app names
declare -a APPS=(
  "python-flask"
  "nodejs-express"
  "java-springboot"
  "dotnet-aspnetcore"
)

print_status() {
  echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

echo "========================================================================"
print_status "Destroying all Terraform EC2 Application Signals stacks"
echo "========================================================================"
echo ""

for app_name in "${APPS[@]}"; do
  print_status "Destroying $app_name..."
  if "$SCRIPT_DIR/destroy.sh" "$app_name"; then
    print_success "$app_name destroyed"
  else
    print_error "Failed to destroy $app_name (might not exist)"
  fi
  echo ""
done

echo "========================================================================"
print_success "All stacks destroyed!"
echo "========================================================================"
