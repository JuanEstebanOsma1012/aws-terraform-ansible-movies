# Makefile for Terraform Infrastructure Management
# This file provides convenient commands for common Terraform operations

.PHONY: help init validate plan apply destroy clean fmt docs test

# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform working directory
	@echo "🚀 Initializing Terraform..."
	terraform init
	@echo "✅ Terraform initialized successfully"

validate: init ## Validate Terraform configuration
	@echo "🔍 Validating Terraform configuration..."
	terraform validate
	terraform fmt -check -recursive
	@echo "✅ Terraform configuration is valid"

plan: validate ## Create and show an execution plan
	@echo "📋 Creating Terraform execution plan..."
	terraform plan -out=tfplan
	@echo "✅ Terraform plan created successfully"

apply: plan ## Apply the Terraform configuration
	@echo "🚀 Applying Terraform configuration..."
	terraform apply tfplan
	@echo "✅ Terraform applied successfully"

destroy: ## Destroy Terraform-managed infrastructure
	@echo "⚠️  WARNING: This will destroy all infrastructure!"
	@echo "Press Ctrl+C to cancel, or wait 10 seconds to continue..."
	@sleep 10
	terraform destroy
	@echo "✅ Infrastructure destroyed"

clean: ## Clean up temporary files and caches
	@echo "🧹 Cleaning up temporary files..."
	rm -rf .terraform/
	rm -f tfplan tfplan.*
	rm -f terraform.tfstate.backup
	rm -f crash.log crash.*.log
	@echo "✅ Cleanup completed"

fmt: ## Format Terraform configuration files
	@echo "🎨 Formatting Terraform files..."
	terraform fmt -recursive
	@echo "✅ Terraform files formatted"

docs: ## Generate documentation
	@echo "📚 Generating documentation..."
	terraform-docs markdown table --output-file README.md .
	@echo "✅ Documentation generated"

test: validate ## Run basic tests
	@echo "🧪 Running basic tests..."
	@echo "Checking for hardcoded secrets..."
	@if grep -r "password\s*=\s*\"" --include="*.tf" .; then \
		echo "❌ Found hardcoded passwords in Terraform files"; \
		exit 1; \
	fi
	@echo "Checking for proper tagging..."
	@if ! grep -r "tags\s*=" --include="*.tf" modules/; then \
		echo "⚠️  Warning: Some resources may be missing tags"; \
	fi
	@echo "✅ Basic tests completed"

cost: plan ## Estimate infrastructure costs (requires infracost)
	@echo "💰 Estimating infrastructure costs..."
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path tfplan; \
	else \
		echo "ℹ️  Install infracost for cost estimation: https://www.infracost.io/docs/"; \
	fi

security: ## Run security checks (requires tfsec)
	@echo "🔒 Running security checks..."
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec .; \
	else \
		echo "ℹ️  Install tfsec for security scanning: https://aquasecurity.github.io/tfsec/"; \
	fi

setup-dev: ## Setup development environment
	@echo "🛠️  Setting up development environment..."
	@echo "Installing pre-commit hooks..."
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		echo "✅ Pre-commit hooks installed"; \
	else \
		echo "⚠️  Please install pre-commit: pip install pre-commit"; \
	fi

workspace-list: ## List all Terraform workspaces
	@echo "📋 Terraform workspaces:"
	terraform workspace list

workspace-new: ## Create a new workspace (usage: make workspace-new WORKSPACE=name)
	@if [ -z "$(WORKSPACE)" ]; then \
		echo "❌ Please specify WORKSPACE name: make workspace-new WORKSPACE=dev"; \
		exit 1; \
	fi
	terraform workspace new $(WORKSPACE)
	@echo "✅ Workspace $(WORKSPACE) created"

workspace-switch: ## Switch to a workspace (usage: make workspace-switch WORKSPACE=name)
	@if [ -z "$(WORKSPACE)" ]; then \
		echo "❌ Please specify WORKSPACE name: make workspace-switch WORKSPACE=dev"; \
		exit 1; \
	fi
	terraform workspace select $(WORKSPACE)
	@echo "✅ Switched to workspace $(WORKSPACE)"

status: ## Show current infrastructure status
	@echo "📊 Infrastructure Status:"
	@echo "Current workspace: $$(terraform workspace show)"
	@echo "State location: $$(terraform state pull 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || echo 'No state found')"
	@echo ""
	@echo "AWS Resources (if deployed):"
	@if terraform state list >/dev/null 2>&1; then \
		echo "Total resources: $$(terraform state list | wc -l)"; \
		terraform state list | head -10; \
		if [ $$(terraform state list | wc -l) -gt 10 ]; then \
			echo "... and $$(($$(terraform state list | wc -l) - 10)) more"; \
		fi \
	else \
		echo "No resources deployed"; \
	fi

# Environment-specific targets
dev: workspace-switch WORKSPACE=dev ## Switch to development workspace
	@echo "🔄 Switched to development environment"

staging: workspace-switch WORKSPACE=staging ## Switch to staging workspace
	@echo "🔄 Switched to staging environment"

prod: workspace-switch WORKSPACE=prod ## Switch to production workspace
	@echo "🔄 Switched to production environment"
