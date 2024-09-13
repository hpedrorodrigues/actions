#!/usr/bin/env bats

setup() {
  export SINGLE_LINE_SCRIPT='echo "Hello!"'
  export MULTILINE_SCRIPT='
    echo "Hi!"
    echo "Hello, world!"
  '
}

main() {
  sh "${BATS_TEST_DIRNAME}/entrypoint.sh"
}

@test 'Allow to run single line scripts' {
  # GitHub-provided environment variables
  export INPUT_RUN="${SINGLE_LINE_SCRIPT}"

  run main
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = 'Hello!' ]
}

@test 'Allow to run multiline scripts' {
  # GitHub-provided environment variables
  export INPUT_RUN="${MULTILINE_SCRIPT}"

  run main
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = 'Hi!' ]
  [ "${lines[1]}" = 'Hello, world!' ]
}

@test 'Print error message when no script is provided' {
  run main
  [ "${status}" -eq 1 ]
  [ "${lines[0]}" = 'No script provided!' ]
}
