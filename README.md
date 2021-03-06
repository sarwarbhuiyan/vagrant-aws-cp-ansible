# Vagrant, AWS, and cp-ansible example

This project makes it easy to get started with cp-ansible on AWS hosted VMs for a developer working machines temporarily and suspending or tearing them down after a piece of work.

Some features of the project:
1. The project makes use of make, vagrant, aws, and ansible to setup virtual machines on AWS for openldap, zookeeper, kafka, connect, and ksqlDB. 
2. A sample aws inventory file (hosts.yml) which enables SSL, RBAC, and LDAP with some sample users
file is provided for modification. 
2. The vagrant tasks create machines with host names ending with \*.confluent.local and ensures /etc/hosts is updated both locally and on the VMs so
that we can avoid dealing with changing host names to be the AWS host names.
3. An openldap playbook to setup an Openldap server and add some basic users
4. Suspend/teardown commands to save on money when you're done for the day or done forever with those VMs
5. Clones cp-ansible into provisioning/cp-ansible and the user can choose whatever tag they want


## Pre-requisites

1. [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
2. [make](https://www.gnu.org/software/make/) - (comes already built-in on Mac OSX though)
3. AWS Account with credentials stored in ~/.aws/credentials
4. Create an ssh key for your VMs from the AWS Console and download locally to ~/.ssh/

## Configuration

1. The example assumes the user is using AWS eu-west-2 region. Switching to any other region requires changing the region and ami-id in the Vagrant file.

```ruby
    aws.region = 'eu-west-2'
    aws.ami = 'ami-09e5afc68eed60ef4'
```

2. In Vagrantfile, replace "sarwar" with something else to make sure my VM names and tags  don't clash with yours if you're using AWS eu-west-1 on the Confluent SE account.

3. Update provisioning/hosts.yml with your own ssh key for AWS.

```yaml
ansible_ssh_private_key_file: ~/.ssh/sarwar-confluent-dev.pem
```

4. You should consider a different DNS suffix to ".confluent.local". If you do, search/replace ".confluent.local" in Vagrantfile and provisioning/hosts.yml
to the suffix of your choosing. Otherwise, you may end up clashing with mine and it might not be pretty. 


OPTIONAL:

The Make file includes tasks to install vagrant, vagrant-aws, and vagrant-hostmanager which perform a number of functions. If you've already got those,
you can make your startup faster by doing the following to skip installing them.

```bash
$ touch install-vagrant
$ touch install-vagrant-plugins
```

## Start the VMs

```bash
$ make start-vms
```

You will be asked to provide your password to update your local /etc/hosts file 


## Setup OpenLDAP with sample data

```bash
$ make ldap-playbook
```

## Setup confluent platform

cp-ansible is already available in provisioning using git subtree. If you want update that tree

```bash
$ make run-all-playbook
```

## Access C3

Open a browser to https://c3.confluent.local (or whatever other suffix you used when you updated Vagrantfile and provisioning/hosts.yml)

## Suspend all VMs for the day

```bash
$ make stop-vms
```

## Teardown all VMs

```bash
$ make teardown-vms
```


## Teardown individual vm and update hosts

Sometimes you might need to teardown an individual VM only and update the hosts files

```bash
$ vagrant destroy <name of vm> # (e.g. c3.confluent.local)
$ vagrant hostmanager
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.


## License
[Apache 2](https://choosealicense.com/licenses/apache-2.0/)
