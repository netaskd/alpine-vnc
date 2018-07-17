NAME ?= alpine-vnc
PREF ?= 
DOCKER_REPO ?= ${DOCKER_REPO:-netaskd}
TAG ?= latest
USER ?= alpine
PASS ?= alpine
REALM ?= LOCALDOMAIN
KVNO ?= 1
RESOLUTION ?= 1920x1080

.PHONY: build start stop restart

all: help
restart: stop start keytab

build:	## build image from source
	@docker build --build-arg USER=${USER} --build-arg PASS=${PASS} -t ${DOCKER_REPO}/${NAME}:${TAG} .
	@docker rmi -f $(shell docker images -qf 'dangling=true') >/dev/null 2>&1 || true

start:	## create the container and run it as daemon
	@docker run -d \
	--restart=always \
	--hostname=${NAME} \
	-v /etc/localtime:/etc/localtime:ro \
	-p 5900:5900 \
	--name ${NAME}${PREF} \
	-e USER=${USER} \
	-e PASS=${PASS} \
	-e REALM=${REALM} \
	-e RESOLUTION=${RESOLUTION} \
	${DOCKER_REPO}/${NAME}:${TAG} >/dev/null 2>&1

stop:   ## remove the container
	@docker rm -fv ${NAME}${PREF} >/dev/null 2>&1 || true

exec:   ## run shell inside the container
	@docker exec -it ${NAME}${PREF} bash

login:  ## login to docker registry
	@docker login $(DOCKER_REPO)/$(NAME):$(TAG)

push:   ## push image to docker registry
	@docker push $(DOCKER_REPO)/$(NAME):$(TAG) 

keytab:	## generate keytab for GSSAPI ssh connection
	@docker exec -it ${NAME}${PREF} bash -c \
	'REALM=${REALM} \
	KVNO=${KVNO} \
	USER=${USER} \
	PASS=${PASS} \
	CRYPTO=${CRYPTO} \
	/etc/gen-keytab.sh'

help:   ## show this help
	@grep -h "##" $(MAKEFILE_LIST) | grep -v grep | sed -e 's/\\$$//;s/##/\t/'

