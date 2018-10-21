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

sysctl -p

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sh -c 'echo "* soft nofile 10000" >> /etc/security/limits.conf'
sh -c 'echo "* hard nofile 10000" >> /etc/security/limits.conf'

if test -f /sys/kernel/mm/transparent_hugepage/enabled; then 
	 echo "never > /sys/kernel/mm/transparent_hugepage/enabled"
	sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled'
fi 

if test -f /sys/kernel/mm/transparent_hugepage/defrag; then 
	echo "never > /sys/kernel/mm/transparent_hugepage/defrag"
	sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/defrag'
fi

cd


#################################################################################
# INSTALLING SALT-MASTER
#################################################################################
yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm 
yum install -y salt-master
systemctl enable salt-master
systemctl start salt-master

#################################################################################
# INSTALLING AMBARI-SERVER
#################################################################################
yum-config-manager --add-repo http://public-repo-1.hortonworks.com/ambari/${OS_TYPE}/2.x/updates/2.7.0.0/ambari.repo
yum-config-manager --add-repo http://public-repo-1.hortonworks.com/HDP/${OS_TYPE}/3.x/updates/3.0.1.0/hdp.repo
yum update -y

# Install Essentials
# yum install -y epel-release wget curl
yum install -y wget curl
yum install -y ntp
systemctl enable ntpd
systemctl start ntpd

echo "HOSTNAME=$(hostname)" >> /etc/sysconfig/network

if [ ${OS_TYPE} = "amazonlinux2" ]; then
    echo "Amazon Linux release 2" > /etc/system-release
    amazon-linux-extras install -y postgresql9.6
# else
#     yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm
fi

yum install -y ambari-server

yum install java-1.8.0-openjdk -y
ambari-server setup -j /usr/lib/jvm/jre-1.8.0 -s

yum install -y postgresql-jdbc
ambari-server setup --jdbc-db=postgres --jdbc-driver=/usr/share/java/postgresql-jdbc.jar

# INSTALL HDF MPACK
wget http://public-repo-1.hortonworks.com/HDF/${OS_TYPE}/3.x/updates/3.2.0.0/tars/hdf_ambari_mp/hdf-ambari-mpack-3.2.0.0-520.tar.gz

ambari-server install-mpack \
--mpack=./hdf-ambari-mpack-3.2.0.0-520.tar.gz \
--verbose -s && rm ./hdf-ambari-mpack-3.2.0.0-520.tar.gz

sed -i.bak 's/ambari/ranger,rangerkms,oozie,druid,hive,superset,registry,streamline,ambari/g' /var/lib/pgsql/data/pg_hba.conf

sudo -u postgres bash -c "psql <<EOF
CREATE DATABASE ranger;
CREATE USER rangeradmin WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE "ranger" to rangeradmin;
--
CREATE DATABASE rangerkms;
CREATE USER rangerkms WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE "rangerkms" to rangerkms;
--
CREATE DATABASE oozie;
CREATE USER oozie WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE "oozie" to oozie;
--
CREATE DATABASE druid;
CREATE USER druid WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE "druid" to druid;
--
CREATE DATABASE hive;
CREATE USER hive WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE "hive" to hive;
--
CREATE DATABASE superset;
CREATE USER superset WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE "superset" to superset;
--
CREATE DATABASE registry;
CREATE USER registry WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE "registry" to registry;
--
CREATE DATABASE streamline;
CREATE USER streamline WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE "streamline" to streamline;
EOF
"


systemctl enable postgresql
systemctl restart postgresql
systemctl enable ambari-server
systemctl restart ambari-server

yum install -y ambari-agent
