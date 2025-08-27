#!/bin/sh

set -o errexit
set -o nounset

if ${INPUT_DEBUG:-false}; then
  set -o xtrace
fi

echo 'Checking Terraform files...'
terraform fmt -check -recursive

echo 'Checking OpenTofu files...'
tofu fmt -check -recursive

echo 'Checking Terragrunt files...'
terragrunt hcl fmt -check
