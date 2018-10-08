varRamAmbari=2048
varRamMan=4096
varRamNode=4096

varDomain = "hortonworks.local"

varAmbariServer = "hdp-ambari"
varManagerServer = "hdp-manager"
varNodeServer = "hdp-node"


hdp_nodes = [
	{ :host => "#{varAmbariServer}",  :ip => "10.10.67.10", :box => "centos7", :ram => varRamAmbari, :cpu => 2, :gui => false },
	{ :host => "#{varManagerServer}",  :ip => "10.10.67.11", :box => "centos7", :ram => varRamMan, :cpu => 2, :gui => false },
	{ :host => "#{varNodeServer}",  :ip => "10.10.67.12", :box => "centos7", :ram => varRamNode, :cpu => 2, :gui => false },
]

## ################################################################
## START - HOSTS FOR GUESTS
## ################################################################
varHostEntries = ""
hdp_nodes.each do |hdp_node|
	varHostEntries << "#{hdp_node[:ip]} #{hdp_node[:host]}.#{varDomain} #{hdp_node[:host]}\n"
end

puts varHostEntries

$etchosts = <<SCRIPT
#!/bin/bash
cat > /etc/hosts <<EOF
127.0.0.1       localhost
10.10.67.1      host.#{varDomain} host
#{varHostEntries}
EOF
SCRIPT
## ################################################################
## END - HOSTS FOR GUESTS
## ################################################################


Vagrant.configure("2") do |config|

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = false
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  hdp_nodes.each do |hdp_node|
	config.vm.define hdp_node[:host] do |hdp_config|
		hdp_config.vm.box = hdp_node[:box]
		hdp_config.vm.hostname = "#{hdp_node[:host]}.#{varDomain}"
		hdp_config.vm.network "private_network", ip: hdp_node[:ip], :netmask => "255.255.255.0"
		hdp_config.hostmanager.aliases = "#{hdp_node[:host]}"
		hdp_config.vm.provider :virtualbox do |v|
			v.name = hdp_node[:host].to_s
			v.gui = hdp_node[:gui]
			v.customize ["modifyvm", :id, "--memory", hdp_node[:ram].to_s]
			v.customize ["modifyvm", :id, "--cpus", hdp_node[:cpu].to_s]
		end

		#hdp_config.vm.synced_folder ".", "/vagrant"
		#hdp_config.ssh.private_key_path = "~/.vagrant.d/insecure_private_key"
		hdp_config.ssh.forward_agent = true
		hdp_config.vm.provision :shell, :inline => $etchosts


		if hdp_node[:host] == varAmbariServer
 			puts "Bootstrapping AMBARI...."
			hdp_config.vm.provision :shell, privileged: true, path: "user_data/bootstrap-ambari.sh", env: {"OS_TYPE" => "centos7", "AMBARI_SERVER" => '#{varAmbariServer}'}
			hdp_config.vm.network "forwarded_port", guest: 8080, host: 8080
		else		
			puts "Bootstrapping NODE...."
			hdp_config.vm.provision :shell, privileged: true, path: "user_data/bootstrap-node.sh", env: {"OS_TYPE" => "centos7","AMBARI_SERVER" => '#{varAmbariServer}'}
		end

		public_key = File.read("ssh/id_rsa.pub")
		private_key = File.read("ssh/id_rsa")

		hdp_config.vm.provision :shell, privileged: true, path: "ssh/ssh-setup.sh", 
					env: {"PUB_KEY" => '#{public_key}',"PRIV_KEY" => '#{private_key}',"AMBARI_SERVER" => '#{varAmbariServer}'}

		'#{varAmbariServer}'
	end
  end
end
