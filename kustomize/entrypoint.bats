#!/usr/bin/env bats

setup() {
  export SIMPLE="${BATS_TEST_DIRNAME}/../.github/extra/kustomize/simple"
  export VARIANT_DEV="${BATS_TEST_DIRNAME}/../.github/extra/kustomize/variants/dev"
  export VARIANT_STG="${BATS_TEST_DIRNAME}/../.github/extra/kustomize/variants/stg"
  export VARIANT_PRD="${BATS_TEST_DIRNAME}/../.github/extra/kustomize/variants/prd"

  cd "${BATS_TEST_DIRNAME}/.." || exit 1
}

main() {
  sh "${BATS_TEST_DIRNAME}/entrypoint.sh"
}

@test 'Should validate all kustomization files when filter is set to none' {
  export INPUT_FILTER='none'
  export INPUT_PATH=''
  export INPUT_LOG_LEVEL='quiet'

  run main
  [ "${status}" -eq 0 ]
  [[ "${output}" == *'LOOK: ./.github/extra/kustomize/variants'* ]]
  [[ "${output}" == *'PASS: ./.github/extra/kustomize/variants'* ]]
  [[ "${output}" == *'LOOK: ./.github/extra/kustomize/variants/prd'* ]]
  [[ "${output}" == *'PASS: ./.github/extra/kustomize/variants/prd'* ]]
  [[ "${output}" == *'LOOK: ./.github/extra/kustomize/variants/dev'* ]]
  [[ "${output}" == *'PASS: ./.github/extra/kustomize/variants/dev'* ]]
  [[ "${output}" == *'LOOK: ./.github/extra/kustomize/variants/stg'* ]]
  [[ "${output}" == *'PASS: ./.github/extra/kustomize/variants/stg'* ]]
  [[ "${output}" == *'LOOK: ./.github/extra/kustomize/variants/base'* ]]
  [[ "${output}" == *'PASS: ./.github/extra/kustomize/variants/base'* ]]
  [[ "${output}" == *'LOOK: ./.github/extra/kustomize/simple'* ]]
  [[ "${output}" == *'PASS: ./.github/extra/kustomize/simple'* ]]
}

@test 'Should validate all paths provided when filter is set to static' {
  export INPUT_FILTER='static'
  export INPUT_PATH="${SIMPLE} ${VARIANT_PRD}"
  export INPUT_LOG_LEVEL='quiet'

  run main
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "LOOK: ${SIMPLE}" ]
  [ "${lines[1]}" = "PASS: ${SIMPLE}" ]
  [ "${lines[2]}" = "LOOK: ${VARIANT_PRD}" ]
  [ "${lines[3]}" = "PASS: ${VARIANT_PRD}" ]
}

@test 'Should fail when an invalid value is given for filter' {
  export INPUT_FILTER="invalid-${RANDOM}"
  export INPUT_PATH=''
  export INPUT_LOG_LEVEL='quiet'

  run main
  [ "${status}" -eq 1 ]
  [ "${output}" = "Error: invalid value provided for filter: \"${INPUT_FILTER}\"." ]
}

@test 'Should fail when an invalid value is given for log level' {
  export INPUT_FILTER='none'
  export INPUT_PATH=''
  export INPUT_LOG_LEVEL="invalid-${RANDOM}"

  run main
  [ "${status}" -eq 1 ]
  [ "${lines[0]}" = "Error: invalid value provided for log level: \"${INPUT_LOG_LEVEL}\"." ]
  [ "${lines[1]}" = 'Accepted values are "verbose" or "quiet".' ]
}

@test 'Should fail when no path is given and filter is set to static' {
  export INPUT_FILTER='static'
  export INPUT_PATH=''
  export INPUT_LOG_LEVEL='quiet'

  run main
  [ "${status}" -eq 1 ]
  [ "${lines[0]}" = 'Error: `static` filter requires a value for input `path`.' ]
}

@test 'Should print no changes when no kustomizations are detected and filter is set to none' {
  export INPUT_FILTER='none'
  export INPUT_PATH=''
  export INPUT_LOG_LEVEL='quiet'

  cd "$(mktemp -d)" || exit 1

  run main
  [ "${status}" -eq 0 ]
  [ "${output}" = 'No kustomization directories found.' ]
}
