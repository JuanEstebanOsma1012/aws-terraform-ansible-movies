# AWS Infrastructure for Movie Analyst Application

This repository contains Terraform infrastructure code to deploy a three-tier web application (Movie Analyst) on AWS. The infrastructure includes a web frontend, API backend, and MySQL database with proper security groups and load balancing.

## Architecture Overview

The infrastructure deploys the following components:

- **VPC with public and private subnets** across multiple availability zones
- **Application Load Balancer (ALB)** for frontend and backend services
- **Frontend instances** running the Movie Analyst UI (Node.js application)
- **Backend instances** running the Movie Analyst API (Node.js with MySQL)
- **RDS MySQL database** for data persistence
- **Bastion host** for secure SSH access to private instances
- **Security groups** with proper network access controls

### Architecture Diagram

```
Internet Gateway
        |
    Public Subnet
        |
    Load Balancer ---- Frontend Instances
        |                      |
    Private Subnet             |
        |                      |
    Backend Instances ----------
        |
    Database Subnet
        |
    RDS MySQL
```

## Prerequisites

Before deploying this infrastructure, ensure you have:

1. **AWS Account** with administrative privileges or the following permissions:
   - EC2 (create instances, security groups, key pairs)
   - VPC (create VPCs, subnets, internet gateways, NAT gateways)
   - RDS (create databases, subnet groups)
   - ELB (create load balancers)
   - IAM (create roles and policies for EC2 instances)

2. **AWS CLI** installed and configured:
   ```bash
   # Install AWS CLI
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   
   # Configure AWS CLI
   aws configure
   ```
   You'll need:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region (e.g., us-east-1)
   - Output format (json recommended)

3. **Terraform** installed (version 1.0 or later):
   ```bash
   # Download and install Terraform
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   
   # Verify installation
   terraform version
   ```

4. **Git** installed for cloning the repository:
   ```bash
   sudo apt update
   sudo apt install git -y
   ```

5. **SSH Client** for accessing the bastion host (usually pre-installed on Linux/Mac)

## Project Structure

```
.
├── main.tf                     # Main Terraform configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── bastion_userdata.tftpl      # User data script for bastion host
├── start_back.tftpl            # User data script for backend instances
├── start_front.tftpl           # User data script for frontend instances
├── modules/
│   ├── provider/               # Provider configuration
│   ├── network/                # VPC, subnets, routing
│   ├── bastion/                # Bastion host resources
│   ├── frontend/               # Frontend instances and load balancer
│   ├── backend/                # Backend instances and load balancer
│   └── database/               # RDS MySQL database
└── codigo/
    └── devops-rampup/          # Application source code
        ├── movie-analyst-api/  # Backend API application
        ├── movie-analyst-ui/   # Frontend web application
        ├── movie-analyst-db/   # Database schema
        └── movie-app-deploy/   # Ansible deployment playbooks
```

## Module Description

### Network Module
- Creates VPC with CIDR 192.168.0.0/24
- Sets up public and private subnets across two availability zones
- Configures Internet Gateway and NAT Gateway
- Establishes proper routing tables

### Bastion Module
- Deploys a bastion host in the public subnet
- Provides secure SSH access to private instances
- Creates security group allowing SSH access from the internet

### Frontend Module
- Deploys web server instances in private subnets
- Sets up Application Load Balancer for high availability
- Configures auto-scaling group for the frontend tier
- Installs and runs the Movie Analyst UI application

### Backend Module
- Deploys API server instances in private subnets
- Sets up Application Load Balancer for backend services
- Configures auto-scaling group for the backend tier
- Installs and runs the Movie Analyst API application

### Database Module
- Creates RDS MySQL instance in private subnets
- Sets up database subnet group
- Configures security group allowing access only from backend instances
- Initializes database with required schema

## Complete Deployment Guide

### Step 1: Environment Setup

1. **Verify Prerequisites**:
   ```bash
   # Check AWS CLI configuration
   aws sts get-caller-identity
   
   # Check Terraform installation
   terraform version
   
   # Verify AWS permissions (this should return your account details)
   aws ec2 describe-regions --region us-east-1
   ```

### Step 2: Clone and Configure

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Review the Project Structure**:
   ```bash
   # Explore the project
   tree . -I 'codigo|llaves|*.tfstate*'
   ```

3. **Configure Variables**:

Copy the example variables file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific configurations:

```hcl
# AWS Configuration
region = "us-east-1"

# Database Configuration (CHANGE THESE IN PRODUCTION!)
db_username = "movieapp_admin"
db_password = "YourSecurePassword123!"

# Optional: Add additional customizations
# instance_type = "t3.small"
# environment = "production"
```

**Important Security Note**: Never commit the `terraform.tfvars` file to version control as it contains sensitive information.

