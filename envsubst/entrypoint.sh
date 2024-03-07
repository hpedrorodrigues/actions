#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

IFS=' ' read -r -a template <<<"${INPUT_TEMPLATE}"
IFS=' ' read -r -a result <<<"${INPUT_RESULT}"

if [ "${#template[@]}" -ne "${#result[@]}" ]; then
  echo >&2 'Error: `template` and `result` must have the same number of items.'
  echo >&2 "Got: template items=${#template[@]}, result items=${#result[@]}"
  exit 1
fi

for i in "${!template[@]}"; do
  template_file="${template[i]}"
  result_file="${result[i]}"

  echo "Processing \"${template_file}\" -> \"${result_file}\""
  envsubst <"${template_file}" >"${result_file}"
done
