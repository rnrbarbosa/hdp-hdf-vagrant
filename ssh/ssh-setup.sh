#!/bin/bash

# SSH KEYS CONFIG
echo 'Copying ansible-vm public SSH Keys to the VM'
chmod 700 /home/vagrant/.ssh
echo ${PUB_KEY} >> /home/vagrant/.ssh/authorized_keys
echo ${PRIV_KEY} >> /home/vagrant/.ssh/id_rsa
echo 'Host *' >> /home/vagrant/.ssh/config
echo 'StrictHostKeyChecking no' >> /home/vagrant/.ssh/config
echo 'UserKnownHostsFile /dev/null' >> /home/vagrant/.ssh/config
chown vagrant:vagrant .ssh/id_rsa .ssh/config
chmod -R 600 /home/vagrant/.ssh/*

# AMBARI-AGENT config
cd /etc/ambari-agent/conf
cp ambari-agent.ini ambari-agent.ini.bak
sed -i.bak s/hostname=localhost/hostname=${AMBARI_SERVER}.hortonworks.local/g ambari-agent.ini
ambari-agent restart