# Contributing to AWS Movie Analyst Infrastructure

Thank you for your interest in contributing to this project!

## Quick Start for Contributors

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes following the guidelines below
4. Test thoroughly in a development environment
5. Submit a pull request

## Development Guidelines

### Before You Start

- Install Terraform (version 1.0+)
- Configure AWS credentials
- Read the main [README.md](README.md) for project overview

### Code Standards

```bash
# Format code before committing
terraform fmt -recursive

# Validate configuration
terraform validate

# Test your changes
terraform plan -var-file=test.tfvars
```

### Variable Guidelines

When adding new variables to `variables.tf`:

```hcl
variable "example_var" {
  description = "Clear description of the variable purpose"
  type        = string
  default     = "sensible_default_value"
  sensitive   = true  # if contains sensitive data
  
  validation {
    condition     = length(var.example_var) > 0
    error_message = "Variable cannot be empty."
  }
}
```

### Security Requirements

- **Never commit secrets** - Use variables with `sensitive = true`
- **Test security groups** - Ensure they follow least privilege
- **Review IAM policies** - Grant minimum required permissions
- **Validate encryption** - Use encryption at rest and in transit

## Pull Request Process

### Before Submitting

- [ ] Code formatted with `terraform fmt`
- [ ] Configuration validated with `terraform validate`
- [ ] Tested deployment in development environment
- [ ] Documentation updated if needed
- [ ] No hardcoded credentials or secrets

### Pull Request Template

```markdown
## What Changed
Brief description of your changes

## Why
Explain the reason for this change

## Testing
- [ ] Local validation passed
- [ ] Deployment tested
- [ ] No breaking changes (or breaking changes documented)

## Security Impact
Describe any security implications
```

## Commit Message Format

Use conventional commits:

```
feat(module): add new security group rules
fix(database): correct subnet group configuration  
docs(readme): update deployment instructions
refactor(network): improve CIDR block organization
```

## Testing Your Changes

1. **Create test environment**:
   ```bash
   cp terraform.tfvars.example test.tfvars
   # Edit test.tfvars with test values
   ```

2. **Test deployment**:
   ```bash
   terraform workspace new test-$(date +%s)
   terraform plan -var-file=test.tfvars
   terraform apply -var-file=test.tfvars
   ```

3. **Clean up**:
   ```bash
   terraform destroy -var-file=test.tfvars
   terraform workspace select default
   terraform workspace delete test-$(date +%s)
   ```

## Reporting Issues

Include in your issue:
- Terraform version (`terraform version`)
- AWS region
- Error messages (remove sensitive data)
- Steps to reproduce

## License Note

Contributions to infrastructure code are under MIT License. The application code in `codigo/` directory has different licensing - do not modify those files.

## Getting Help

- Check [README.md](README.md) first
- Search existing issues
- Open a new issue for bugs or feature requests

Thank you for contributing!
