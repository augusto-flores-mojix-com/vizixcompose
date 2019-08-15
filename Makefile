DEBUG := $(filter test, $(MAKECMDGOALS))
ENVSUBST := $(shell command -v envsubst 2> /dev/null)

.PHONY: all

all:
ifndef ENVSUBST
	$(error "envsubst is not available. Please check the documentation to continue.")
endif

help:
	@echo Sample command: make SERVICES_URL=127.0.0.1 VIZIX_VERSION=vX.x.x VIZIX_DATA_PATH=$PWD/data

envfile: check-env
	$(info Trying to generate the .env file...)
	envsubst < envsample > .env

test: check-env
	$(info Using the following variables:)
	$(info SERVICES_URL=${SERVICES_URL})
	$(info VIZIX_VERSION=${VIZIX_VERSION})
	$(info VIZIX_DATA_PATH=${VIZIX_DATA_PATH})
	@echo Generate the dotenv file executing the following:
	@echo make envfile

check-env:
ifeq ($(SERVICES_URL),)
	$(error SERVICES_URL is not defined. Execute "make help" for more information.)
endif
ifeq ($(VIZIX_VERSION),)
	$(error VIZIX_VERSION is not defined. Execute "make help" for more information.)
endif
ifeq ($(VIZIX_DATA_PATH),)
	$(error DATA_PATH is not defined. Execute "make help" for more information.)
endif