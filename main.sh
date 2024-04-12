#!/bin/bash

# TODO:
# - https://itnext.io/upgrading-bash-on-macos-7138bd1066ba
# - Pass password from a config file so that apis-fastify
#   can have access to postgres and redis.
# - add https://redis.com/redis-enterprise/redis-insight/ to tools
#   ex: docker inspect <[postgres-container-id] | grep IPAddress

# Bash Version
# echo $(bash --version)

# NOTES:
# - https://docs.docker.com/compose/reference/
# Args:
# * $1 = file_name
dockerComposeUp () {
  file_name=$1
  docker \
  --debug \
  compose \
  -f "./${file_name}" \
  up \
    --build \
    --detach \
    --force-recreate
}

# Args
#* $1 = file_name
dockerComposeDown() {
  file_name=$1
  docker compose -f "./${file_name}" down
}

snitchDockerPruneNoneImages() {
  # removes all <none> images
  docker rmi $(docker images --filter “dangling=true” -q --no-trunc)
}

#
# TODO:
# - support arguments like --arg=val
#
# ARGS
# * $1 = create | destroy
# NOTE: Only applies for apis-fastify
# * $2 = architecture : monolithic | microservice
# * $3 = build-images: | true | false
# * $4 = pull-remote-images : true | false
#
main () {
  file_name="docker-compose.yml"
  if [[ $1 == "create" ]]; then
    # snitchDockerPruneNoneImages
    # --set components.postgres=true
    # helm template render . --debug > "./${file_name}"
    helm template . > "./${file_name}"
    sleep 5
    dockerComposeUp ${file_name}
    # Gets the API of postgress
    # docker inspect <[postgres-container-id] | grep IPAddress
  elif [[ $1 == "destroy" ]]; then
    dockerComposeDown ${file_name}
  fi
}

# TODO:
# - user docker secret volume (maybe copy or point to .env of each application)
# - pass a flag to clear local volumes. per component or all.
#     docker-compose rm -s -f <service_name> (this command will not delete local volumes)
#
main "$1"
