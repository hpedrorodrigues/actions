#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

if [ "${INPUT_TEMPLATE_FILE}" = "${INPUT_RESULT_FILE}" ]; then
  echo 'Error: template file and result file cannot be the same.' >&2
  exit 1
fi

envsubst < "${INPUT_TEMPLATE_FILE}" > "${INPUT_RESULT_FILE}"
