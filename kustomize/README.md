# Kustomize

Simple action to validate kustomization files and outputs using [Kustomize].

## Usage

```yaml
- uses: hpedrorodrigues/actions/kustomize@main
  with:
    # Strategy to use for detecting kustomization directories.
    # Possible values: all, git-diff, static.
    detection: ""

    # Paths to kustomization directories to validate (separated by space).
    # This is only used when detection is set to "static".
    path: ""

    # Log level to use for the validation.
    # Possible values: quiet, verbose.
    # - quiet: only headers and errors.
    # - verbose: same as quiet, plus kustomize output.
    log_level: ""
```



[Kustomize]: https://kustomize.io
