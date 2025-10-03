# Terraform Repo Bootstrap

This repository is initialised with a minimal, opinionated scaffold for Terraform projects. It standardises local linting/formatting with **pre-commit** and runs the same checks in **GitHub Actions** on every push and pull request.

## What you get

- `terraform/` directory with starter files:
  - `versions.tf` (Terraform + provider constraints so linters have context)
  - `main.tf`, `variables.tf`, `outputs.tf` (placeholders)
- `.pre-commit-config.yaml` that runs:
  - `terraform_fmt`, `terraform_validate`, and `tflint`
  - plus general hygiene hooks (`trailing-whitespace`, `end-of-file-fixer`, `check-yaml`)
- `.github/workflows/terraform-lint.yml` CI workflow to mirror local checks
- Sensible `.gitignore` for Terraform repos

## Local setup

1. Install prerequisites:
   - Terraform >= 1.6
   - [pre-commit](https://pre-commit.com/#install)
   - [tflint](https://github.com/terraform-linters/tflint) (optional locally; CI installs it)
2. Activate the hooks:
   ```bash
   pre-commit install
   pre-commit run --all-files
   ```

## CI

The workflow in `.github/workflows/terraform-lint.yml` runs on `push` and `pull_request`. It performs:
- `terraform init -backend=false` in the `terraform/` directory
- `terraform fmt -check -recursive`
- `terraform validate`
- `tflint`

## Customising

- Update `terraform/versions.tf` to pin your preferred provider versions.
- If you add modules/providers, ensure CI can `init` without backend auth (keep `-backend=false` for lint jobs).
- If you want `terraform-docs`, add the hook, but remember terraform-docs needs to be available in CI and locally.

## Why this exists

Bootstrapping small infra repos repeatedly is tedious. This script + scaffold gives you a "good defaults" starting point that:
- enforces consistent formatting,
- catches obvious mistakes early, and
- keeps local and CI behaviour aligned.

---

© 2025 XRF Digital – MIT licensed. Feel free to copy/adapt.
