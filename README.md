# About

Minimalistic Alpine linux desktop 
* vnc server as remote
* uses openbox as WM 
* Terminator as terminal client
* SSH client supports GSSAPI auth

# Usage

Start the container
```bash
docker run -d --name alpine -p -p 5900:5900 netaskd/alpine-vnc
```

*note Connect with your favorite vnc client

User: alpine
Pass: alpine
