# 02-build-and-scout

Set up:
- Go to settings > secrets and variables > actions
  - Add a new secret: DOCKER_USERNAME
  - Add a new secret: DOCKER_PASSWORD
  - See: https://github.com/docker-sa/01-build-image/settings/secrets/actions

## Create a tag to trigger the workflow

```bash
TAG="0.0.0"
git add .
git commit -m "📦 create release ${TAG}"
git tag ${TAG}
git push origin main ${TAG}
```

Go to https://github.com/docker-sa/02-build-and-scout/actions

And then, https://hub.docker.com/repository/docker/philippecharriere494/02-hello-scout-demo/general
