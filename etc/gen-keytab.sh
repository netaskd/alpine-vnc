#!/bin/bash

# set default values
CRYPTO=${CRYPTO:-aes256-cts-hmac-sha1-96}
KVNO=${KVNO:-1}

# simple check necessary staff
[ -z $(which ktutil) ] && echo "ktutil is not found. please add krb5-workstation packet" && exit 1

# test variables
[ -z "${REALM}" ] && echo "You have to set vars: USER, REALM, KVNO, PASS before run it target" && exit 127
[[ "$USER" == "alpine" ]] && echo "please set USER variable to domain username" && exit 1
[[ "$PASS" == "alpine" ]] && echo "please set PASS variable to domain user's password" && exit 1

# remove old file
[ -f ${PWD}/krb5.keytab ] && rm -f ${PWD}/krb5.keytab

# generate new file
ktutil <<EOF 2>/dev/null
addent -password -p ${USER}@${REALM} -k ${KVNO} -e ${CRYPTO}
${PASS}
wkt ${PWD}/krb5.keytab
exit
EOF

# show list
klist -Kekt ${PWD}/krb5.keytab

# generate krb5cc_0 and krb5cc_1000
kinit -k ${USER}@${REALM} -t /etc/krb5.keytab -c /tmp/krb5cc_0 \
&& cp /tmp/krb5cc_0 /tmp/krb5cc_1000 \
&& chown ${USER}:${USER} /tmp/krb5cc_1000

# periodic update krb5 cache
[ ! -f "/etc/periodic/host-kinit.sh" ] \
&& [ -f "/etc/krb5.keytab" ] \
&& [ ! -z "${REALM}" ] \
&& echo "kinit -k ${USER}@${REALM} -t /etc/krb5.keytab -c /tmp/krb5cc_0" >/etc/periodic/host-kinit.sh \
&& echo "cp /tmp/krb5cc_0 /tmp/krb5cc_1000" >>/etc/periodic/host-kinit.sh \
&& echo "chown ${USER}:${USER} /tmp/krb5cc_1000" >>/etc/periodic/host-kinit.sh \
&& chmod +x /etc/periodic/host-kinit.sh \
&& echo '*/5    *       *       *       *       /etc/periodic/host-kinit.sh' >>/etc/crontabs/root \
|| echo "notice: cron job is not updated. see file: $0"

