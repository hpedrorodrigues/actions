#!/bin/sh

set -o errexit
set -o nounset

if ${VERBOSE:-false}; then
  set -o xtrace
fi

readonly input="${INPUT_INPUT:-}"
readonly output="${INPUT_OUTPUT:-}"
readonly in_place=${INPUT_IN_PLACE:-false}
readonly format="${INPUT_FORMAT:-}"

if [ -n "${output}" ] && ${in_place}; then
  echo >&2 'Error: `output` and `in_place` are mutually exclusive and cannot be used together.'
  exit 1
fi

input_size=0
for item in ${input}; do
  eval input_item_${input_size}="${item}"
  input_size=$((input_size + 1))
done

output_size=0
for item in ${output}; do
  eval output_item_${output_size}="${item}"
  output_size=$((output_size + 1))
done

if [ -n "${output}" ] && [ "${input_size}" -ne "${output_size}" ]; then
  echo >&2 'Error: `input` and `output` must have the same number of items.'
  echo >&2 "Got: input items=${input_size}, output items=${output_size}."
  exit 1
fi

envsubst_wrapper() {
  if [ -n "${format}" ]; then
    envsubst "${format}"
  else
    envsubst
  fi
}

for i in $(seq '0' "$((input_size - 1))"); do
  input_item="$(eval echo "\$input_item_${i}")"

  if ${in_place}; then
    echo "Processing \"${input_item}\" (in-place)"
    content=$(cat "${input_item}")
    echo "${content}" | envsubst_wrapper >"${input_item}"
  elif [ -z "${output}" ]; then
    echo "Processing \"${input_item}\" (stdout)"
    envsubst_wrapper <"${input_item}"
  else
    output_item="$(eval echo "\$output_item_${i}")"
    echo "Processing \"${input_item}\" -> \"${output_item}\""
    envsubst_wrapper <"${input_item}" >"${output_item}"
  fi
done
