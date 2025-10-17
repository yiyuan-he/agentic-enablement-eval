import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as iam from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';

export interface AppConfig {
  appName: string;
  language: string;
  port: number;
  appDirectory: string;
  healthCheckPath: string;
  serviceName: string;
}

export class EC2AppStack extends cdk.Stack {
  constructor(scope: Construct, id: string, config: AppConfig, props?: cdk.StackProps) {
    super(scope, id, props);

    // Construct ECR image URI using convention
    const ecrImageUri = `${this.account}.dkr.ecr.${this.region}.amazonaws.com/${config.appName}:latest`;

    // Use default VPC
    const vpc = ec2.Vpc.fromLookup(this, 'DefaultVPC', {
      isDefault: true,
    });

    // IAM role for EC2 with S3 read permissions, ECR pull, SSM access, and CloudWatch Agent
    const role = new iam.Role(this, 'AppRole', {
      assumedBy: new iam.ServicePrincipal('ec2.amazonaws.com'),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonS3ReadOnlyAccess'),
        iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonSSMManagedInstanceCore'),
        iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonEC2ContainerRegistryReadOnly'),
        iam.ManagedPolicy.fromAwsManagedPolicyName('CloudWatchAgentServerPolicy'),
      ],
    });

    // Security group
    const securityGroup = new ec2.SecurityGroup(this, 'AppSG', {
      vpc,
      description: `Security group for ${config.appName}`,
      allowAllOutbound: true,
    });

    securityGroup.addIngressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(config.port),
      `Allow access to ${config.appName} on port ${config.port}`
    );

    // User data to pull Docker image and run container
    const userData = ec2.UserData.forLinux();
    userData.addCommands(
      '#!/bin/bash',
      'set -e',
      '',
      '# Update and install dependencies',
      'yum update -y',
      'yum install -y docker',
      '',
      '# Download and install CloudWatch Agent',
      'wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm',
      'rpm -U ./amazon-cloudwatch-agent.rpm',
      '',
      '# Create CloudWatch Agent configuration for Application Signals',
      'mkdir -p /opt/aws/amazon-cloudwatch-agent/etc',
      'cat > /tmp/cw-appsignals-config.json << \'EOF\'',
      '{',
      '"traces": {',
      '"traces_collected": {',
      '"application_signals": {}',
      '}',
      '},',
      '"logs": {',
      '"metrics_collected": {',
      '"application_signals": {}',
      '}',
      '}',
      '}',
      'EOF',
      'mv /tmp/cw-appsignals-config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json',
      '',
      '# Start CloudWatch Agent with Application Signals configuration',
      '/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \\',
      '  -a fetch-config \\',
      '  -m ec2 \\',
      '  -s \\',
      '  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json',
      '',
      '# Start Docker service',
      'systemctl start docker',
      'systemctl enable docker',
      'usermod -a -G docker ec2-user',
      '',
      '# Authenticate with ECR',
      `aws ecr get-login-password --region ${this.region} | docker login --username AWS --password-stdin ${this.account}.dkr.ecr.${this.region}.amazonaws.com`,
      '',
      '# Pull Docker image',
      `docker pull ${ecrImageUri}`,
      '',
      '# Run container',
      `docker run -d --name ${config.appName} \\`,
      `  -p ${config.port}:${config.port} \\`,
      `  -e PORT=${config.port} \\`,
      `  -e SERVICE_NAME=${config.serviceName} \\`,
      `  -e AWS_REGION=${this.region} \\`,
      `  ${ecrImageUri}`,
      '',
      '# Wait for application to start',
      'sleep 10',
      '',
      '# Start traffic generator inside container',
      `docker exec -d ${config.appName} bash /app/generate-traffic.sh`,
      '',
      'echo "Application deployed and traffic generation started"'
    );

    // EC2 instance
    const instance = new ec2.Instance(this, 'AppInstance', {
      vpc,
      instanceType: ec2.InstanceType.of(
        ec2.InstanceClass.T3,
        ec2.InstanceSize.SMALL
      ),
      machineImage: ec2.MachineImage.latestAmazonLinux2023(),
      role,
      securityGroup,
      userData,
      vpcSubnets: {
        subnetType: ec2.SubnetType.PUBLIC,
      },
    });

    // Outputs
    new cdk.CfnOutput(this, 'InstanceId', {
      value: instance.instanceId,
      description: 'EC2 Instance ID',
    });

    new cdk.CfnOutput(this, 'InstancePublicIP', {
      value: instance.instancePublicIp,
      description: 'EC2 Instance Public IP',
    });

    new cdk.CfnOutput(this, 'HealthCheckURL', {
      value: `http://${instance.instancePublicIp}:${config.port}${config.healthCheckPath}`,
      description: `${config.appName} Health Endpoint`,
    });

    new cdk.CfnOutput(this, 'BucketsAPIURL', {
      value: `http://${instance.instancePublicIp}:${config.port}/api/buckets`,
      description: `${config.appName} Buckets API Endpoint`,
    });

    new cdk.CfnOutput(this, 'ECRImageURI', {
      value: ecrImageUri,
      description: 'ECR image URI used',
    });

    new cdk.CfnOutput(this, 'Language', {
      value: config.language,
      description: 'Application language',
    });
  }
}
