# AWS Application Signals Enablement Testing

Automated testing for Application Signals enablement across 4 languages (Python, Node.js, Java, .NET) and 3 IaC tools (CDK, Terraform, CloudFormation) using AI agents.

## Prerequisites

- AWS CLI configured
- Docker with buildx
- Node.js/npm (for CDK)
- Terraform
- Amazon Q CLI (for automated testing)

## Automated Testing

**Test all 4 languages:**
```bash
./scripts/test-cdk-ec2.sh
./scripts/test-terraform-ec2.sh
./scripts/test-cloudformation-ec2.sh
```

**Test single language:**
```bash
./scripts/test-cdk-ec2.sh python-flask
./scripts/test-terraform-ec2.sh python-flask
./scripts/test-cloudformation-ec2.sh python-flask

# Available: python-flask, nodejs-express, java-springboot, dotnet-aspnetcore
```

**What it does:**
1. Resets git changes
2. AI agent enables Application Signals
3. Rebuilds Docker images with instrumentation
4. Deploys infrastructure
5. Verifies deployment

## Service Naming

Services deployed with these names in CloudWatch Application Signals:
- **CDK:** `{app}-cdk` (e.g., `python-flask-cdk`)
- **Terraform:** `{app}-terraform` (e.g., `python-flask-terraform`)
- **CloudFormation:** `{app}-cfn` (e.g., `python-flask-cfn`)

## Cleanup

**Destroy all stacks:**
```bash
./scripts/cdk/destroy-all.sh
./scripts/terraform/destroy-all.sh
./scripts/cloudformation/destroy-all.sh
```

**Destroy single stack:**
```bash
./scripts/cdk/destroy.sh PythonFlaskCdkStack
./scripts/terraform/destroy.sh python-flask
./scripts/cloudformation/destroy.sh python-flask
```

## Manual Deployment

**Build images:**
```bash
./scripts/build-and-push-images.sh              # All apps
./scripts/build-and-push-images.sh python-flask  # Single app
```

**Deploy:**
```bash
# CDK
cd infrastructure/ec2/cdk && npm install
./scripts/cdk/deploy.sh PythonFlaskCdkStack

# Terraform
./scripts/terraform/deploy.sh python-flask

# CloudFormation
./scripts/cloudformation/deploy.sh python-flask
```

## Sample Apps

Each app has:
- `Dockerfile` - Containerized app
- `/health` - Health endpoint
- `/api/buckets` - Lists S3 buckets (tests AWS SDK instrumentation)
- `generate-traffic.sh` - Continuous traffic generation
