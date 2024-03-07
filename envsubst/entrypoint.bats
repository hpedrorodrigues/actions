#!/usr/bin/env bats

setup() {
  export JSON_INPUT_FILE="${BATS_TEST_DIRNAME}/../.github/extra/envsubst/simple.template.json"
  export TEXT_INPUT_FILE="${BATS_TEST_DIRNAME}/../.github/extra/envsubst/simple.template.txt"
  export MARKDOWN_INPUT_FILE="${BATS_TEST_DIRNAME}/../.github/extra/envsubst/simple.template.md"

  export JSON_OUTPUT_FILE='result.json'
  export TEXT_OUTPUT_FILE='result.text'
  export MARKDOWN_OUTPUT_FILE='result.md'
}

teardown() {
  ! [ -f "${JSON_OUTPUT_FILE}" ] || rm -f "${JSON_OUTPUT_FILE}"
  ! [ -f "${TEXT_OUTPUT_FILE}" ] || rm -f "${TEXT_OUTPUT_FILE}"
  ! [ -f "${MARKDOWN_OUTPUT_FILE}" ] || rm -f "${MARKDOWN_OUTPUT_FILE}"
}

main() {
  sh "${BATS_TEST_DIRNAME}/entrypoint.sh"
}

@test 'Render single file' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${TEXT_INPUT_FILE}"
  export INPUT_OUTPUT="${TEXT_OUTPUT_FILE}"

  # User-provided environment variables
  export NAME='World'

  run main
  [ "${status}" -eq 0 ]
  [ "$(cat "${INPUT_OUTPUT}")" = 'Hello, World!' ]
}

@test 'Render single file (in-place)' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${TEXT_INPUT_FILE}"
  export INPUT_OUTPUT=''
  export INPUT_IN_PLACE='true'

  # User-provided environment variables
  export NAME='World'

  run main
  [ "${status}" -eq 0 ]
  [ "${output}" = "Processing \"${TEXT_INPUT_FILE}\" (in-place)" ]
  [ "$(cat "${INPUT_INPUT}")" = 'Hello, World!' ]
}

@test 'Render single file (stdout)' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${TEXT_INPUT_FILE}"
  export INPUT_OUTPUT=''
  export INPUT_IN_PLACE='false'

  # User-provided environment variables
  export NAME='World'

  run main
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "Processing \"${TEXT_INPUT_FILE}\" (stdout)" ]
  [ "${lines[1]}" = 'Hello, World!' ]
}

@test 'Render multiple files' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${JSON_INPUT_FILE} ${MARKDOWN_INPUT_FILE}"
  export INPUT_OUTPUT="${JSON_OUTPUT_FILE} ${MARKDOWN_OUTPUT_FILE}"

  # User-provided environment variables
  export JSON_VALUE='value'
  export TITLE='Awesome!'

  run main
  [ "${status}" -eq 0 ]
  [ "$(cat "${JSON_OUTPUT_FILE}")" = '{"key": "value"}' ]
  [ "$(cat "${MARKDOWN_OUTPUT_FILE}")" = '# Awesome!' ]
}

@test 'Render multiple files (in-place)' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${JSON_INPUT_FILE} ${MARKDOWN_INPUT_FILE}"
  export INPUT_OUTPUT=''
  export INPUT_IN_PLACE='true'

  # User-provided environment variables
  export JSON_VALUE='value'
  export TITLE='Awesome!'

  run main
  [ "${status}" -eq 0 ]
  [ "$(cat "${JSON_INPUT_FILE}")" = '{"key": "value"}' ]
  [ "$(cat "${MARKDOWN_INPUT_FILE}")" = '# Awesome!' ]
}

@test 'Render multiple files (stdout)' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${TEXT_INPUT_FILE} ${JSON_INPUT_FILE}"
  export INPUT_OUTPUT=''
  export INPUT_IN_PLACE='false'

  # User-provided environment variables
  export NAME='World'
  export JSON_VALUE='value'

  run main
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "Processing \"${TEXT_INPUT_FILE}\" (stdout)" ]
  [ "${lines[1]}" = 'Hello, World!' ]
  [ "${lines[2]}" = "Processing \"${JSON_INPUT_FILE}\" (stdout)" ]
  [ "${lines[3]}" = '{"key": "value"}' ]
}

@test "Should fail when \`input\` and \`output\` doesn't have the same number of items" {
  # GitHub-provided environment variables
  export INPUT_INPUT="${JSON_INPUT_FILE} ${MARKDOWN_INPUT_FILE}"
  export INPUT_OUTPUT="${JSON_OUTPUT_FILE}"

  run main
  [ "${status}" -eq 1 ]
  [ "${lines[0]}" = 'Error: `input` and `output` must have the same number of items.' ]
  [ "${lines[1]}" = 'Got: input items=2, output items=1.' ]
}

@test 'Should fail when \`output\` and \`in_place\` are both provided' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${JSON_INPUT_FILE}"
  export INPUT_OUTPUT="${JSON_OUTPUT_FILE}"
  export INPUT_IN_PLACE='true'

  run main
  [ "${status}" -eq 1 ]
  [ "${output}" = 'Error: `output` and `in_place` are mutually exclusive and cannot be used together.' ]
}
