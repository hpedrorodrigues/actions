# envsubst

Simple wrapper action for running [envsubst] over a file or set of files.

## Usage

```yaml
- uses: hpedrorodrigues/actions/envsubst@v1.0.6
  with:
    # One or more files to apply substitutions on (separated by space).
    input: ''

    # One or more files to write the result to (separated by space).
    # If not provided, the result will be printed to stdout.
    output: ''

    # Whether to perform in-place substitutions.
    # If true, the input files will be overwritten with the result.
    in_place: ''

    # Describe environment variables to be used in the substitutions (separated by space).
    # If provided, only the environment variables referenced in the format will be substituted.
    format: ''
```

## Scenarios

- [Apply substitutions on a single file](#apply-substitutions-on-a-single-file)
- [Apply substitutions on multiple files](#apply-substitutions-on-multiple-files)
- [Apply substitutions in-place](#apply-substitutions-in-place)
- [Apply substitutions with custom environment variables](#apply-substitutions-with-custom-environment-variables)
- [Apply substitutions and print result to stdout](#apply-substitutions-and-print-result-to-stdout)
- [Apply substitutions restricting to specific environment variables](#apply-substitutions-restricting-to-specific-environment-variables)

### Apply substitutions on a single file

```yaml
- uses: hpedrorodrigues/actions/envsubst@v1.0.6
  with:
    input: template.yml
    output: deployment.yml
```

### Apply substitutions on multiple files

```yaml
- uses: hpedrorodrigues/actions/envsubst@v1.0.6
  with:
    input: template.yml package.txt config.toml
    output: result.yml output.txt result.toml
```

### Apply substitutions in-place

```yaml
- uses: hpedrorodrigues/actions/envsubst@v1.0.6
  with:
    input: deployment.yml
    in_place: true
```

### Apply substitutions with custom environment variables

```yaml
- uses: hpedrorodrigues/actions/envsubst@v1.0.6
  with:
    input: template.yml
    output: result.yml
  env:
    BUILD_REF: ${{ github.sha }}
    CUSTOM: 'static value'
```

### Apply substitutions and print result to stdout

```yaml
- uses: hpedrorodrigues/actions/envsubst@v1.0.6
  with:
    input: template.yml
```

### Apply substitutions restricting to specific environment variables

```yaml
- uses: hpedrorodrigues/actions/envsubst@v1.0.6
  with:
    input: template.yml
    format: '${CUSTOM_VAR} ${GITHUB_SHA}'
```

[envsubst]: https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html
