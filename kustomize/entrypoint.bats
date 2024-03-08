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

@test 'Should validate all kustomization files when detection is set to all' {
  export INPUT_DETECTION='all'
  export INPUT_PATH=''
  export INPUT_LOG_LEVEL='quiet'

  run main
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = 'LOOK: ./.github/extra/kustomize/variants' ]
  [ "${lines[1]}" = 'PASS: ./.github/extra/kustomize/variants' ]
  [ "${lines[2]}" = 'LOOK: ./.github/extra/kustomize/variants/prd' ]
  [ "${lines[3]}" = 'PASS: ./.github/extra/kustomize/variants/prd' ]
  [ "${lines[4]}" = 'LOOK: ./.github/extra/kustomize/variants/dev' ]
  [ "${lines[5]}" = 'PASS: ./.github/extra/kustomize/variants/dev' ]
  [ "${lines[6]}" = 'LOOK: ./.github/extra/kustomize/variants/stg' ]
  [ "${lines[7]}" = 'PASS: ./.github/extra/kustomize/variants/stg' ]
  [ "${lines[8]}" = 'LOOK: ./.github/extra/kustomize/variants/base' ]
  [ "${lines[9]}" = 'PASS: ./.github/extra/kustomize/variants/base' ]
  [ "${lines[10]}" = 'LOOK: ./.github/extra/kustomize/simple' ]
  [ "${lines[11]}" = 'PASS: ./.github/extra/kustomize/simple' ]
}

@test 'Should validate all paths provided when detection is set to static' {
  export INPUT_DETECTION='static'
  export INPUT_PATH="${SIMPLE} ${VARIANT_PRD}"
  export INPUT_LOG_LEVEL='quiet'

  run main
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "LOOK: ${SIMPLE}" ]
  [ "${lines[1]}" = "PASS: ${SIMPLE}" ]
  [ "${lines[2]}" = "LOOK: ${VARIANT_PRD}" ]
  [ "${lines[3]}" = "PASS: ${VARIANT_PRD}" ]
}

@test 'Should fail when an invalid value is given for detection' {
  export INPUT_DETECTION="invalid-${RANDOM}"
  export INPUT_PATH=''
  export INPUT_LOG_LEVEL='quiet'

  run main
  [ "${status}" -eq 1 ]
  [ "${output}" = "Error: invalid value provided for detection: \"${INPUT_DETECTION}\"." ]
}

@test 'Should fail when an invalid value is given for log level' {
  export INPUT_DETECTION='all'
  export INPUT_PATH=''
  export INPUT_LOG_LEVEL="invalid-${RANDOM}"

  run main
  [ "${status}" -eq 1 ]
  [ "${lines[0]}" = "Error: invalid value provided for log level: \"${INPUT_LOG_LEVEL}\"." ]
  [ "${lines[1]}" = 'Accepted values are "verbose" or "quiet".' ]
}

@test 'Should fail when no path is given and detection is set to static' {
  export INPUT_DETECTION='static'
  export INPUT_PATH=''
  export INPUT_LOG_LEVEL='quiet'

  run main
  [ "${status}" -eq 1 ]
  [ "${lines[0]}" = 'Error: `static` detection requires a value for input `path`.' ]
}
