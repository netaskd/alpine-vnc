#!/bin/sh

# generate fresh rsa key if needed
if [ ! -f "/etc/ssh/ssh_host_rsa_key" ];then 
  ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi

# generate fresh dsa key if needed
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ];then 
  ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

# set custom ssh_config
envsubst <etc/ssh/ssh_config >/etc/ssh/ssh_config

# prepare ssh run dir
mkdir -p /var/run/sshd

# generate krb5cc_0 and krb5cc_1000
[ ! -f "/tmp/krb5cc_0" ] \
&& [ -f "/etc/krb5.keytab" ] \
&& kinit -k ${USER}@${REALM} -t /etc/krb5.keytab -c /tmp/krb5cc_0 \
&& cp /tmp/krb5cc_0 /tmp/krb5cc_1000 \
&& chown ${USER}:${USER} /tmp/krb5cc_1000

# periodic update krb5 cache
[ ! -f "/etc/periodic/host-kinit.sh" ] \
&& [ -f "/etc/krb5.keytab" ] \
&& echo "kinit -k ${USER}@${REALM} -t /etc/krb5.keytab -c /tmp/krb5cc_0" >/etc/periodic/host-kinit.sh \
&& echo "cp /tmp/krb5cc_0 /tmp/krb5cc_1000" >>/etc/periodic/host-kinit.sh \
&& echo "chown ${USER}:${USER} /tmp/krb5cc_1000" >>/etc/periodic/host-kinit.sh \
&& chmod +x /etc/periodic/host-kinit.sh \
&& echo '*/5 	* 	* 	* 	*	/etc/periodic/host-kinit.sh' >>/etc/crontabs/root

# set bashrc
echo "PS1='\u[\W]# '" >>/root/.bashrc
echo "PS1='\u[\W]\$ '" >>/home/${USER}/.bashrc

# set profile for Terminator
envsubst </home/${USER}/.config/terminator/config >/home/${USER}/.config/terminator/config
chown -R ${USER}:${USER} /home/${USER}

# set env
envsubst </etc/supervisord.conf >/etc/supervisord.conf

# openbox theme mod
envsubst </etc/xdg/openbox/autostart >/etc/xdg/openbox/autostart
sed -i 's/#6699CC/#010102/g' /usr/share/themes/Mikachu/openbox-3/themerc
sed -i 's/#334866/#0b0b3d/g' /usr/share/themes/Mikachu/openbox-3/themerc
sed -i 's/#7F7FA0/#2B2B4F/g' /usr/share/themes/Mikachu/openbox-3/themerc
sed -i 's/#333350/#2E2E5B/g' /usr/share/themes/Mikachu/openbox-3/themerc

# vim settings
ln -sf /usr/bin/vim /usr/bin/vi \
&& echo "colors desert" >> /etc/vim/vimrc

# set gtk2 theme
echo 'gtk-icon-theme-name= "Tangerine"' >/home/${USER}/.gtkrc-2.0 \
&& echo 'gtk-theme-name= "Numix"' >>/home/${USER}/.gtkrc-2.0 \
&& echo 'gtk-font-name = "xos4 Terminus 12"' >>/home/${USER}/.gtkrc-2.0

# generate machine-id
uuidgen > /etc/machine-id

# set keyboard for all sh users
echo "export QT_XKB_CONFIG_ROOT=/usr/share/X11/locale" >> /etc/profile
source /etc/profile

exec "$@"
