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

## Connect to Postgres

```bash
# TODO:
# - find out why docker compose creates a db quoted!
# Hosted by Docker.
psql -h localhost -p 5432 -U root -d \"snitch_db\"
```

## Tools

> Main tools that must be install to be able to run this repo.

- bash
- helm
- docker-compose

## TODO

- Auto assign ports.
- Create redis.conf file to play around with redis configurations
- Create postgres.config file to play around with redis configurations

## Set UP Postgres GUI

- https://towardsdatascience.com/how-to-run-postgresql-and-pgadmin-using-docker-3a6a8ae918b5

## REFERENCES

- Docker best practices: `https://testdriven.io/blog/docker-best-practices/`
