#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

envsubst < "${INPUT_TEMPLATE_FILE}" > "${INPUT_RESULT_FILE}"
