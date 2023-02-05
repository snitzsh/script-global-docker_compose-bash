
#! /bin/bash

# TODO:
# - https://itnext.io/upgrading-bash-on-macos-7138bd1066ba

# Bash Version
# echo $(bash --version)

# $1 = file_name
dockerComposeUp () {
  file_name=$1
  docker-compose -f "./${file_name}" up
}

# $1 = file_name
dockerComposeDown() {
  file_name=$1
  docker-compose -f "./${file_name}" down
}

# TODO: create images here, such as api-fastify, etc
createImages() {
  # docker build -t apis-fastify ../apis-fastify
  docker build -t website-vue ../website-vue
  echo ""
}

# TODO: create images here, such as alpine, etc.
pullImages() {
  echo ""
}

main () {
  file_name="docker-compose.yml"
  if [[ $1 == "create" ]]; then
    createImages
    # --set components.postgres=true
    helm template render . --debug > "./${file_name}"
    dockerComposeUp ${file_name}
  else
    dockerComposeDown ${file_name}
  fi
}

# $1 = create | destroy
main $1
