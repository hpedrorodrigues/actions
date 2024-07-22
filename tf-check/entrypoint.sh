#!/bin/sh

set -o errexit
set -o nounset

if ${VERBOSE:-false}; then
  set -o xtrace
fi

terraform fmt -check -diff -recursive \
  && tofu fmt -check -diff -recursive \
  && terragrunt hclfmt --terragrunt-check --terragrunt-diff
