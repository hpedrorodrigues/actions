#!/bin/sh

set -o errexit
set -o nounset

if ${VERBOSE:-false}; then
  set -o xtrace
fi

readonly apko_image='ghcr.io/wolfi-dev/apko:latest'
readonly digest_file='digest.txt'

readonly github_workspace="${GITHUB_WORKSPACE:-}"

if [ -z "${INPUT_CONFIG:-}" ] || [ -z "${INPUT_TAG:-}" ]; then
  >&2 echo 'Config and tag are required!'
  exit 1
fi

commands='
  set -o errexit
  set -o pipefail
  set -o nounset

  echo "${REGISTRY_PASSWORD}" \
  | /usr/bin/apko login "${REGISTRY}" \
    --username "${REGISTRY_USERNAME}" \
    --password-stdin

  [ -n "${SOURCE_DATE}" ] && export SOURCE_DATE_EPOCH="${SOURCE_DATE}"

  /usr/bin/apko publish "${CONFIG}" ${TAG} \
    --annotations="${ANNOTATION}" \
    | tee "${DIGEST_FILE}"
'

docker run \
  --interactive \
  --rm \
  --entrypoint /bin/sh \
  --network host \
  --env "CONFIG=${INPUT_CONFIG}" \
  --env "TAG=${INPUT_TAG}" \
  --env "ANNOTATION=${INPUT_ANNOTATION}" \
  --env "SOURCE_DATE=${INPUT_SOURCE_DATE_EPOCH}" \
  --env "REGISTRY=${INPUT_REGISTRY}" \
  --env "REGISTRY_USERNAME=${INPUT_REGISTRY_USERNAME}" \
  --env "REGISTRY_PASSWORD=${INPUT_REGISTRY_PASSWORD}" \
  --env "DIGEST_FILE=${digest_file}" \
  --volume "${PWD}:${github_workspace}" \
  --volume '/tmp:/tmp' \
  --workdir "${github_workspace}" \
  "${apko_image}" -c "${commands}"

echo "digest=$(cat "${digest_file}")" >>"${GITHUB_OUTPUT}" && rm "${digest_file}"
