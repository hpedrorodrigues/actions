# Kustomize

An action to validate kustomization files and outputs using [Kustomize].

## Usage

```yaml
- uses: hpedrorodrigues/actions/kustomize@v1.0.2
  with:
    # Strategy to use for detecting kustomization directories.
    # Possible values
    # - none: use all kustomization directories found in the repository.
    # - modified: use kustomization directories found based on the modified files.
    # - static: use the provided paths to kustomization directories.
    filter: ''

    # Paths to kustomization directories to validate (separated by space).
    # This is only used when filter is set to "static".
    path: ''

    # Log level to use for the validation.
    # Possible values:
    # - quiet: only headers and errors.
    # - verbose: same as quiet, plus kustomize output.
    log_level: ''

    # Additional flags to pass to kustomize build.
    flags: ''
```

## Scenarios

- [Validate all kustomization directories](#validate-all-kustomization-directories)
- [Validate modified kustomization directories](#validate-modified-kustomization-directories)
- [Validate specific kustomization directories](#validate-specific-kustomization-directories)
- [Validate kustomization directories with custom log level](#validate-kustomization-directories-with-custom-log-level)
- [Validate kustomization directories with custom flags](#validate-kustomization-directories-with-custom-flags)
- [Validate kustomization directories with custom kustomize version](#validate-kustomization-directories-with-custom-kustomize-version)

### Validate all kustomization directories

```yaml
- uses: hpedrorodrigues/actions/kustomize@v1.0.2
# or
- uses: hpedrorodrigues/actions/kustomize@v1.0.2
  with:
    filter: 'none'
```

### Validate modified kustomization directories

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0 # This is required to allow this action to detect modified files.
- uses: hpedrorodrigues/actions/kustomize@v1.0.2
  with:
    filter: 'modified'
```

### Validate specific kustomization directories

```yaml
- uses: hpedrorodrigues/actions/kustomize@v1.0.2
  with:
    filter: 'static'
    path: 'kustomize/base kustomize/overlays/production'
```

### Validate kustomization directories with custom log level

```yaml
- uses: hpedrorodrigues/actions/kustomize@v1.0.2
  with:
    filter: 'none'
    log_level: 'verbose'
```

### Validate kustomization directories with custom flags

```yaml
- uses: hpedrorodrigues/actions/kustomize@v1.0.2
  with:
    filter: 'none'
    flags: '--load-restrictor=LoadRestrictionsNone --enable-alpha-plugins'
```

### Validate kustomization directories with custom kustomize version

```yaml
- uses: alexellis/setup-arkade@v2
- uses: alexellis/arkade-get@master
  with:
    kustomize: latest
- uses: hpedrorodrigues/actions/kustomize@v1.0.2
  with:
    filter: 'none'
```

[Kustomize]: https://kustomize.io
