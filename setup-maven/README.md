# Setup Maven

Set up a specific version of [Apache Maven](https://maven.apache.org).

This action downloads the requested version from the [Apache archive](https://archive.apache.org/dist/maven) (or from a mirror), stores it in the [runner tool cache](https://github.com/actions/toolkit/tree/main/packages/tool-cache), adds `mvn` to the `PATH`, and exports `MAVEN_HOME`. It can also generate a `~/.m2/settings.xml`.

By default a preinstalled Maven that matches the requested version is reused and nothing is downloaded, while a different preinstalled version is ignored and the requested one is installed. Set `skip-if-installed: false` to instead fail when any Maven is already installed on the runner, as a tripwire for runner-image drift and to guarantee the binary comes from this action. Note that GitHub-hosted runners such as `ubuntu-latest` ship with Maven preinstalled, so `false` only suits runner images without Maven.

## Usage

```yaml
- name: Set up Maven
  uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  with:
    version: 3.9.16

- name: Build
  run: mvn --batch-mode verify
```

### Using a mirror

Set `mirror-url` to download the Maven distribution from a Maven-repository-layout mirror instead of archive.apache.org (e.g., an Artifact Registry remote repository of Maven Central, to avoid rate limits on shared egress IPs). The distribution is fetched from `<mirror-url>/org/apache/maven/apache-maven/<version>/apache-maven-<version>-bin.tar.gz`.

```yaml
- name: Set up Maven
  uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  with:
    version: 3.9.16
    mirror-url: https://us-central1-maven.pkg.dev/my-project/remote-maven-central
    mirror-token: ${{ steps.auth.outputs.access_token }}
```

`mirror-token` is optional and is sent as an `Authorization: Bearer` header. It is registered as a secret so it never appears in logs.

### Generating settings.xml

The `settings-*` inputs generate a `settings.xml` so that dependency resolution also goes through a mirror or authenticated repository. Servers, mirrors, and properties are JSON arrays with the same shape as their [settings.xml](https://maven.apache.org/settings.html) elements. The generated file is removed when the job ends.

```yaml
- name: Set up Maven
  uses: hpedrorodrigues/actions/setup-maven@v1.0.7
  with:
    mirror-url: https://us-central1-maven.pkg.dev/my-project/remote-maven-central
    mirror-token: ${{ steps.auth.outputs.access_token }}
    settings-servers: |
      [{"id": "remote-maven-central", "username": "oauth2accesstoken", "password": "${env.AR_TOKEN}"}]
    settings-mirrors: |
      [{"id": "remote-maven-central", "mirrorOf": "central", "url": "https://us-central1-maven.pkg.dev/my-project/remote-maven-central"}]

- name: Build
  run: mvn --batch-mode verify
  env:
    AR_TOKEN: ${{ steps.auth.outputs.access_token }}
```

Do not put credentials directly into `settings-servers`: reference an environment variable with `${env.NAME}` instead, and set that variable only on the steps that run `mvn`. This keeps the token out of the file on disk.

## Inputs

| Name                  | Description                                                                | Required | Default                  |
| --------------------- | -------------------------------------------------------------------------- | -------- | ------------------------ |
| `version`             | The version of Apache Maven to set up                                      | No       | `3.9.16`                 |
| `mirror-url`          | Base URL of a Maven-repository-layout mirror for the distribution download | No       |                          |
| `mirror-token`        | Bearer token used to authenticate against the mirror                       | No       |                          |
| `skip-if-installed`   | Reuse a matching preinstalled Maven instead of failing                     | No       | `true`                   |
| `settings-servers`    | Servers for the generated settings.xml (JSON array)                        | No       |                          |
| `settings-mirrors`    | Mirrors for the generated settings.xml (JSON array)                        | No       |                          |
| `settings-properties` | Properties for the generated settings.xml (JSON array of one-key objects)  | No       |                          |
| `settings-path`       | Path of the generated settings.xml                                         | No       | `$HOME/.m2/settings.xml` |
| `settings-override`   | Overwrite an existing settings.xml                                         | No       | `true`                   |

## Outputs

| Name      | Description                                 |
| --------- | ------------------------------------------- |
| `path`    | The path to the Maven installation          |
| `version` | The version of Apache Maven that was set up |

## Development

```bash
npm install
npm run all # format, lint, test, and bundle to dist/
```

The compiled `dist/` directory is committed. GitHub runs the action from it directly, so rebuild it after any change to `src/`.

To run the action locally, copy `.env.example` to `.env`, set `INPUT_VERSION`, `RUNNER_TOOL_CACHE`, and `RUNNER_TEMP`, and run `npm run local-action`.
