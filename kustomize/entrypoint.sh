#!/bin/sh

set -o errexit
set -o nounset

if ${VERBOSE:-false}; then
  set -o xtrace
fi

readonly detection="${INPUT_DETECTION:-}"

if [ "${detection}" = 'all' ]; then
  readonly kustomization_directories="$(
    find . -type f \( -name kustomization.yml -o -name kustomization.yaml \) \
      | xargs -I {} dirname {}
  )"
else
  echo >&2 "Error: invalid value provided for detection: \"${detection}\"."
  exit 1
fi

for kustomization_directory in ${kustomization_directories}; do
  echo "Checking directory: ${kustomization_directory}"
  kustomize build "${kustomization_directory}"
done
