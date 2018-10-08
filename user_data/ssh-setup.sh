#!/bin/bash

# SSH KEYS CONFIG
echo 'Copying ansible-vm public SSH Keys to the VM'
echo ${PUB_KEY} >> /home/vagrant/.ssh/authorized_keys
echo ${PRIV_KEY} >> /home/vagrant/.ssh/id_rsa
chown vagrant:vagrant .ssh/id_rsa .ssh/config
echo 'Host *' >> /home/vagrant/.ssh/config
echo 'StrictHostKeyChecking no' >> /home/vagrant/.ssh/config
echo 'UserKnownHostsFile /dev/null' >> /home/vagrant/.ssh/config
chmod 700 /home/vagrant/.ssh
chmod -R 600 /home/vagrant/.ssh/*
