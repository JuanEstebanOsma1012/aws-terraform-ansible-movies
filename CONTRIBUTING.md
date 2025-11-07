# Contributing to AWS Movie Analyst Infrastructure

Thank you for your interest in contributing to this project! This document provides comprehensive guidelines and information for contributors.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code. We are committed to providing a welcoming and inspiring community for all.

## How to Contribute

### Reporting Issues

Before creating an issue, please:

1. **Search existing issues** to avoid duplicates
2. **Use the issue template** when available
3. **Provide detailed information** including:
   - Terraform version (`terraform version`)
   - AWS region and account type
   - Error messages (with sensitive data removed)
   - Steps to reproduce the issue
   - Expected vs actual behavior

### Submitting Changes

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/project-name.git
   cd project-name
   ```
3. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes** following the guidelines below
5. **Test your changes** thoroughly in a test environment
6. **Commit with descriptive messages** following conventional commits
7. **Push to your fork** and create a pull request

## Development Guidelines

### Terraform Best Practices

1. **Code Formatting**:
   ```bash
   # Format all Terraform files
   terraform fmt -recursive
   
   # Check formatting
   terraform fmt -check -recursive
   ```

2. **Code Validation**:
   ```bash
   # Initialize and validate
   terraform init
   terraform validate
   
   # Security scanning (optional)
   tfsec .
   ```

3. **Documentation**:
   ```bash
   # Generate module documentation
   terraform-docs markdown table --output-file README.md .
   ```

### Module Structure Guidelines

```
modules/
└── module-name/
    ├── main.tf          # Main resource definitions
    ├── variables.tf     # Input variables
    ├── outputs.tf       # Output values
    ├── versions.tf      # Provider version constraints
    └── README.md        # Module documentation
```

### Variable Guidelines

```hcl
variable "example_var" {
  description = "Clear, concise description of the variable purpose and usage"
  type        = string
  default     = "sensible_default_value"
  
  validation {
    condition     = length(var.example_var) > 0 && length(var.example_var) <= 64
    error_message = "Variable must be between 1 and 64 characters."
  }
}
```

### Security Guidelines

1. **No hardcoded secrets** - Use variables with `sensitive = true`
2. **Principle of least privilege** - Grant minimum required permissions
3. **Enable encryption** - Use encryption at rest and in transit
4. **Resource tagging** - Tag all resources for security and cost tracking
5. **Network security** - Use security groups and NACLs appropriately

### Testing Requirements

1. **Pre-deployment Testing**:
   ```bash
   # Validate syntax and formatting
   make validate
   
   # Generate execution plan
   terraform plan -var-file=test.tfvars -out=tfplan
   
   # Review plan output carefully
   terraform show tfplan
   ```

2. **Integration Testing**:
   ```bash
   # Create test workspace
   terraform workspace new test-$(date +%s)
   
   # Deploy to test environment
   terraform apply -var-file=test.tfvars
   
   # Run validation tests
   ./scripts/validate-infrastructure.sh
   
   # Clean up test resources
   terraform destroy -auto-approve
   terraform workspace select default
   terraform workspace delete test-$(date +%s)
   ```

3. **Cost Impact Testing**:
   ```bash
   # Estimate costs before deployment
   terraform plan -out=tfplan
   infracost breakdown --path tfplan
   ```

## Pull Request Process

### Before Submitting

1. **Update documentation** if your changes affect user-facing functionality
2. **Add or update tests** for new features or bug fixes
3. **Ensure all checks pass** locally before pushing
4. **Keep commits atomic** - one logical change per commit
5. **Write descriptive commit messages**

### Pull Request Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review of code completed
- [ ] Tests added for new functionality
- [ ] Documentation updated
- [ ] No hardcoded secrets or credentials
- [ ] All CI/CD checks passing
- [ ] Breaking changes documented

### Pull Request Template

```markdown
## Description
Brief description of the changes and why they're needed.

## Type of Change
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update

