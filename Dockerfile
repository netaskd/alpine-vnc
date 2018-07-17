FROM alpine:edge
MAINTAINER netaskd@gmail.com

ARG USER=${USER:-alpine}
ARG PASS=${PASS:-alpine}

ADD apk /apk
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
	&& apk --update --no-cache add \
	xset xsetroot xvfb x11vnc thunar-volman feh git xfce4-terminal \
	slim xf86-input-synaptics xf86-input-mouse xf86-input-keyboard \
	setxkbmap util-linux dbus dbus-x11 tcpdump ttf-freefont krb5 bind-tools \
	xauth supervisor x11vnc util-linux dbus ttf-freefont chromium ansible \
	xf86-input-keyboard sudo terminus-font openbox py2-vte bash vim numix-themes-gtk2 \
	&& apk --allow-untrusted --no-cache add /apk/*.apk \
	&& rm -rf /tmp/* /var/cache/apk/*

RUN addgroup ${USER} \
	&& adduser  -G ${USER} -s /bin/bash -D ${USER} \
	&& echo "${USER}:${PASS}" | /usr/sbin/chpasswd 0>/dev/null \
	&& echo "${USER}    ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
	&& sed -i 's,/ash,/bash,g' /etc/passwd 

ADD terminator /home/${USER}/.config/terminator
ADD etc /etc

EXPOSE 5900 22
VOLUME ["/etc/ssh"]
ENTRYPOINT ["/etc/docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]

