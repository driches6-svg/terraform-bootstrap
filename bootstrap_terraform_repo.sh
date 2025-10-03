#!/usr/bin/env bash
set -euo pipefail

# bootstrap_terraform_repo.sh
# Run this from the root of a freshly checked-out GitHub repo.
# It creates a minimal Terraform scaffold + pre-commit + CI workflow.

# Colours
green() { printf "\033[0;32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[0;33m%s\033[0m\n" "$*"; }

# 1) Create terraform dir and starter files
mkdir -p terraform

cat > terraform/versions.tf <<'EOF'
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
EOF

# Keep placeholders minimal but present so validate/linters have files to scan
: > terraform/main.tf
: > terraform/variables.tf
: > terraform/outputs.tf

# 2) pre-commit config (lint/format/validate/tflint + basic hygiene)
cat > .pre-commit-config.yaml <<'EOF'
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.90.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint

  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
EOF

# 3) GitHub Actions workflow to run on push/PR
mkdir -p .github/workflows

cat > .github/workflows/terraform-lint.yml <<'EOF'
name: Terraform Lint

on:
  push:
    branches: ["**"]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "~> 1.6"

      - name: Setup TFLint
        uses: terraform-linters/setup-tflint@v4

      - name: Init (no backend)
        working-directory: terraform
        run: terraform init -backend=false

      - name: Format check
        run: terraform fmt -check -recursive

      - name: Validate
        working-directory: terraform
        run: terraform validate

      - name: TFLint
        working-directory: terraform
        run: tflint -f compact
EOF

# 4) Sensible .gitignore for Terraform
cat > .gitignore <<'EOF'
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash logs
crash.log
crash.*.log

# Override files (user-specific)
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Variable files with secrets (opt-in commit if you want)
*.auto.tfvars
*.tfvars

# Local env files
.env
.env.*

# Terraform plan files
*.plan

# macOS & editors
.DS_Store
.idea/
.vscode/
*.swp
EOF

# 5) README (brief guidance)
cat > README.md <<'EOF'
REPLACED_BY_DOWNLOADABLE_README
EOF

yellow "Installing pre-commit hooks (if available) ..."
if command -v pre-commit >/dev/null 2>&1; then
  pre-commit install
  green "pre-commit installed for this repo."
else
  yellow "pre-commit not found; skip install. Install from https://pre-commit.com/#install"
fi

green "Done. Created terraform scaffold, pre-commit config, CI workflow, and .gitignore."
green "Next steps:"
echo "  1) Review terraform/versions.tf and adjust provider versions."
echo "  2) Install pre-commit and run: pre-commit run --all-files"
echo "  3) Push to GitHub to exercise CI."
