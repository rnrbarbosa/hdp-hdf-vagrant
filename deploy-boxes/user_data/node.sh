#!/bin/bash

cp /etc/ambari-agent/conf/ambari-agent.ini /etc/ambari-agent/conf/ambari-agent.ini.bak
cd /etc/ambari-agent/conf
sed -i.bak s/hostname=localhost/hostname=${AMBARI_SERVER:-master1}/g /etc/ambari-agent/conf/ambari-agent.ini

systemctl enable ambari-agent
systemctl restart ambari-agent