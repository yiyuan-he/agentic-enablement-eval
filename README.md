# AWS Application Signals Enablement Testing

Automated testing for Application Signals enablement across 4 languages (Python, Node.js, Java, .NET) and 3 IaC tools (CDK, Terraform, CloudFormation) using AI agents.

## Prerequisites

- AWS CLI configured
- Docker with buildx
- Node.js/npm (for CDK)
- Terraform
- Amazon Q CLI

## Automated Testing

**Test all 4 languages:**
```bash
./scripts/cdk/test-ec2.sh
./scripts/terraform/test-ec2.sh
./scripts/cloudformation/test-ec2.sh
```

**Test single language:**
```bash
./scripts/cdk/test-ec2.sh python-flask
./scripts/terraform/test-ec2.sh python-flask
./scripts/cloudformation/test-ec2.sh python-flask

# Available: python-flask, nodejs-express, java-springboot, dotnet-aspnetcore
```

## Cleanup

**Destroy all:**
```bash
./scripts/cdk/destroy-all.sh
./scripts/terraform/destroy-all.sh
./scripts/cloudformation/destroy-all.sh
```

**Destroy single app:**
```bash
./scripts/cdk/destroy.sh python-flask
./scripts/terraform/destroy.sh python-flask
./scripts/cloudformation/destroy.sh python-flask
```
