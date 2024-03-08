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

  git checkout -- "${JSON_INPUT_FILE}" "${TEXT_INPUT_FILE}" "${MARKDOWN_INPUT_FILE}"
}

main() {
  sh "${BATS_TEST_DIRNAME}/entrypoint.sh"
}

@test 'Apply substitutions on single file' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${TEXT_INPUT_FILE}"
  export INPUT_OUTPUT="${TEXT_OUTPUT_FILE}"
  export INPUT_IN_PLACE='false'
  export INPUT_FORMAT=''

  # User-provided environment variables
  export NAME='World'

  run main
  [ "${status}" -eq 0 ]
  [ "$(cat "${INPUT_OUTPUT}")" = 'Hello, World!' ]
}

@test 'Apply substitutions on single file (in-place)' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${TEXT_INPUT_FILE}"
  export INPUT_OUTPUT=''
  export INPUT_IN_PLACE='true'
  export INPUT_FORMAT=''

  # User-provided environment variables
  export NAME='World'

  run main
  [ "${status}" -eq 0 ]
  [ "${output}" = "Processing \"${TEXT_INPUT_FILE}\" (in-place)" ]
  [ "$(cat "${INPUT_INPUT}")" = 'Hello, World!' ]
}

@test 'Apply substitutions on single file (stdout)' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${TEXT_INPUT_FILE}"
  export INPUT_OUTPUT=''
  export INPUT_IN_PLACE='false'
  export INPUT_FORMAT=''

  # User-provided environment variables
  export NAME='World'

  run main
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "Processing \"${TEXT_INPUT_FILE}\" (stdout)" ]
  [ "${lines[1]}" = 'Hello, World!' ]
}

@test 'Apply substitutions on multiple files' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${MARKDOWN_INPUT_FILE} ${TEXT_INPUT_FILE}"
  export INPUT_OUTPUT="${MARKDOWN_OUTPUT_FILE} ${TEXT_OUTPUT_FILE}"
  export INPUT_IN_PLACE='false'
  export INPUT_FORMAT=''

  # User-provided environment variables
  export TITLE='Awesome!'
  export NAME='John'

  run main
  [ "${status}" -eq 0 ]
  [ "$(cat "${MARKDOWN_OUTPUT_FILE}")" = '# Awesome!' ]
  [ "$(cat "${TEXT_OUTPUT_FILE}")" = 'Hello, John!' ]
}

@test 'Apply substitutions on multiple files (in-place)' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${TEXT_INPUT_FILE} ${MARKDOWN_INPUT_FILE}"
  export INPUT_OUTPUT=''
  export INPUT_IN_PLACE='true'
  export INPUT_FORMAT=''

  # User-provided environment variables
  export NAME='Jane'
  export TITLE='Amazing!'

  run main
  [ "${status}" -eq 0 ]
  [ "$(cat "${TEXT_INPUT_FILE}")" = 'Hello, Jane!' ]
  [ "$(cat "${MARKDOWN_INPUT_FILE}")" = '# Amazing!' ]
}

@test 'Apply substitutions on multiple files (stdout)' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${MARKDOWN_INPUT_FILE} ${TEXT_INPUT_FILE}"
  export INPUT_OUTPUT=''
  export INPUT_IN_PLACE='false'
  export INPUT_FORMAT=''

  # User-provided environment variables
  export TITLE='Test'
  export NAME='Jenny'

  run main
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "Processing \"${MARKDOWN_INPUT_FILE}\" (stdout)" ]
  [ "${lines[1]}" = '# Test' ]
  [ "${lines[2]}" = "Processing \"${TEXT_INPUT_FILE}\" (stdout)" ]
  [ "${lines[3]}" = 'Hello, Jenny!' ]
}

@test 'Should apply substitutions only for the environment variables referenced in the format string' {
  # GitHub-provided environment variables
  export INPUT_INPUT="${JSON_INPUT_FILE}"
  export INPUT_OUTPUT=''
  export INPUT_IN_PLACE='false'
  export INPUT_FORMAT='${VALUE_1} ${VALUE_3}'

  # User-provided environment variables
  export VALUE_1='value 1'
  export VALUE_2='value 2'
  export VALUE_3='value 3'

  run main
  [ "${status}" -eq 0 ]
  [ "${lines[0]}" = "Processing \"${JSON_INPUT_FILE}\" (stdout)" ]
  [ "${lines[1]}" = '{"key_1": "value 1", "key_2": "${VALUE_2}", "key_3": "value 3"}' ]
}

@test "Should fail when \`input\` and \`output\` doesn't have the same number of items" {
  # GitHub-provided environment variables
  export INPUT_INPUT="${JSON_INPUT_FILE} ${MARKDOWN_INPUT_FILE}"
  export INPUT_OUTPUT="${JSON_OUTPUT_FILE}"
  export INPUT_IN_PLACE='false'
  export INPUT_FORMAT=''

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
  export INPUT_FORMAT=''

  run main
  [ "${status}" -eq 1 ]
  [ "${output}" = 'Error: `output` and `in_place` are mutually exclusive and cannot be used together.' ]
}
