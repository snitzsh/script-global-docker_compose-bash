#!/bin/bash

# TODO:
# - https://itnext.io/upgrading-bash-on-macos-7138bd1066ba
# - Pass password from a config file so that apis-fastify
#   can have access to postgres and redis.
# - add https://redis.com/redis-enterprise/redis-insight/ to tools
#   ex: docker inspect <[postgres-container-id] | grep IPAddress

# Bash Version
# echo $(bash --version)

#
# TODO:
#   - when executor is the boilerplate, maybe we need to silance the logs
#     or change the log output to plain. Not sure how docker determines 'auto'.
#
# NOTES:
#   - https://docs.docker.com/compose/reference/
#   - flag `-f` is not listed as part of compose flags, i think it inherits
#     the flag from `docker build`.
#   - docker compose will create containers even if we are only building.
#
# ARGS:
# * $1 = file_name
#
dockerComposeUp () {

  file_name=$1

  docker \
    --debug \
    compose \
      -f "./${file_name}" \
      --progress "auto" \
      up \
        --build \
        --detach \
        --force-recreate
        # --no-log-prefix
        # --no-start
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
#   - support arguments like --arg=val
#   - user docker secret volume (maybe copy or point to .env of each
#     application)
#   - pass a flag to clear local volumes. per component or all.
#     docker-compose rm -s -f <service_name> (this command will not delete local
#     volumes)
#
# NOTE:
#   - null
#
# DESCRIPTION:
#   - main function that executes other functions based on arguments.
#
# ARGS:
#   - $1 = create | destroy
#
# RETURN:
#   - null
#
main () {

  # echo "Run: $run_command"
  # echo "Exec: $exec_command"
  # exit 1
  file_name="docker-compose.yml"
  if [[ $1 == "create" ]]; then
    # snitchDockerPruneNoneImages
    # --set components.postgres=true
    # helm template render . --debug > "./${file_name}"

    # TODO: only pipe it if success, if it fails do not override the docker-compose.yaml
    # TODO: make sure to handle 2 documnet output.
    # TODO: support --arguments to override
    helm template . > "./${file_name}"
    exit 1
    sleep 3
    dockerComposeUp ${file_name}
    # Gets the API of postgress
    # docker inspect <[postgres-container-id] | grep IPAddress
  elif [[ $1 == "destroy" ]]; then
    dockerComposeDown ${file_name}
  fi
}

main "$@"
