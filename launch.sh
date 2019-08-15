#!/bin/bash -e

generate_env_file() {
  envsubst < envsample > .env
}

login_to_dockerhub() {
  docker login -u "$DOCKER_HUB_USERNAME" -p "$DOCKER_HUB_PASSWORD"
}

setup_mongo() {
  source .env
  docker-compose up -d mongo
  docker-compose exec -T mongo mongo admin \
  --eval "db.createUser({user:'$VIZIX_MONGO_USERNAME', pwd:'$VIZIX_MONGO_PASSWORD',roles:['userAdminAnyDatabase']});"
  docker-compose exec -T mongo mongo admin -u "$VIZIX_MONGO_USERNAME" -p "$VIZIX_MONGO_PASSWORD" \
  --authenticationDatabase admin \
  --eval "db.createRole({role:'executeFunctions',privileges:[{resource:{anyResource:true},actions:['anyAction']}],roles:[]});db.grantRolesToUser('admin',[{ role: 'executeFunctions', db: 'admin' },{ role : 'readWrite', db : '$VIZIX_MONGO_DB' }]);"
}

launch_base_containers() {
  docker-compose up -d mqtt mysql zookeeper
  sleep 5
  docker-compose up -d kafka
}

execute_vizix_tools() {
  docker-compose -f vizix-tools.yml up
}

cleanup() {
  docker system prune -f
  docker logout
  rm -rf envsample
}


printenv
cd /opt/vizix/

generate_env_file
login_to_dockerhub
setup_mongo
launch_base_containers
execute_vizix_tools
docker-compose up -d
cleanup
