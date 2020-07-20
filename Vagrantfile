# Require the AWS provider plugin
require 'vagrant-aws'

class Hash
  def slice(*keep_keys)
    h = {}
    keep_keys.each { |key| h[key] = fetch(key) if has_key?(key) }
    h
  end unless Hash.method_defined?(:slice)
  def except(*less_keys)
    slice(*keys - less_keys)
  end unless Hash.method_defined?(:except)
end

$cached_addresses = {}
# There is a bug when using virtualbox/dhcp which makes hostmanager not find
# the proper IP, only the loop one: https://github.com/smdahlen/vagrant-hostmanager/issues/86
# The following custom resolver (for linux guests) is a good workaround.
# Furthermore it handles aws private/public IP.
 
# A limitation (feature?) is that hostmanager only looks at the current provider.
# This means that if you `up` an aws vm, then a virtualbox vm, all aws ips
# will disappear from your host /etc/hosts.
# To prevent this, apply this patch to your hostmanager plugin (1.6.1), probably
# at $HOME/.vagramt.d/gems/gems or (hopefully) wait for newer versions.
# https://github.com/smdahlen/vagrant-hostmanager/pull/169
$ip_resolver = proc do |vm, resolving_vm|
  
# For aws, we should use private IP on the guests, public IP on the host
  if vm.provider_name == :aws
    if resolving_vm.nil?
      used_name = vm.name.to_s + '--host'
    else
      used_name = vm.name.to_s + '--guest'
    end
  else
    used_name= vm.name.to_s
  end
 
  if $cached_addresses[used_name].nil?
    if hostname = (vm.ssh_info && vm.ssh_info[:host])
      
      # getting aws guest ip *for the host*, we want the public IP in that case.
      if vm.provider_name == :aws and resolving_vm.nil?

        vm.communicate.execute('curl -s http://169.254.169.254/latest/meta-data/public-ipv4') do |type, pubip|
          $cached_addresses[used_name] = pubip
        end
      else
 
        vm.communicate.execute('uname -o') do |type, uname|
          unless uname.downcase.include?('linux')
            warn("Guest for #{vm.name} (#{vm.provider_name}) is not Linux, hostmanager might not find an IP.")
          end
        end
 
        vm.communicate.execute('hostname --all-ip-addresses') do |type, hostname_i|
          # much easier (but less fun) to work in ruby than sed'ing or perl'ing from shell
 
          allips = hostname_i.strip().split(' ')
          if vm.provider_name == :virtualbox
            # 10.0.2.15 is the default virtualbox IP in NAT mode.
            allips = allips.select { |x| x != '10.0.2.15'}
          end
 
          if allips.size() == 0
            warn("Trying to find out ip for #{vm.name} (#{vm.provider_name}), found none useable: #{allips}.")
          else
            if allips.size() > 1
              warn("Trying to find out ip for #{vm.name} (#{vm.provider_name}), found too many: #{allips} and I cannot choose cleverly. Will select the first one.")
            end
            $cached_addresses[used_name] = allips[0]
          end
        end
      end
    end
  end
  $cached_addresses[used_name]
end


# Create and configure the AWS instance(s)
Vagrant.configure('2') do |config|

  # Use dummy AWS box
  config.vm.box = 'aws-dummy'
  config.hostmanager.enabled = false
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.ip_resolver = $ip_resolver
 
  config.vm.allowed_synced_folder_types = [:rsync]

  config.vm.define "zookeeper1.confluent.local" do |node|
    node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar zk 1', 'Owner': 'Sarwar Bhuiyan'}
    end
  end

  config.vm.define "zookeeper2.confluent.local" do |node|
    node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar zk 2', 'Owner': 'Sarwar Bhuiyan'}
    end
  end


  config.vm.define "zookeeper3.confluent.local" do |node|
    node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar zk 3', 'Owner': 'Sarwar Bhuiyan'}
    end
  end

  config.vm.define "kafka1.confluent.local" do |node|
    node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar kafka 1', 'Owner': 'Sarwar Bhuiyan'}
        aws.instance_type = "t2.small"
        aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 100 }]

    end
  end

  config.vm.define "kafka2.confluent.local" do |node|
     node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar kafka 2', 'Owner': 'Sarwar Bhuiyan'}
        aws.instance_type = "t2.small"
        aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 100 }]
    end
  end

  config.vm.define "kafka3.confluent.local" do |node|
     node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar kafka 3', 'Owner': 'Sarwar Bhuiyan'}
        aws.instance_type = "t2.small"
        aws.block_device_mapping = [{ 'DeviceName' => '/dev/sda1', 'Ebs.VolumeSize' => 100 }]
    end
  end

  config.vm.define "c3.confluent.local" do |node|
     node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar control center', 'Owner': 'Sarwar Bhuiyan'}
        aws.instance_type = "t2.medium"
    end
  end
  
  config.vm.define "sr.confluent.local" do |node|
     node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar schema registry', 'Owner': 'Sarwar Bhuiyan'}
    end
  end
  
  config.vm.define "ksqldb.confluent.local" do |node|
     node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar ksqldb', 'Owner': 'Sarwar Bhuiyan'}
    end
  end
 
  config.vm.define "connect.confluent.local" do |node|
     node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar kafka connect', 'Owner': 'Sarwar Bhuiyan'}
        aws.instance_type = "t2.small"
    end
  end

  config.vm.define "ldap.confluent.local" do |node|
     node.vm.provider :aws do |aws, override| 
    	aws.tags = { 'Name': 'sarwar ldap', 'Owner': 'Sarwar Bhuiyan'}
        aws.instance_type = "t2.micro"
    end
  end




  # Specify AWS provider configuration
  config.vm.provider 'aws' do |aws, override|
    # Read AWS authentication information from environment variables
    #aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    #aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    # Specify SSH keypair to use
    aws.keypair_name = 'sarwar-confluent-dev'
    # Specify region, AMI ID, and security group(s)
    aws.region = 'eu-west-2'
    aws.ami = 'ami-09e5afc68eed60ef4'
    aws.security_groups = ['sarwar-security-group']

    aws.region_config "us-east-1" do |region|
        region.spot_instance = true
        region.spot_max_price = "0.02"
    end

    aws.instance_type = "t2.micro"

    # Specify username and private key path
    override.ssh.username = 'centos'
    override.ssh.private_key_path = '~/.ssh/sarwar-confluent-dev.pem'
  end
end
