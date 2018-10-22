# Vagrant Requirements on Ubuntu

```
wget https://releases.hashicorp.com/vagrant/2.1.5/vagrant_2.1.5_x86_64.deb
sudo dpkg -i ./vagrant_2.1.5_x86_64.deb
sudo vagrant plugin install vagrant-hostmanager  
vagrant plugin install vagrant-vbguest
``` 

# Centos Virtual Box

```
vagrant box add centos7 http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1809_01.VirtualBox.box
```

# Start the Cluster

```
vagrant up
```

# Ambari URL

On your Laptop type:

http://hdp-ambari.hortonworks.local:8080/

For the ssh use:

```
username: vagrant
``` 

# Building the boxes

```
vagrant package --base ambari-server --output ambari-server.box
vagrant package --base ambari-node --output ambari-node.box
```

# Add Boxes

```
vagrant box add ambari-server ambari-server.box
vagrant box add ambari-agent ambari-node.box
rm ambari-*
```


