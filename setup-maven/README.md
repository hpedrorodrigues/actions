# Setup Maven

Action to set up a specific version of [Apache Maven].

## Usage

```yaml
- uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  with:
    # The version of Apache Maven to set up.
    # (default: 3.9.16)
    version: ''

    # Base URL of a Maven-repository-layout mirror to download the Maven
    # distribution from (e.g., an Artifact Registry remote repository of
    # Maven Central). The distribution is downloaded from
    # <mirror-url>/org/apache/maven/apache-maven/<version>/apache-maven-<version>-bin.tar.gz.
    mirror-url: ''

    # Bearer token used to authenticate against the mirror.
    # Registered as a secret so it never appears in logs.
    mirror-token: ''

    # Whether to reuse a preinstalled Maven that matches the requested
    # version. If false, the action fails when any Maven is already
    # installed on the runner.
    # (default: true)
    skip-if-installed: ''

    # Servers for the generated settings.xml (JSON array).
    # Reference credentials as ${env.NAME} instead of literal values.
    settings-servers: ''

    # Mirrors for the generated settings.xml (JSON array).
    settings-mirrors: ''

    # Properties for the generated settings.xml (JSON array of one-key
    # objects), rendered in a profile that is active by default.
    settings-properties: ''

    # Path of the generated settings.xml.
    # (default: $HOME/.m2/settings.xml)
    settings-path: ''

    # Whether to overwrite an existing settings.xml.
    # (default: true)
    settings-override: ''
```

The generated settings.xml is removed when the job ends.

## Outputs

| Name      | Description                                 |
| --------- | ------------------------------------------- |
| `path`    | The path to the Maven installation          |
| `version` | The version of Apache Maven that was set up |

## Scenarios

- [Set up the default Maven version](#set-up-the-default-maven-version)
- [Set up a specific Maven version](#set-up-a-specific-maven-version)
- [Download the distribution through a mirror](#download-the-distribution-through-a-mirror)
- [Fail when Maven is preinstalled](#fail-when-maven-is-preinstalled)
- [Resolve dependencies through a mirror](#resolve-dependencies-through-a-mirror)
- [Set build properties](#set-build-properties)
- [Write settings.xml to a custom path](#write-settingsxml-to-a-custom-path)
- [Use the outputs](#use-the-outputs)

### Set up the default Maven version

```yaml
- uses: hpedrorodrigues/actions/setup-maven@v1.0.7

- run: mvn --batch-mode verify
```

### Set up a specific Maven version

```yaml
- uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  with:
    version: 3.8.8
```

### Download the distribution through a mirror

```yaml
- uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  with:
    mirror-url: https://us-central1-maven.pkg.dev/my-project/remote-maven-central
    mirror-token: ${{ steps.auth.outputs.access_token }}
```

### Fail when Maven is preinstalled

GitHub-hosted runners ship with Maven preinstalled, so this only suits runner images without Maven.

```yaml
- uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  with:
    skip-if-installed: false
```

### Resolve dependencies through a mirror

The mirror inputs only cover the Maven distribution itself. Dependency resolution goes through the generated settings.xml, with the token exported only on the steps that run mvn.

```yaml
- uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  with:
    settings-servers: |
      [{"id": "remote-maven-central", "username": "oauth2accesstoken", "password": "${env.AR_TOKEN}"}]
    settings-mirrors: |
      [{"id": "remote-maven-central", "mirrorOf": "central", "url": "https://us-central1-maven.pkg.dev/my-project/remote-maven-central"}]

- run: mvn --batch-mode verify
  env:
    AR_TOKEN: ${{ steps.auth.outputs.access_token }}
```

### Set build properties

```yaml
- uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  with:
    settings-properties: |
      [{"revision": "1.2.3"}, {"maven.test.skip": "true"}]
```

### Write settings.xml to a custom path

```yaml
- uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  with:
    settings-mirrors: |
      [{"id": "corporate", "mirrorOf": "central", "url": "https://repo.example.com/maven2"}]
    settings-path: /home/runner/custom/settings.xml
    settings-override: false
```

### Use the outputs

```yaml
- uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  id: maven

- run: |
    echo "Maven ${{ steps.maven.outputs.version }} installed at ${{ steps.maven.outputs.path }}"
```

## Development

```bash
npm install
npm run all # format, lint, test, and bundle to dist/
```

The compiled `dist/` directory is committed. GitHub runs the action from it directly, so rebuild it after any change to `src/`.

To run the action locally, copy `.env.example` to `.env`, set the desired `INPUT_*` values plus `RUNNER_TOOL_CACHE` and `RUNNER_TEMP`, and run `npm run local-action`.

[Apache Maven]: https://maven.apache.org
