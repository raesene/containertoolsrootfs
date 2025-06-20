#!/bin/sh

: ${SSH_USERPASS:=$(dd if=/dev/urandom bs=1 count=15 | base64)}

__create_rundir() {
	mkdir -p /var/run/sshd
}

__create_user() {
# Create a user to SSH into as.
echo  "root:$SSH_USERPASS" | chpasswd
echo ssh user password: $SSH_USERPASS
}

__create_hostkeys() {
rm -f /etc/ssh/ssh_host_rsa_key
rm -f /etc/ssh/ssh_host_rsa_key.pub
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 
}

__ip_address() {
ip_address=$(ip addr show | grep -E '^[0-9]+: eth0' -A2 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')
echo "The IP address is: $ip_address"
}


# Call all functions
__create_rundir
__create_hostkeys
__create_user
__ip_address

exec /usr/sbin/sshd -D -p 3456 -e "$@"
