# Kustomize

Simple action to validate kustomization files and outputs using [Kustomize].

## Usage

```yaml
- uses: hpedrorodrigues/actions/kustomize@main
  with:
    # Strategy to use for detecting kustomization directories.
    # Possible values
    # - none: use all kustomization directories found in the repository.
    # - modified: use kustomization directories found based on the modified files.
    # - static: use the provided paths to kustomization directories.
    filter: ""

    # Paths to kustomization directories to validate (separated by space).
    # This is only used when filter is set to "static".
    path: ""

    # Log level to use for the validation.
    # Possible values:
    # - quiet: only headers and errors.
    # - verbose: same as quiet, plus kustomize output.
    log_level: ""

    # Additional flags to pass to kustomize build.
    flags: ""
```



[Kustomize]: https://kustomize.io
