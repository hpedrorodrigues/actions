# tools

Action that let you run a few Linux tools without the necessity to install them on the runner.

List of pre-installed tools is [here](https://github.com/hpedrorodrigues/images/blob/main/tools/tools.apko.yaml).

## Usage

```yaml
- name: Compress an example file
  uses: hpedrorodrigues/actions/tools@v1.0.5
  with:
    script: |
      FILE_NAME='example-file'
      zip -r ${FILE_NAME}.zip .
```
