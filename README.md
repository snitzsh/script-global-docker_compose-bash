# composer-docker

Allows to build the platform images and running containers in local machine

## Notes

This is not a helm-chart to deploy in k8s. This a helm-chart to just build the
docker-composer.yaml.

## Run commands

```bash
# $opt: create | destroy
bash main.sh <[opt]>
```

## Tools

> Main tools that must be install to be able to run this repo.

- bash
- helm
- docker-compose

## TODO

- Auto assign ports.

## Set UP Postgres GUI

- https://towardsdatascience.com/how-to-run-postgresql-and-pgadmin-using-docker-3a6a8ae918b5