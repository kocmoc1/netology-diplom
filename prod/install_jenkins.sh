#!/bin/bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release  
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install openjdk-11-jdk jenkins python3-virtualenv ansible-core docker-ce docker-ce-cli containerd.io -y
sudo snap install kubectl --classic
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
ssh 10.255.255.20 sudo cat /etc/kubernetes/admin.conf >  $HOME/.kube/config
sed -i 's/127.0.0.1/10.255.255.20/g' $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml

wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml
mv deploy.yaml nginx-ingress-controller-deploy.yaml


# vim external-ips.yaml
# spec:
#   externalIPs:
#   - 192.168.42.245
#   - 192.168.42.246
# kubectl -n ingress-nginx patch svc ingress-nginx-controller --patch "$(cat external-ips.yaml)"
# 
# https://itsecforu.ru/2021/11/15/%E2%98%B8%EF%B8%8F-%D1%80%D0%B0%D0%B7%D0%B2%D0%B5%D1%80%D1%82%D1%8B%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BE%D0%BD%D1%82%D1%80%D0%BE%D0%BB%D0%BB%D0%B5%D1%80%D0%B0-nginx-ingress-%D0%BD%D0%B0-kubernet/