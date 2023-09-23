# Makefile for Terraform
.PHONY: init plan apply destroy state-list fmt

TERRAFORM_DIR ?= terraform

init:
	@terraform -chdir=$(TERRAFORM_DIR) init -backend-config=backend.conf -reconfigure

plan:
	@terraform -chdir=$(TERRAFORM_DIR) plan -var-file=terraform.tfvars

apply:
	@terraform -chdir=$(TERRAFORM_DIR) apply -var-file=terraform.tfvars

state-list:
	@terraform -chdir=$(TERRAFORM_DIR) state list

destroy:
	@terraform -chdir=$(TERRAFORM_DIR) destroy

fmt:
	@find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -exec terraform fmt {} \;
