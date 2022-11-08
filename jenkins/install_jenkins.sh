#!/bin/bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt install openjdk-11-jdk jenkins python3-virtualenv ansible-core -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
git clone https://github.com/kubernetes-sigs/kubespray.git
VENVDIR=kubespray-venv
KUBESPRAYDIR=~/kubespray
ANSIBLE_VERSION=2.12
virtualenv  --python=$(which python3) $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR
pip install -U -r requirements-$ANSIBLE_VERSION.txt
test -f requirements-$ANSIBLE_VERSION.yml && \
  ansible-galaxy role install -r requirements-$ANSIBLE_VERSION.yml && \
  ansible-galaxy collection -r requirements-$ANSIBLE_VERSION.yml
cp -rfp inventory/sample inventory/diplom-netology
curl -o $KUBESPRAYDIR/inventory/diplom-netology/group_vars/k8s_cluster/addons.yml https://storage.yandexcloud.net/devops-diplom-yandexcloud/addons.yml
curl -o $KUBESPRAYDIR/inventory/diplom-netology/inventory.ini https://storage.yandexcloud.net/devops-diplom-yandexcloud/inventory.ini
curl -o ~/.ssh/id_rsa https://storage.yandexcloud.net/devops-diplom-yandexcloud/id_rsa
chmod 600 ~/.ssh/id_rsa
declare -a IPS=(10.255.255.20 10.255.255.22 10.255.255.21 10.255.255.23)
CONFIG_FILE=inventory/diplom-netology/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
ansible-playbook -i inventory/diplom-netology/hosts.yaml  --become --become-user=root cluster.yml