### Step 3: Optional Backend Configuration

For production environments, configure remote state storage:

1. **Create S3 Backend** (optional but recommended):
   ```bash
   # Create S3 bucket for state storage
   aws s3 mb s3://your-unique-terraform-state-bucket --region us-east-1
   
   # Create DynamoDB table for state locking
   aws dynamodb create-table \
     --table-name terraform-state-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
     --region us-east-1
   ```

2. **Enable Backend** (copy from backend.tf.example):
   ```bash
   cp backend.tf.example backend.tf
   # Edit backend.tf with your bucket name
   ```

### Step 4: Deploy Infrastructure

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```
   This downloads required providers and initializes the working directory.

2. **Validate Configuration**:
   ```bash
   terraform validate
   terraform fmt
   ```

3. **Plan the Deployment**:
   ```bash
   terraform plan -out=tfplan
   ```
   Review the planned changes carefully. This will show you exactly what resources will be created.

4. **Apply the Configuration**:
   ```bash
   terraform apply tfplan
   ```
   Or for interactive apply:
   ```bash
   terraform apply
   ```
   When prompted, type `yes` to confirm the deployment.

### Step 5: Verify Deployment

1. **Check Outputs**:
   ```bash
   terraform output
   ```

2. **Access the Application**:

After successful deployment, Terraform will output the load balancer DNS name:

   ```bash
   # Get the application URL
   echo "Application URL: http://$(terraform output -raw elb_dns)"
   
   # Test the application
   curl -I http://$(terraform output -raw elb_dns)
   ```

3. **SSH Access to Instances** (for troubleshooting):
   ```bash
   # Get bastion host IP
   BASTION_IP=$(aws ec2 describe-instances \
     --filters "Name=tag:Name,Values=*bastion*" "Name=instance-state-name,Values=running" \
     --query 'Reservations[0].Instances[0].PublicIpAddress' \
     --output text)
   
   # SSH to bastion (key will be generated during deployment)
   ssh -i ~/.ssh/bastion_key ec2-user@$BASTION_IP
   ```

### Step 6: Monitor and Validate

1. **Check Resource Status**:
   ```bash
   # Verify EC2 instances
   aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table
   
   # Check load balancer status
   aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,State.Code]' --output table
   
   # Verify RDS database
   aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]' --output table
   ```

2. **Application Health Check**:
   ```bash
   # Test frontend
   curl -f http://$(terraform output -raw elb_dns)/health || echo "Frontend health check failed"
   
   # Monitor logs (if needed)
   aws logs describe-log-groups --log-group-name-prefix "/aws/ec2"
   ```

## Environment Variables and Configuration

### Required Variables

The following variables must be configured in your `terraform.tfvars` file:

| Variable | Type | Description | Default | Required |
|----------|------|-------------|---------|----------|
| `region` | string | AWS region for deployment | `us-east-1` | No |
| `db_username` | string | Database username | `applicationuser` | No |
| `db_password` | string | Database password | `Change-Me-In-Production!` | Yes* |

*While db_password has a default, you MUST change it for any real deployment.

### Optional Customization Variables

You can add these to your `variables.tf` and `terraform.tfvars` for additional customization:

```hcl
# Instance configuration
variable "frontend_instance_type" {
  description = "Instance type for frontend servers"
  type        = string
  default     = "t3.micro"
}

variable "backend_instance_type" {
  description = "Instance type for backend servers"
  type        = string
  default     = "t3.micro"
}

# Database configuration
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

