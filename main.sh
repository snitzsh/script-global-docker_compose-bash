
#! /bin/bash

# TODO:
# - https://itnext.io/upgrading-bash-on-macos-7138bd1066ba
# - Pass password from a config file so that apis-fastify
#   can have access to postgres and redis.
# - add https://redis.com/redis-enterprise/redis-insight/ to tools
# - get the container id for redis and postgres to get the host api-address
#   find out how to pass it on the redisinsight and pgadmin4 to prevent
#   creating a db connection everytime.
#   ex: docker inspect <[postgres-container-id] | grep IPAddress

# Bash Version
# echo $(bash --version)

# Args:
# * $1 = file_name
dockerComposeUp () {
  file_name=$1
  docker compose -f "./${file_name}" up --build --detach --force-recreate
}

# Args
#* $1 = file_name
dockerComposeDown() {
  file_name=$1
  docker compose -f "./${file_name}" down
}
# TODO:
#   - check if needs to build or not. maybe have a cache file with true false
#     based on git diff. Only for local.
#   - this function can be use to build for ECR
# ARGS:
# * $1 = build-images : true | false
snitchBuildImages() {
  # build_images=$1
  # "apis-fastify"
  # repos_folder=("apis-rust" "website-vue")
  repos_folder=("apis-rust")

  for folder in "${repos_folder[@]}"
  do
    echo "Building image for $folder"
    sleep 5
    echo "##############-START-##############"
    docker build -t "${folder}" "../${folder}"
    echo "##############-DONE-##############"
  done
}

# TODO
# - Do dynamic pull ex: docker | ecr | etc.
# NOTE:
# - No neeed to pull anymore. docker compose will pull it automatically.
publicPullRemoteImages() {
  images=(
    "redis"
    "postgres"
    "grafana/grafana"
    "dpage/pgadmin4"
    "redislabs/redisinsight"
  )
  for image in "${images[@]}"
  do
    echo "Pulling docker image for $image"
    sleep 5
    echo "##############-START-##############"
    docker pull "${image}"
    echo "##############-DONE-##############"
  done
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
    # snitchBuildImages
    # publicPullRemoteImages
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

main $1
