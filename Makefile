NAME ?= alpine-vnc
PREF ?= 
DOCKER_REPO ?= ${DOCKER_REPO:-netaskd}
TAG ?= latest
USER ?= alpine
PASS ?= alpine
REALM ?= LOCALDOMAIN
KVNO ?= 3
RESOLUTION ?= 1920x1080

.PHONY: build start stop restart

all: help
restart: stop start

build:	## build image from source
	@docker build --build-arg USER=${USER} --build-arg PASS=${PASS} -t ${DOCKER_REPO}/${NAME}:${TAG} .
	@docker rmi -f $(shell docker images -qf 'dangling=true') >/dev/null 2>&1 || true

start:	## create the container and run it as daemon
	docker run -d \
	--restart=always \
	--hostname=${NAME} \
	-v /etc/localtime:/etc/localtime:ro \
	-p 5900:5900 \
	--name ${NAME}${PREF} \
	-e USER=${USER} \
	-e PASS=${PASS} \
	-e REALM=${REALM} \
	-e RESOLUTION=${RESOLUTION} \
	${DOCKER_REPO}/${NAME}:${TAG}

stop:   ## remove the container
	@docker rm -fv ${NAME}${PREF} || true

exec:   ## run shell inside the container
	@docker exec -it ${NAME}${PREF} bash

login:  ## login to docker registry
	@docker login $(DOCKER_REPO)/$(NAME):$(TAG)

push:   ## push image to docker registry
	@docker push $(DOCKER_REPO)/$(NAME):$(TAG) 

keytab:	## generate keytab for GSSAPI ssh connection
	@echo -en 'addent -password -p ${USER}@${REALM} -k ${KVNO} -e aes256-cts-hmac-sha1-96\n${PASS}\nwkt ./etc/krb5.keytab\n\q\n'|ktutil

help:   ## show this help
	@grep -h "##" $(MAKEFILE_LIST) | grep -v grep | sed -e 's/\\$$//;s/##/\t/'

