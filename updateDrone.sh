#!/bin/bash

login() { 
echo "Type docker_username:"
read docker_username
echo "Type docker_password:"
read docker_password
echo "Type slack_webhook"
read slack_webhook

echo "Logging in to Drone"
export DRONE_SERVER=https://drone.vizixcloud.com
echo "set ${DRONE_SERVER}"

echo "Type Drone Token:"
read drone_token
export DRONE_TOKEN=${drone_token}
drone info
}

what=${1}
repo=${2}

if [ $what = 'create' ]; then

echo "Creating Secrets at the following Repository: ${2}"
login
sleep 2

drone secret add \
--repository tierconnect/${repo} \
--name slack_webhook \
--value ${slack_webhook} \
--image plugins/slack \
--event push \
--event pull_request \
--event tag

drone secret add \
--repository tierconnect/${repo} \
--name docker_username \
--value ${docker_username} \
--image plugins/docker \
--event push \
--event pull_request \
--event tag

drone secret add \
--repository tierconnect/${repo} \
--name docker_password \
--value ${docker_password} \
--image plugins/docker \
--event push \
--event pull_request \
--event tag

fi
if [ $what = 'update' ]; then

echo "Updating Secrets at the following Repository: ${2}"
login
sleep 2

drone secret update \
--repository tierconnect/${repo} \
--name slack_webhook \
--image plugins/slack \
--event push \
--event pull_request \
--event tag

drone secret update \
--repository tierconnect/${repo} \
--name docker_username \
--image plugins/docker \
--event push \
--event pull_request \
--event tag

drone secret update \
--repository tierconnect/${repo} \
--name docker_password \
--image plugins/docker \
--event push \
--event pull_request \
--event tag

    exit 0
fi
