#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

set -x

template_size=0
for item in ${INPUT_TEMPLATE}; do
  eval template_item_${template_size}="${item}"
  template_size=$((template_size + 1))
done

result_size=0
for item in ${INPUT_RESULT}; do
  eval result_item_${result_size}="${item}"
  result_size=$((result_size + 1))
done

if [ "${template_size}" -ne "${result_size}" ]; then
  echo >&2 'Error: `template` and `result` must have the same number of items.'
  echo >&2 "Got: template items=${template_size}, result items=${result_size}"
  exit 1
fi

for i in $(seq '0' "$((template_size - 1))"); do
  template_item="$(eval echo "\$template_item_${i}")"
  result_item="$(eval echo "\$result_item_${i}")"

  echo "Processing \"${template_item}\" -> \"${result_item}\""
  envsubst <"${template_item}" >"${result_item}"
done
