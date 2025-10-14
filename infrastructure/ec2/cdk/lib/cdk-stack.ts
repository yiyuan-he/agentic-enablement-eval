import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as iam from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';

export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc = ec2.Vpc.fromLookup(this, 'DefaultVPC', {
        isDefault: true,
    });

    const securityGroup = new ec2.SecurityGroup(this, 'TestAppSecurityGroup', {
        vpc,
        description: 'Security group for Application Signals test EC2',
        allowAllOutbound: true
    });

    securityGroup.addIngressRule(
        ec2.Peer.anyIpv4(),
        ec2.Port.tcp(5000),
        'Allow application access for testing traffic'
    );

    const role = new iam.Role(this, 'TestAppRole', {
        assumedBy: new iam.ServicePrincipal('ec2.amazonaws.com'),
        description: 'Role for Application Signals test EC2 instance',
        roleName: 'Ec2AppSignalsTestRole',
        managedPolicies: [
            iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonSSMManagedInstanceCore'),
        ],
    });

    const instance = new ec2.Instance(this, 'TestInstance', {
        vpc,
        instanceType: ec2.InstanceType.of(
            ec2.InstanceClass.T3,
            ec2.InstanceSize.SMALL
        ),
        machineImage: ec2.MachineImage.latestAmazonLinux2023(),
        securityGroup,
        role,
        vpcSubnets: {
            subnetType: ec2.SubnetType.PUBLIC
        },
    });

    instance.userData.addCommands(
        '#!/bin/bash',
        'set -e',
        '',
        '# Update system',
        'yum update -y',
        '',
        '# Install Python 3.11',
        'yum install -y python3.11 python3.11-pip',
        'ln -sf /usr/bin/python3.11 /usr/bin/python3',
        'ln -sf /usr/bin/pip3.11 /usr/bin/pip3',
        '',
        '# Install Node.js 18',
        'curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -',
        'yum install -y nodejs',
        '',
        '# Install Java 17',
        'yum install -y java-17-amazon-corretto',
        '',
        '# Create app directory',
        'mkdir -p /opt/test-app',
        'chown ec2-user:ec2-user /opt/test-app',
        '',
        '# Install AWS CLI v2',
        'yum install -y unzip',
        'curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"',
        'unzip -q awscliv2.zip',
        './aws/install',
        'rm -rf aws awscliv2.zip',
        '',
        'echo "Instance setup complete" > /var/log/userdata-complete.log'
    );

    new cdk.CfnOutput(this, 'InstanceId', {
        value: instance.instanceId,
        description: 'EC2 Instance ID',
    });

    new cdk.CfnOutput(this, 'PublicIp', {
        value: instance.instancePublicIp,
        description: 'EC2 Public IP Address'
    });

    new cdk.CfnOutput(this, 'RoleName', {
        value: role.roleName,
        description: 'IAM Role Name',
    });
    
    new cdk.CfnOutput(this, 'ConnectCommand', {
        value: `aws ssm start-session --target ${instance.instanceId}`,
        description: 'SSM command to connect to instance',
    });
  }
}
