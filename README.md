# About

Minimalistic Alpine linux desktop inside docker container
* vnc server as remote
* uses openbox as WM 
* Terminator as terminal client
* SSH client supports GSSAPI auth

# Usage

Use make file for manage it
```bash
$ make
build:		 build image from source
start:		 create the container and run it as daemon
stop:   	 remove the container
exec:   	 run shell inside the container
login:  	 login to docker registry
push:   	 push image to docker registry
keytab:		 generate keytab for GSSAPI ssh connection
help:   	 show this help
```

*note Connect with your favorite vnc client

User: alpine

Pass: alpine