## Testing
- [ ] Local testing completed
- [ ] Integration tests pass
- [ ] Cost impact assessed
- [ ] Security implications reviewed

## Screenshots/Outputs
If applicable, add screenshots or terraform outputs to help explain your changes.

## Deployment Notes
Special instructions for deploying these changes (if any).
```

## Commit Message Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(database): add encryption at rest for RDS instances

fix(network): correct security group rules for bastion host

docs(readme): update deployment instructions with new variables

refactor(modules): restructure network module for better maintainability
```

## Release Process

1. **Version Tagging**:
   ```bash
   # Create and push tags
   git tag -a v1.0.0 -m "Release version 1.0.0: Add support for multiple environments"
   git push origin v1.0.0
   ```

2. **Release Notes**: Include in each release:
   - 🎉 New features
   - 🐛 Bug fixes
   - 💥 Breaking changes
   - 🔧 Migration guide (if needed)
   - ⚠️ Known issues

## Environment Setup

### Development Environment

```bash
# Install required tools
sudo apt update
sudo apt install -y make jq tree

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install additional tools
pip install pre-commit
go install github.com/terraform-docs/terraform-docs@latest
go install github.com/aquasecurity/tfsec/cmd/tfsec@latest
```

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tfsec
```

## Getting Help

- 📖 **Documentation**: Check the README.md and module documentation first
- 🐛 **Issues**: Search existing issues or create a new one
- 💬 **Discussions**: Use GitHub Discussions for questions and ideas
- 🔒 **Security**: Email maintainers for security-related issues
- 💡 **Feature Requests**: Open an issue with the "enhancement" label

## Recognition

Contributors will be recognized in:
- 📋 CONTRIBUTORS.md file
- 📝 Release notes
- 📚 Project documentation
- 🏆 Annual contributor highlights

## License Note

Remember that contributions to the infrastructure code are under MIT License, but the application code in `codigo/` directory has different licensing terms. Only contribute to the infrastructure components.

Thank you for contributing to this project! Your efforts help make infrastructure deployment easier and more reliable for everyone. 🚀

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Create a new branch for your feature or bug fix
4. Make your changes
5. Test your changes thoroughly
6. Submit a pull request

## Development Guidelines

### Terraform Best Practices

- Follow Terraform naming conventions
- Use meaningful resource names and descriptions
- Add comments for complex configurations
- Use variables for configurable values
- Avoid hardcoding sensitive information
- Test changes in a separate environment before submitting

### Code Structure

- Keep modules focused and single-purpose
- Use consistent formatting (run `terraform fmt`)
- Validate configurations (run `terraform validate`)
- Update documentation when making changes

### Testing

Before submitting a pull request:

1. Run `terraform fmt` to format your code
2. Run `terraform validate` to check syntax
3. Run `terraform plan` to verify changes
4. Test deployment in a development environment
5. Update documentation if needed

### Documentation

- Update README.md for significant changes
- Add inline comments for complex logic
- Update variable descriptions
- Document any new outputs

### Security

- Never commit sensitive information (credentials, keys, etc.)
- Use variables for configurable secrets
- Follow AWS security best practices
- Review security group rules carefully

## Submitting Changes

### Pull Request Process

1. Ensure your branch is up to date with the main branch
2. Provide a clear description of the changes
3. Reference any related issues
4. Include testing information
5. Update documentation as needed

### Pull Request Template

Please include the following information in your pull request:

- **Description**: What changes are you making and why?
- **Testing**: How have you tested these changes?
- **Documentation**: Have you updated relevant documentation?
- **Security**: Are there any security implications?

## Reporting Issues

When reporting issues, please include:

- Clear description of the problem
- Steps to reproduce the issue
- Expected vs actual behavior
- Terraform version and provider versions
- Error messages and logs
- Environment details (AWS region, etc.)

## Questions

If you have questions about contributing, please open an issue or contact the maintainers.

Thank you for contributing!
