#!/bin/bash

# get configuration from /etc/ldap.conf
#for x in $(sed -n 's/^\([a-zA-Z_]*\) \(.*\)$/\1="\2"/p' /etc/ldap/ldap.conf |grep bind..=); do 
#for x in $(grep bind[dnpw] /etc/ldap/ldap.conf |sed s/\ /=\"/); do 
#  echo $x\" 
#  #eval $x; 
#done
bindpw="$(grep bindpw /etc/ldap/ldap.conf |sed s/bindpw\ //)";
binddn="$(grep binddn /etc/ldap/ldap.conf |sed s/binddn\ //)";
base="$(grep base\  /etc/ldap/ldap.conf |sed s/base\ //)";
uri="$(grep uri /etc/ldap/ldap.conf |sed s/uri\ //)";
ssl="$(grep ssl\  /etc/ldap/ldap.conf|sed s/ssl\ //)";
tls_checkpeer="$(grep tls_checkpeer\  /etc/ldap/ldap.conf|sed s/tls_checkpeer\ //)";

OPTIONS=
case "$ssl" in
    start_tls) 
	case "$tls_checkpeer" in
	    no) OPTIONS+="-Z";;
	    *) OPTIONS+="-ZZ";;
	esac;;
esac

ldapsearch $OPTIONS -H "${uri}" \
    -w "${bindpw}" -D "${binddn}" \
    -b "${base}" \
    '(&(objectClass=posixAccount)(uid='"$1"'))' \
    'sshPublicKey' \
    |sed -n '/^ /{H;d};/sshPublicKey::/x;$g;s/\n *//g;s/sshPublicKey:: //gp' |base64 -d
