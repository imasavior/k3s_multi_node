#!/bin/bash

set -e  # Exit on any error

# 定義顏色
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}[*] Uninstalling K3s if exists...${NC}"
/usr/local/bin/k3s-uninstall.sh || echo -e "${YELLOW}[!] K3s not installed or uninstall failed.${NC}"

echo -e "${BLUE}[*] Installing K3s...${NC}"
curl -sfL https://get.k3s.io | sh -s - server --node-name k3s-master

echo -e "${BLUE}[*] Preparing kubeconfig directory...${NC}"
rm -rf /home/ubuntu/.k3s
mkdir -p /home/ubuntu/.k3s

echo -e "${BLUE}[*] Copying kubeconfig...${NC}"
sudo cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.k3s/k3s.yaml
sudo chown ubuntu:ubuntu /home/ubuntu/.k3s/k3s.yaml
sudo chmod 777 /home/ubuntu/.k3s/k3s.yaml

echo -e "${BLUE}[*] Installing Helm...${NC}"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

KUBE_LINE='export KUBECONFIG=$HOME/.k3s/k3s.yaml'
if ! grep -qxF "$KUBE_LINE" /home/ubuntu/.bashrc; then
  echo "$KUBE_LINE" >> /home/ubuntu/.bashrc
  echo -e "${GREEN}[*] Added KUBECONFIG to .bashrc${NC}"
fi

# 加入 kubectl 簡寫 alias
ALIAS_LINE="alias k=kubectl"
if ! grep -qxF "$ALIAS_LINE" /home/ubuntu/.bashrc; then
  echo "$ALIAS_LINE" >> /home/ubuntu/.bashrc
  echo -e "${GREEN}[*] Added alias k=kubectl to .bashrc${NC}"
fi

echo -e "${BLUE}[*] Sourcing .bashrc...${NC}"
source /home/ubuntu/.bashrc

echo -e "${CYAN}[*] Installing Elastic Cloud on Kubernetes (ECK) Operator ...${NC}"
kubectl create -f https://download.elastic.co/downloads/eck/3.1.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/3.1.0/operator.yaml

echo -e "${GREEN}[✔] K3s, Helm, and ECK Operator installation complete.${NC}"

rm -rf kube-flannel.yml
echo -e "${CYAN}[*] Downloading Flannel YAML...${NC}"
wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

echo -e "${BLUE}[*] Waiting 60 seconds for ECK components to start...${NC}"
sleep 60
kubectl get po -A

echo -e "${YELLOW}========== Master Token ==========${NC}"
sudo cat /var/lib/rancher/k3s/server/node-token
echo -e "${YELLOW}==================================${NC}"

# 印出加入指令
echo ""
MASTER_IP=$(hostname -I | awk '{print $1}')
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
echo -e "${GREEN}🚀 請在其他節點執行以下指令加入 cluster：${NC}"
echo -e "/usr/local/bin/k3s-agent-uninstall.sh"
echo -e "${CYAN}curl -sfL https://get.k3s.io | K3S_URL=https://${MASTER_IP}:6443 K3S_TOKEN=${TOKEN} K3S_NODE_NAME=vm sh -${NC}"
source ~/.bashrc
