#!/bin/bash

set -o errexit
set -o nounset

if ${VERBOSE:-false}; then
  set -o xtrace
fi

if [ -z "${INPUT_SCRIPT:-}" ]; then
  echo 'No script provided!' >&2
  exit 1
fi

eval "${INPUT_SCRIPT}"
