#!/bin/bash

# Execute on Both "Master" & "Worker" Nodes:

# 1. Disable Swap: Required for Kubernetes to function correctly.
echo "Disabling swap..."
sudo swapoff -a
sleep 2

# 2. Load Necessary Kernel Modules: Required for Kubernetes networking.
echo "Loading necessary kernel modules for Kubernetes networking..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
sleep 2

# 3. Set Sysctl Parameters: Helps with networking.
echo "Setting sysctl parameters for networking..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
lsmod | grep br_netfilter
lsmod | grep overlay
sleep 2

# 4. Install Containerd:
echo "Installing containerd..."
sudo apt-get update
sleep 2

sudo apt-get install -y ca-certificates curl
sleep 2

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sleep 2

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sleep 2

sudo apt-get install -y containerd.io
sleep 2

containerd config default | sed -e 's/SystemdCgroup = false/SystemdCgroup = true/' -e 's/sandbox_image = "registry.k8s.io\/pause:3.6"/sandbox_image = "registry.k8s.io\/pause:3.9"/' | sudo tee /etc/containerd/config.toml

sudo systemctl restart containerd
sleep 2

sudo systemctl is-active containerd
sleep 2

# 5. Add Kubernetes APT Repository
echo "Setting up Kubernetes APT repository..."
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /etc/apt/trusted.gpg.d/kubernetes.asc
sleep 2

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sleep 2

# Update package list
sudo apt-get update
sleep 2

# 6. Install Kubernetes Components (kubelet, kubeadm, kubectl) version 1.29.0:
echo "Installing Kubernetes components (kubelet, kubeadm, kubectl) version 1.29.0..."
sudo apt-get install -y kubelet=1.29.0-00 kubeadm=1.29.0-00 kubectl=1.29.0-00
sleep 2

# 7. Mark Kubernetes packages to hold at version 1.29.0
echo "Marking Kubernetes packages on hold to prevent automatic upgrades..."
sudo apt-mark hold kubelet kubeadm kubectl
sleep 2

# 8. Verify Kubernetes installation
echo "Verifying Kubernetes installation..."
kubelet --version
kubeadm version
kubectl version --client

# 9. Completion Message
echo "Kubernetes 1.29.0 setup completed successfully."
