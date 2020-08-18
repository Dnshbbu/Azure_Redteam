#!/bin/sh
# Setup Ansible master

# cd /tmp
apt-get -y update 
apt install -y sshpass 
apt install -y ansible
sed -i '/^#host_key_checking/s/^#//' /etc/ansible/ansible.cfg
mv hosts /etc/ansible/hosts

echo "[+] Ansible is installed and ready to go"
