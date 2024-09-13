#!/bin/bash

set -o errexit
set -o nounset

if ${INPUT_DEBUG:-false}; then
  set -o xtrace
fi

if [ -z "${INPUT_RUN:-}" ]; then
  echo 'No script provided!' >&2
  exit 1
fi

eval "${INPUT_RUN}"
