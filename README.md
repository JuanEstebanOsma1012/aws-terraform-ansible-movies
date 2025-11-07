# AWS Infrastructure for Movie Analyst Application

This repository contains Terraform infrastructure code to deploy a three-tier web application on AWS. The infrastructure includes a web frontend, API backend, and MySQL database with proper security groups and load balancing.

## Architecture Overview

The infrastructure deploys the following AWS resources:

- **VPC** with public and private subnets across multiple availability zones
- **Classic Load Balancer (ELB)** for frontend and backend services
- **EC2 instances** for frontend (Node.js UI) and backend (Node.js API) 
- **RDS MySQL database** for data persistence
- **Bastion host** for secure SSH access to private instances
- **Security groups** with proper network access controls
- **Internet Gateway** and **NAT Gateway** for networking

## Prerequisites

Before deploying this infrastructure, you need:

1. **AWS Account** with programmatic access
2. **AWS credentials** configured (via AWS CLI, environment variables, or IAM role)
3. **Terraform** installed (version 1.0 or later)

### Installing Terraform

```bash
# Download Terraform (adjust version as needed)
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

### AWS Credentials Setup

Configure AWS credentials using one of these methods:

```bash
# Option 1: AWS CLI
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

## Project Structure

```
.
├── main.tf                     # Main Terraform configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── terraform.tfvars.example    # Variables template
├── backend.tf.example          # S3 backend configuration example
├── bastion_userdata.tftpl      # User data script for bastion host
├── start_back.tftpl            # User data script for backend instances
├── start_front.tftpl           # User data script for frontend instances
└── modules/
    ├── provider/               # Provider configuration
    ├── network/                # VPC, subnets, routing
    ├── bastion/                # Bastion host resources
    ├── frontend/               # Frontend instances and ELB
    ├── backend/                # Backend instances and ELB
    └── database/               # RDS MySQL database
```

## Configuration

### Required Variables

Create a `terraform.tfvars` file with your specific configurations:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit the `terraform.tfvars` file:

```hcl
# AWS region
region = "us-east-1"

# Database credentials (CHANGE THESE!)
db_username = "your_db_user"
db_password = "YourSecurePassword123!"
```

### Available Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `region` | string | AWS region for deployment | `us-east-1` |
| `db_username` | string | Database username | `applicationuser` |
| `db_password` | string | Database password | `your-secure-password-here` |

**Note**: All variables have defaults in `variables.tf`. You only need to set values in `terraform.tfvars` for variables you want to override.

**Security Note**: Never commit `terraform.tfvars` to version control.

## Deployment Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/JuanEstebanOsma1012/aws-terraform-ansible-movies.git
cd aws-terraform-ansible-movies
```

### 2. Configure Variables

```bash
# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan the deployment
terraform plan

# Apply the infrastructure
terraform apply
```

When prompted, type `yes` to confirm the deployment.

### 4. Access Your Application

After deployment, get the application URL:

```bash
# Get the load balancer DNS
terraform output elb_dns

# Test the application
curl http://$(terraform output -raw elb_dns)
```

## Terraform Commands Reference

### Basic Operations

```bash
# Initialize working directory
terraform init

# Format configuration files
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# List resources in state
terraform state list

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Advanced Operations

```bash
# Plan with specific variables file
terraform plan -var-file="custom.tfvars"

# Apply without interactive approval
terraform apply -auto-approve

# Target specific resource
terraform plan -target=module.database

# Refresh state
terraform refresh

# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0

# Show outputs
terraform output
terraform output -json
```

## AWS Resources Created

This Terraform configuration creates the following AWS resources:

### Network Infrastructure
- **1 VPC** with CIDR 192.168.0.0/24
- **2 Public subnets** (192.168.0.0/26, 192.168.0.64/26)
- **2 Private subnets** (192.168.0.128/26, 192.168.0.192/26)
- **1 Internet Gateway**
- **1 NAT Gateway**
- **Route tables** for public and private subnets

### Compute Resources
- **1 Bastion host** (t3.micro) in public subnet
- **Frontend instances** (t3.micro) in private subnets
- **Backend instances** (t3.micro) in private subnets

### Load Balancing
- **2 Classic Load Balancers (ELB)**
  - Frontend ELB (internet-facing)
  - Backend ELB (internal)

### Database
- **1 RDS MySQL instance** (db.t3.micro) in private subnets
- **Database subnet group** spanning multiple AZs

### Security
- **Security groups** for each tier with appropriate rules
- **SSH key pair** for instance access

## Cleanup

To destroy all infrastructure:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

**Warning**: This will permanently delete all resources and data.

## Troubleshooting

### Common Issues

1. **Authentication Error**:
   ```bash
   # Error: "No valid credential sources found"
   # Solution: Configure AWS credentials
   aws configure
   ```

2. **Permission Denied**:
   ```bash
   # Error: "User is not authorized to perform action"
   # Solution: Ensure your AWS user has necessary permissions
   ```

3. **Resource Already Exists**:
   ```bash
   # Error: "VPC already exists"
   # Solution: Check for existing resources or use different region
   ```

4. **State Lock**:
   ```bash
   # Error: "Error locking state"
   # Solution: Force unlock (use carefully)
   terraform force-unlock LOCK_ID
   ```

### Debugging Tips

- Check Terraform logs: `TF_LOG=DEBUG terraform apply`
- Validate configuration: `terraform validate`
- Check AWS Console for resource status
- Review CloudTrail for API call errors

## License and Legal Information

### Infrastructure Code
The Terraform infrastructure code is licensed under the MIT License.

### Application Code Restrictions
**IMPORTANT**: The application source code in the `codigo/` directory is **NOT** licensed under MIT and is **NOT** free to use, modify, or distribute.

**What you CAN use**:
- All Terraform infrastructure code
- Configuration templates and documentation

**What you CANNOT use**:
- Application source code in `codigo/devops-rampup/`
- Database schemas and seeds

For your own projects, replace the application code with your own or use open-source alternatives.

## Support

For issues related to this infrastructure code, please open an issue in the GitHub repository.
