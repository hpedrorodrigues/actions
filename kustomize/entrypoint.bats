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
