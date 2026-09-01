# Setup Maven

Set up a specific version of [Apache Maven](https://maven.apache.org).

This action downloads the requested version from the [Apache archive](https://archive.apache.org/dist/maven) (or from a mirror), stores it in the [runner tool cache](https://github.com/actions/toolkit/tree/main/packages/tool-cache), adds `mvn` to the `PATH`, and exports `MAVEN_HOME`.

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

`mirror-token` is optional and is sent as an `Authorization: Bearer` header. It is registered as a secret so it never appears in logs. Note that the mirror only serves the Maven distribution itself. To also resolve project dependencies through the mirror, configure `~/.m2/settings.xml`.

## Inputs

| Name           | Description                                          | Required | Default  |
| -------------- | ---------------------------------------------------- | -------- | -------- |
| `version`      | The version of Apache Maven to set up                | No       | `3.9.16` |
| `mirror-url`   | Base URL of a Maven-repository-layout mirror         | No       |          |
| `mirror-token` | Bearer token used to authenticate against the mirror | No       |          |

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