# Environment tagging
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "movie-analyst"
}
```

## Application Details

### Movie Analyst UI (Frontend)
- **Technology**: Node.js with Express and EJS templates
- **Port**: 3030
- **Features**: Web interface for browsing movies, authors, and publications

### Movie Analyst API (Backend)
- **Technology**: Node.js with Express
- **Database**: MySQL
- **Features**: RESTful API for movie data management

### Database Schema
The MySQL database includes tables for:
- Movies
- Authors
- Publications
- Relationships between entities

## Security Considerations

- All application instances are deployed in private subnets
- Database is isolated in private subnets with restricted access
- Bastion host provides secure SSH access to private instances
- Security groups follow the principle of least privilege
- Load balancers handle public internet traffic

- Check EC2 instance user data logs: `/var/log/cloud-init-output.log`
- Monitor application logs on instances
- Use AWS CloudWatch for infrastructure monitoring
- Enable VPC Flow Logs for network troubleshooting:
  ```bash
  # Enable VPC Flow Logs
  VPC_ID=$(terraform output -raw vpc_id)
  aws ec2 create-flow-logs --resource-type VPC --resource-ids $VPC_ID --traffic-type ALL --log-destination-type cloud-watch-logs --log-group-name VPCFlowLogs
  ```

## Development and Testing Environment

### Local Development Setup

1. **Development Tools**:
   ```bash
   # Install additional tools for development
   sudo apt install -y tree jq awscli
   
   # Install terraform-docs for documentation
   wget https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-linux-amd64.tar.gz
   tar -xzf terraform-docs-v0.16.0-linux-amd64.tar.gz
   sudo mv terraform-docs /usr/local/bin/
   ```

2. **Pre-commit Hooks** (recommended):
   ```bash
   # Install pre-commit
   pip install pre-commit
   
   # Create .pre-commit-config.yaml
   cat << 'EOF' > .pre-commit-config.yaml
   repos:
     - repo: https://github.com/antonbabenko/pre-commit-terraform
       rev: v1.83.5
       hooks:
         - id: terraform_fmt
         - id: terraform_validate
         - id: terraform_docs
   EOF
   
   # Install hooks
   pre-commit install
   ```

3. **Testing with Terratest** (advanced):
   ```bash
   # Install Go for Terratest
   wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
   sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
   export PATH=$PATH:/usr/local/go/bin
   ```

### Multi-Environment Setup

1. **Environment Structure**:
   ```bash
   mkdir -p environments/{dev,staging,prod}
   
   # Create environment-specific tfvars
   cat << 'EOF' > environments/dev/terraform.tfvars
   region = "us-east-1"
   environment = "dev"
   db_username = "devuser"
   db_password = "DevPassword123!"
   frontend_instance_type = "t3.nano"
   backend_instance_type = "t3.nano"
   EOF
   ```

2. **Deploy Multiple Environments**:
   ```bash
   # Deploy development environment
   terraform workspace new dev
   terraform apply -var-file=environments/dev/terraform.tfvars
   
   # Deploy staging environment
   terraform workspace new staging
   terraform apply -var-file=environments/staging/terraform.tfvars
   ```

### Automation and CI/CD Integration

1. **GitHub Actions Example** (`.github/workflows/terraform.yml`):
   ```yaml
   name: 'Terraform'
   
   on:
     push:
       branches: [ main ]
     pull_request:
       branches: [ main ]
   
   jobs:
     terraform:
       runs-on: ubuntu-latest
       
       steps:
       - uses: actions/checkout@v3
       
       - name: Setup Terraform
         uses: hashicorp/setup-terraform@v2
         with:
           terraform_version: 1.6.0
   
       - name: Terraform Format
         run: terraform fmt -check
   
       - name: Terraform Init
         run: terraform init
   
       - name: Terraform Validate
         run: terraform validate
   
       - name: Terraform Plan
         run: terraform plan
         env:
           AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
           AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
   ```

2. **Makefile for Common Operations**:
   ```makefile
   .PHONY: init plan apply destroy validate fmt clean
   
   init:
   	terraform init
   
   validate: init
   	terraform validate
   	terraform fmt -check
   
   plan: validate
   	terraform plan -out=tfplan
   
   apply: plan
   	terraform apply tfplan
   
   destroy:
   	terraform destroy -auto-approve
   
   fmt:
   	terraform fmt -recursive
   
   clean:
   	rm -rf .terraform/
   	rm -f tfplan
   	rm -f terraform.tfstate*
   ```

## Customization

### Modifying Instance Types
Update the instance types in the respective module variables:
- Frontend instances: `modules/frontend/variables.tf`
- Backend instances: `modules/backend/variables.tf`
- Database: `modules/database/variables.tf`

### Scaling Configuration
Adjust auto-scaling group settings in:
- `modules/frontend/main.tf`
- `modules/backend/main.tf`

### Network Configuration
Modify CIDR blocks and subnet configurations in:
- `modules/network/main.tf`

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## Troubleshooting

### Common Issues

1. **SSH Access**: Ensure the bastion host is running and accessible
2. **Application Not Loading**: Check security group rules and instance health
3. **Database Connection**: Verify RDS instance status and security group configurations

## Troubleshooting

### Common Issues and Solutions

1. **AWS Credentials Issues**:
   ```bash
   # Error: "Unable to locate credentials"
   # Solution: Configure AWS CLI
   aws configure
   
   # Verify credentials
   aws sts get-caller-identity
   ```

2. **Insufficient Permissions**:
   ```bash
   # Error: "User: arn:aws:iam::xxx is not authorized to perform: ec2:CreateVpc"
   # Solution: Ensure your IAM user has the required permissions
   ```

3. **Resource Limit Exceeded**:
   ```bash
   # Error: "VPC limit exceeded"
   # Solution: Check AWS service limits
   aws service-quotas get-service-quota --service-code vpc --quota-code L-F678F1CE
   ```

4. **Terraform State Issues**:
   ```bash
   # Error: "State lock acquired"
   # Solution: Force unlock (use carefully)
   terraform force-unlock LOCK_ID
   ```

5. **SSH Connection Issues**:
   ```bash
   # Error: "Permission denied (publickey)"
   # Solution: Check key permissions
   chmod 400 ~/.ssh/bastion_key
   ```

### Validation and Testing

1. **Infrastructure Health Check**:
   ```bash
   #!/bin/bash
   # Create a health check script
   
   echo "=== Infrastructure Health Check ==="
   
   # Check VPC
   VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=prod-vpc" --query 'Vpcs[0].VpcId' --output text)
   echo "VPC Status: $VPC_ID"
   
   # Check Instances
   aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[InstanceId,Tags[?Key==`Name`].Value|[0],State.Name]' --output table
   
   # Check Load Balancers
   aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,State.Code,DNSName]' --output table
   
   # Check RDS
   aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]' --output table
   ```

2. **Application Connectivity Test**:
   ```bash
   # Test application endpoints
   APP_URL=$(terraform output -raw elb_dns)
   
   # Test frontend
   curl -f http://$APP_URL || echo "Frontend unreachable"
   
   # Test backend health (if available)
   curl -f http://$APP_URL/api/health || echo "Backend health endpoint not available"
   ```

### Cost Estimation

**Monthly Cost Breakdown** (us-east-1 pricing):

| Resource | Type | Quantity | Monthly Cost (USD) |
|----------|------|----------|-------------------|
| EC2 Instances | t3.micro | 4-6 instances | $15-25 |
| RDS MySQL | db.t3.micro | 1 instance | $15 |
| NAT Gateway | Standard | 1 gateway | $45 |
| Application Load Balancer | ALB | 2 load balancers | $36 |
| EBS Storage | gp3 | ~50 GB | $5 |
| Data Transfer | Internet | Variable | $5-15 |
| **Total Estimated** | | | **$121-141/month** |

**Cost Optimization Tips**:

1. **Use Spot Instances** (for non-production):
   ```hcl
   # Add to instance configuration
   spot_price = "0.01"
   ```

2. **Schedule Resources** (for development):
   ```bash
   # Stop instances during off-hours
   aws ec2 stop-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Environment,Values=dev" --query 'Reservations[*].Instances[*].InstanceId' --output text)
   ```

3. **Use Smaller Instance Types**:
   ```hcl
   # In terraform.tfvars
   frontend_instance_type = "t3.nano"  # $3.80/month
   backend_instance_type = "t3.nano"   # $3.80/month
   db_instance_class = "db.t3.micro"   # $15/month
   ```

### Logs and Debugging

- Check EC2 instance user data logs: `/var/log/cloud-init-output.log`
- Monitor application logs on instances
- Use AWS CloudWatch for infrastructure monitoring

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the infrastructure changes
5. Submit a pull request

## License and Legal Information

### Infrastructure Code License

The Terraform infrastructure code in this repository (all files except the `codigo/` directory) is licensed under the MIT License - see the LICENSE file for details.

### Application Code Restrictions

**IMPORTANT**: The application source code located in the `codigo/` directory is **NOT** licensed under MIT and is **NOT** free to use, modify, or distribute. This code is included for reference and educational purposes only.

**Restrictions on `codigo/` directory**:
- The Movie Analyst application code (`codigo/devops-rampup/`) is proprietary
- You may NOT use, copy, modify, or distribute this application code
- The code is provided for learning and demonstration purposes only
- For production use, you must develop your own application or obtain proper licensing

### What You Can Use

✅ **You CAN freely use**:
- All Terraform infrastructure code
- Configuration templates
- Documentation and deployment scripts
- Architecture patterns and best practices

❌ **You CANNOT use**:
- Application source code in `codigo/devops-rampup/movie-analyst-api/`
- Application source code in `codigo/devops-rampup/movie-analyst-ui/`
- Database schemas in `codigo/devops-rampup/movie-analyst-db/`
- Any files within the `codigo/` directory

### For Your Own Projects

To use this infrastructure for your own applications:

1. **Keep the infrastructure code** - Use all Terraform modules and configurations
2. **Replace the application** - Develop your own application or use open-source alternatives
3. **Modify the user data scripts** - Update `start_back.tftpl` and `start_front.tftpl` to deploy your application
4. **Update the database schema** - Create your own database initialization scripts

### Alternative Applications

This infrastructure can be used with any three-tier web application. Consider these open-source alternatives:

- **MEAN/MERN Stack applications**
- **WordPress with MySQL**
- **Django applications**
- **Laravel applications**
- **Any Node.js + MySQL application**

## Support

For questions or issues, please open an issue in the GitHub repository or contact the infrastructure team.
