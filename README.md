# AWS Application Signals Enablement Testing

Testing infrastructure for validating Application Signals enablement across multiple languages and platforms using AI agents and MCP tools.

## Structure

```
sample-apps/                    # Sample applications for testing
  python/flask/                 # Python Flask app
  nodejs/express/               # Node.js Express app
  java/springboot/              # Java Spring Boot app
  dotnet/aspnetcore/            # .NET ASP.NET Core app

infrastructure/ec2/cdk/         # CDK infrastructure for EC2 deployment
  lib/cdk-stack.ts             # Parameterized EC2 stack (language-agnostic)
  config/                      # Configuration files per app
    python-flask.json
    nodejs-express.json
    java-springboot.json
    dotnet-aspnetcore.json

scripts/                        # Helper scripts
  build-and-push-images.sh     # Build & push Docker images to ECR
  deploy.sh                    # Deploy CDK stacks
  destroy.sh                   # Tear down CDK stacks
```

## Sample Apps

Each sample app includes:
- **Dockerfile**: Containerizes the application
- **Health endpoint**: `/health` - Returns service status
- **API endpoint**: `/api/buckets` - Lists S3 buckets (tests AWS SDK integration)
- **generate-traffic.sh**: Continuously generates traffic to endpoints

## Prerequisites

1. AWS CLI configured with credentials for your testing account
2. Docker installed and running
3. Node.js and npm installed (for CDK)

## Quick Start

### 1. Install CDK Dependencies

```bash
cd infrastructure/ec2/cdk
npm install
```

### 2. Build and Push Docker Images to ECR

This step builds Docker images from the sample apps and pushes them to ECR in your AWS account:

```bash
./scripts/build-and-push-images.sh
```

### 3. Deploy Infrastructure

Deploy all apps:
```bash
./scripts/deploy.sh
```

Or deploy a specific app:
```bash
./scripts/deploy.sh PythonFlaskStack
./scripts/deploy.sh NodejsExpressStack
./scripts/deploy.sh JavaSpringbootStack
./scripts/deploy.sh DotnetAspnetcoreStack
```

The CDK will:
1. Create an EC2 instance with Docker installed
2. Pull the pre-built Docker image from ECR
3. Run the containerized application
4. Start traffic generation automatically

### 4. Verify Deployment

After deployment, CDK outputs will show:
- Instance ID
- Public IP address
- Health check URL
- Buckets API URL

Test the endpoints:
```bash
curl http://<public-ip>:5000/health        # Python Flask
curl http://<public-ip>:3000/health        # Node.js Express
curl http://<public-ip>:8080/health        # Java Spring Boot
curl http://<public-ip>:5000/health        # .NET ASP.NET Core
```

### 5. Teardown

Destroy all stacks:
```bash
./scripts/destroy.sh
```

Or destroy a specific stack:
```bash
./scripts/destroy.sh PythonFlaskStack
```

## Accessing Instances

Use AWS Systems Manager Session Manager (no SSH required):

```bash
# Get instance ID from CDK output
aws ssm start-session --target <instance-id>

# Check Docker container status
docker ps

# View application logs
docker logs <container-name>

# View traffic generator logs
tail -f /home/ec2-user/traffic.log
```

## Architecture

- **EC2**: T3.small instances running Amazon Linux 2023
- **Docker**: Applications run in containers pulled from ECR
- **IAM**: Instance role with S3 read access, ECR pull, and SSM access
- **Security**: Security groups allow inbound traffic on app-specific ports
- **VPC**: Uses default VPC for simplicity
- **Traffic**: Background script continuously hits endpoints to generate telemetry

## Testing Application Signals Enablement

This infrastructure is intentionally deployed **WITHOUT** Application Signals enabled. The testing workflow:

1. **Deploy baseline**: Use these scripts to deploy apps without Application Signals
2. **Invoke MCP tool**: Use the `enable_application_signals` MCP tool with parameters:
   ```python
   platform = "ec2"
   language = "python"  # or nodejs, java, dotnet
   iac_directory = "infrastructure/ec2/cdk"
   app_directory = "sample-apps/python/flask"
   ```
3. **AI agent modifies IaC**: Agent updates CDK based on MCP tool guidance
4. **Redeploy**: Run `./scripts/deploy.sh` to apply changes
5. **Validate**: Check CloudWatch for Application Signals telemetry
