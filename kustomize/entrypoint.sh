#!/bin/sh

set -o nounset

if ${VERBOSE:-false}; then
  set -o xtrace
fi

readonly detection="${INPUT_DETECTION:-}"
readonly path="${INPUT_PATH:-}"
readonly log_level="${INPUT_LOG_LEVEL:-}"

if [ "${log_level}" != 'quiet' ] && [ "${log_level}" != 'verbose' ]; then
  >&2 echo "Error: invalid value provided for log level: \"${log_level}\"."
  >&2 echo "Accepted values are \"verbose\" or \"quiet\"."
  exit 1
fi

case "${detection}" in
  all)
    readonly kustomization_directories="$(
      find . -type f \( -name kustomization.yml -o -name kustomization.yaml \) \
        | xargs -I {} dirname {}
    )"
    ;;
  git-diff)
    readonly kustomization_directories="$(
      git diff --diff-filter=d --name-only ${GITHUB_BASE_REF}...${GITHUB_HEAD_REF} \
        | xargs -I {} dirname {} \
        | sort -u \
        | xargs -I {} sh -c 'find {} -maxdepth 1 \( -name kustomization.yml -o -name kustomization.yaml \) | grep -q . && echo {} || true'
    )"
    ;;
  static)
    if [ -z "${path}" ]; then
      >&2 echo 'Error: `static` detection requires a value for input `path`.'
      exit 1
    fi

    readonly kustomization_directories="${path}"
    ;;
  *)
    >&2 echo "Error: invalid value provided for detection: \"${detection}\"."
    exit 1
    ;;
esac

kustomize_wrapper() {
  if [ "${log_level}" = 'quiet' ]; then
    2>&1 >/dev/null kustomize ${@}
  else
    2>&1 kustomize ${@}
  fi
}

for kustomization_directory in ${kustomization_directories}; do
  echo "LOOK: ${kustomization_directory}"
  output="$(kustomize_wrapper build "${kustomization_directory}")"

  if [ "${?}" -eq 0 ]; then
    echo "PASS: ${kustomization_directory}"
  else
    >&2 echo "FAIL: ${kustomization_directory}"
    >&2 echo "${output}"
    exit 1
  fi
done
