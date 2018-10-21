#!/bin/bash

# SSH KEYS CONFIG
echo 'Copying ansible-vm public SSH Keys to the VM'
cat /vagrant/ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
cp /vagrant/ssh/id_rsa /home/vagrant/.ssh/

echo 'Host *' >> /home/vagrant/.ssh/config
echo 'StrictHostKeyChecking no' >> /home/vagrant/.ssh/config
echo 'UserKnownHostsFile /dev/null' >> /home/vagrant/.ssh/config

wget --no-check-certificate https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys

chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod -R 600 /home/vagrant/.ssh/*
