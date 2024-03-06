# envsubst

GitHub Action to run envsubst on a file.

> [!NOTE]
> This is a Docker-based action and may not work as expected on Windows and MacOS runners.

### Inputs

| Name          | Description                                     | Required |
| ------------- | ----------------------------------------------- | -------- |
| template_file | Path to template file to apply substitutions on | true     |
| result_file   | Path to result file with substitutions applied  | true     |

### Example

`template.yml`

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${DEPLOYMENT_NAME}
  labels:
    app: ${APP_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
    spec:
      containers:
        - name: ${APP_NAME}
          image: ${IMAGE}
```

`.github/workflows/main.yml`

```yml
- name: Render template
  uses: hpedrorodrigues/actions/envsubst@main
  with:
    template_file: template.yml
    result_file: deployment.yml
  env:
    DEPLOYMENT_NAME: ${{ env.DEPLOYMENT_NAME }}
    APP_NAME: haproxy
    IMAGE: ${{ env.DOCKER_IMAGE }}:${{ github.sha }}
```
