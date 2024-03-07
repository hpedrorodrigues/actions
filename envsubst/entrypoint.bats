#!/usr/bin/env bats

setup() {
  export JSON_TEMPLATE_FILE="${BATS_TEST_DIRNAME}/../.github/extra/envsubst/simple.template.json"
  export TEXT_TEMPLATE_FILE="${BATS_TEST_DIRNAME}/../.github/extra/envsubst/simple.template.txt"
  export MARKDOWN_TEMPLATE_FILE="${BATS_TEST_DIRNAME}/../.github/extra/envsubst/simple.template.md"

  export JSON_RESULT_FILE='result.json'
  export TEXT_RESULT_FILE='result.text'
  export MARKDOWN_RESULT_FILE='result.md'
}

teardown() {
  ! [ -f "${JSON_RESULT_FILE}" ] || rm -f "${JSON_RESULT_FILE}"
  ! [ -f "${TEXT_RESULT_FILE}" ] || rm -f "${TEXT_RESULT_FILE}"
  ! [ -f "${MARKDOWN_RESULT_FILE}" ] || rm -f "${MARKDOWN_RESULT_FILE}"
}

main() {
  sh "${BATS_TEST_DIRNAME}/entrypoint.sh"
}

@test "Render single file" {
  # GitHub-provided environment variables
  export INPUT_TEMPLATE="${TEXT_TEMPLATE_FILE}"
  export INPUT_RESULT="${TEXT_RESULT_FILE}"

  # User-provided environment variables
  export NAME='World'

  run main
  [ "${status}" -eq 0 ]
  [ 'Hello, World!' = "$(cat "${INPUT_RESULT}")" ]
}

@test "Render multiple files" {
  # GitHub-provided environment variables
  export INPUT_TEMPLATE="${JSON_TEMPLATE_FILE} ${MARKDOWN_TEMPLATE_FILE}"
  export INPUT_RESULT="${JSON_RESULT_FILE} ${MARKDOWN_RESULT_FILE}"

  # User-provided environment variables
  export JSON_VALUE='value'
  export TITLE='Awesome!'

  run main
  [ "${status}" -eq 0 ]
  [ '{"key": "value"}' = "$(cat "${JSON_RESULT_FILE}")" ]
  [ '# Awesome!' = "$(cat "${MARKDOWN_RESULT_FILE}")" ]
}

@test "Should fail when template and result doesn't have the same number of elements" {
  # GitHub-provided environment variables
  export INPUT_TEMPLATE="${JSON_TEMPLATE_FILE} ${MARKDOWN_TEMPLATE_FILE}"
  export INPUT_RESULT="${JSON_RESULT_FILE}"

  run main
  [ "${status}" -eq 1 ]
  [ "${lines[0]}" = 'Error: `template` and `result` must have the same number of items.' ]
  [ "${lines[1]}" = 'Got: template items=2, result items=1.' ]
}
