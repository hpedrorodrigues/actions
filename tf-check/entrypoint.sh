#!/bin/sh

set -o errexit
set -o nounset

if ${VERBOSE:-false}; then
  set -o xtrace
fi

terraform fmt -check -recursive \
  && tofu fmt -check -recursive \
  && terragrunt hclfmt --terragrunt-check
