#!/bin/bash

#################################################################################
# OS SETTINGS
#################################################################################

echo umask 0022 >> /etc/profile

cd /etc
cp -rf sysctl.conf sysctl.conf.bak

sh -c "echo '' >> /etc/sysctl.conf"
sh -c "echo '# Ephemeral ports' >> /etc/sysctl.conf"
sh -c "echo 'net.ipv4.ip_local_port_range = 41000 65000' >> /etc/sysctl.conf"
sh -c "echo '' >> /etc/sysctl.conf"
sh -c "echo '# TCP buffers' >> /etc/sysctl.conf"
sh -c "echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf"
sh -c "echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf"
sh -c "echo 'net.ipv4.tcp_rmem = 4095 87380 16777216' >> /etc/sysctl.conf"
sh -c "echo 'net.ipv4.tcp_wmem = 4095 65536 16777216' >> /etc/sysctl.conf"
sh -c "echo '' >> /etc/sysctl.conf"
sh -c "echo '# Decrease swappiness' >> /etc/sysctl.conf"
sh -c "echo 'vm.swappiness = 5' >> /etc/sysctl.conf"
sh -c "echo '' >> /etc/sysctl.conf"

# These entries causes errors on running sysctl -p. comment out.
# Disable netfilter on bridges.
sed -i.bak s/net.bridge.bridge-nf-call/#net.bridge.bridge-nf-call-/g /etc/sysctl.conf


sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo sh -c 'echo "* soft nofile 10000" >> /etc/security/limits.conf'
sudo sh -c 'echo "* hard nofile 10000" >> /etc/security/limits.conf'

if test -f /sys/kernel/mm/transparent_hugepage/enabled; then 
	 echo "never > /sys/kernel/mm/transparent_hugepage/enabled"
	sudo sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
fi 

if test -f /sys/kernel/mm/transparent_hugepage/defrag; then 
	echo "never > /sys/kernel/mm/transparent_hugepage/defrag"
	sudo sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'
fi

#################################################################################
# INSTALLING SALT-MINION
#################################################################################
yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm 
yum install -y salt-minion
systemctl enable salt-minion
systemctl start salt-minion

#################################################################################
# INSTALLING AMBARI-AGENT
#################################################################################
yum-config-manager --add-repo http://public-repo-1.hortonworks.com/ambari/${OS_TYPE}/2.x/updates/2.7.0.0/ambari.repo
yum-config-manager --add-repo http://public-repo-1.hortonworks.com/HDP/${OS_TYPE}/3.x/updates/3.0.1.0/hdp.repo
yum update -y

echo "HOSTNAME=$(hostname)" >> /etc/sysconfig/network

yum install java-1.8.0-openjdk -y

echo "HOSTNAME=$(hostname)" >> /etc/sysconfig/network

if [[ ${OS_TYPE} == "amazonlinux2" ]]; then
    echo "Amazon Linux release 2" > /etc/system-release
fi

# Install Essentials
yum install -y epel-release wget curl
yum install -y ntp
systemctl enable ntpd
systemctl start ntpd


yum install -y ambari-agent

# cd /etc/ambari-agent/conf
# cp /etc/ambari-agent/conf/ambari-agent.ini /etc/ambari-agent/conf/ambari-agent.ini.bak
# sed -i.bak s/hostname=localhost/hostname=${AMBARI_SERVER}/g /etc/ambari-agent/conf/ambari-agent.ini

# systemctl enable ambari-agent
# systemctl restart ambari-agent
