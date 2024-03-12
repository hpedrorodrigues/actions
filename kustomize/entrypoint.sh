#!/bin/sh

set -o nounset

if ${VERBOSE:-false}; then
  set -o xtrace
fi

readonly filter="${INPUT_FILTER:-}"
readonly path="${INPUT_PATH:-}"
readonly log_level="${INPUT_LOG_LEVEL:-}"
readonly flags="${INPUT_FLAGS:-}"

if [ "${log_level}" != 'quiet' ] && [ "${log_level}" != 'verbose' ]; then
  >&2 echo "Error: invalid value provided for log level: \"${log_level}\"."
  >&2 echo "Accepted values are \"verbose\" or \"quiet\"."
  exit 1
fi

case "${filter}" in
  none)
    readonly kustomization_directories="$(
      find . -type f \( -name kustomization.yml -o -name kustomization.yaml \) \
        | xargs -I {} dirname {}
    )"

    if [ -z "${kustomization_directories}" ]; then
      echo 'No kustomization directories found.'
      exit 0
    fi
    ;;
  modified)
    readonly kustomization_directories="$(
      git diff --diff-filter=d --name-only HEAD^ \
        | xargs -I {} dirname {} \
        | sort -u \
        | xargs -I {} sh -c 'find {} -maxdepth 1 \( -name kustomization.yml -o -name kustomization.yaml \) | grep -q . && echo {} || true'
    )"

    if [ -z "${kustomization_directories}" ]; then
      echo 'No relevant changes found.'
      exit 0
    fi
    ;;
  static)
    if [ -z "${path}" ]; then
      >&2 echo 'Error: `static` filter requires a value for input `path`.'
      exit 1
    fi

    readonly kustomization_directories="${path}"
    ;;
  *)
    >&2 echo "Error: invalid value provided for filter: \"${filter}\"."
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
  output="$(kustomize_wrapper build ${flags} "${kustomization_directory}")"

  if [ "${?}" -eq 0 ]; then
    echo "PASS: ${kustomization_directory}"
  else
    >&2 echo "FAIL: ${kustomization_directory}"
    >&2 echo "${output}"
    exit 1
  fi
done
