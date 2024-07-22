#!/bin/sh

set -o errexit
set -o nounset

if ${VERBOSE:-false}; then
  set -o xtrace
fi

terraform fmt -check -diff \
  && tofu fmt -check -diff \
  && terragrunt hclfmt --terragrunt-check --terragrunt-diff
