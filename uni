#!/bin/bash

# This script will uninstall kubeadm and related Kubernetes components from the node

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root or with sudo" 
  exit 1
fi

echo "Uninstalling kubeadm and Kubernetes components..."

# Step 1: Drain the node if it's a worker node (optional)
# Uncomment the following lines if you're working with worker nodes and wish to drain them
# kubectl drain $(hostname) --ignore-daemonsets --delete-local-data
# kubectl uncordon $(hostname)

# Step 2: Reset kubeadm (this will undo the kubeadm init or kubeadm join)
kubeadm reset -f

# Step 3: Remove Kubernetes-related packages (kubelet, kubeadm, kubectl, etc.)
apt-get purge -y kubeadm kubectl kubelet kubernetes-cni kube* 

# Step 4: Remove the Docker and containerd packages (if installed and used by Kubernetes)
# If you're using Docker, uncomment the next line:
# apt-get purge -y docker.io docker-ce docker-ce-cli containerd.io

# Step 5: Remove any residual Kubernetes directories
rm -rf ~/.kube
rm -rf /etc/kubernetes
rm -rf /var/lib/etcd
rm -rf /var/lib/kubelet
rm -rf /etc/cni
rm -rf /opt/cni
rm -rf /etc/systemd/system/kubelet.service.d

# Step 6: Flush iptables and remove any networking rules created by Kubernetes
iptables -F
iptables -t nat -F
iptables -t mangle -F

# Step 7: Disable and stop kubelet service
systemctl stop kubelet
systemctl disable kubelet

# Step 8: Reboot the system to ensure everything is cleaned up properly
echo "Uninstallation complete. Rebooting the node..."
reboot
