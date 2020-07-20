


install-vagrant:
	brew cask install vagrant
	touch install-vagrant

install-vagrant-plugins: install-vagrant
	vagrant plugin install vagrant-aws
	vagrant plugin install vagrant-hostmanager
	touch install-vagrant-plugins

start-vms: install-vagrant-plugins
	vagrant up
	vagrant hostmanager

stop-vms:
	vagrant halt
	sudo sed -i '' -E '/confluent.local|vagrant-hostmanager/d' /etc/hosts

teardown-vms:
	vagrant destroy --force
	rm ldap-playbook

ldap-playbook:
	ansible-playbook -i provisioning/hosts.yml provisioning/ldap.yml
	touch ldap-playbook

download-cp-ansible:
	git subtree add --prefix provisioning/cp-ansible https://github.com/confluentinc/cp-ansible master --squash

run-all-playbook: ldap-playbook
	ansible-playbook -i provisioning/hosts.yml provisioning/cp-ansible/all.yml -v

ping:
	ansible -i provisioning/hosts.yml all -m ping


list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
