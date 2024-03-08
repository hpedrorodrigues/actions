#!/usr/bin/env bats

setup() {
  cd "${BATS_TEST_DIRNAME}/.." || exit 1
}

main() {
  sh "${BATS_TEST_DIRNAME}/entrypoint.sh"
}

@test 'Should validate all kustomization files successfully' {
  export INPUT_DETECTION='all'

  run main
  [ "${status}" -eq 0 ]
}

@test 'Should fail when an invalid value is given for detection' {
  export INPUT_DETECTION="invalid-${RANDOM}"

  run main
  [ "${status}" -eq 1 ]
  [ "${output}" = "Error: invalid value provided for detection: \"${INPUT_DETECTION}\"." ]
}
