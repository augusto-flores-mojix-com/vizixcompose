#!/bin/sh
set -eu

build() {
    echo "Building VIAB version ${DRONE_TAG}"
    terraform init
    terraform plan -out="viab.plan" -var "aws_access_key=${AWS_ACCESS_KEY}" -var "aws_secret_key=${AWS_SECRET_KEY}" -var "vizix_version=${DRONE_TAG}" -var "packet_api_key=${PACKET_API_KEY}" -var "packet_project_id=${PACKET_PROJECT_ID}" -var "docker_hub_username=${DOCKER_HUB_USERNAME}" -var "docker_hub_password=${DOCKER_HUB_PASSWORD}"
    cat viab.plan
    terraform apply -auto-approve "viab.plan"
}

destroy() {
    terraform destroy -force -var "aws_access_key=${AWS_ACCESS_KEY}" -var "aws_secret_key=${AWS_SECRET_KEY}" -var "vizix_version=${DRONE_TAG}" -var "packet_api_key=${PACKET_API_KEY}" -var "packet_project_id=${PACKET_PROJECT_ID}" -var "docker_hub_username=${DOCKER_HUB_USERNAME}" -var "docker_hub_password=${DOCKER_HUB_PASSWORD}"
}

case $1 in
    'build' )
        build
    ;;
    'destroy' )
        destroy
    ;;
    *) echo "ERROR: No task defined."; exit 1;;
esac
