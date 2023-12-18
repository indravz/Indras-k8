
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "k8_sg" {
  name        = "k8-sgroup"
  description = "Security group for Kubernetes master node"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.security_group_cidr]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]  # Allow traffic from Default VPC CIDR
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.security_group_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.security_group_cidr]
  }

  tags = {
    Name = "k8-sg"
  }
}


resource "aws_key_pair" "kubernetes_keypair" {
  key_name   = "k8_keypair"
  public_key = var.public_key
}

resource "aws_instance" "k8_master" {
  ami           = "ami-07b36ea9852e986ad"
  instance_type = "t2.medium"
  key_name      = aws_key_pair.kubernetes_keypair.key_name  # Provide the key pair name

  security_groups = [aws_security_group.k8_sg.name]

  tags = {
    Name = "k8-master-1"
  }

  root_block_device {
    volume_size = 30  # 30 GB storage
    volume_type = "gp2"
  }

  user_data = <<-EOF
              #!/bin/bash

              # Update packages
              sudo apt update
              sudo apt-get update && sudo apt-get upgrade -y

              # Add Kubernetes repository
              echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

              # Install necessary packages
              sudo apt-get install -y apt-transport-https curl
              curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
              sudo apt-get update
              sudo apt-get install -y vim git curl wget kubelet kubeadm kubectl
              sudo apt-mark hold kubelet kubeadm kubectl

              # Disable firewall
              sudo ufw disable

              # Disable swap
              sudo swapoff -a
              sudo sed -i '/swap/d' /etc/fstab

              # Install CRI dependencies
              sudo tee /etc/modules-load.d/containerd.conf <<EOF1
              overlay
              br_netfilter
              EOF1

              sudo modprobe overlay
              sudo modprobe br_netfilter

              sudo tee /etc/sysctl.d/kubernetes.conf<<EOF2
              net.bridge.bridge-nf-call-ip6tables = 1
              net.bridge.bridge-nf-call-iptables = 1
              net.ipv4.ip_forward = 1
              EOF2

              sudo sysctl --system

              # Install Docker
              sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt update
              sudo apt install -y docker-ce

              # Install containerd
              sudo apt install -y containerd.io
              sudo mkdir -p /etc/containerd
              sudo containerd config default | sudo tee /etc/containerd/config.toml

              sudo systemctl restart containerd
              sudo systemctl enable containerd

              sudo systemctl enable kubelet

              # Setup control plane
              sudo kubeadm config images pull --cri-socket unix:///run/containerd/containerd.sock
              sudo kubeadm init --apiserver-advertise-address=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=all

              mkdir -p $HOME/.kube
              sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
              sudo chown $(id -u):$(id -g) $HOME/.kube/config

              kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
              kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml

              sudo kubeadm token create --print-join-command > /home/ubuntu/join_worker.sh
              EOF
}

resource "aws_instance" "k8_worker_1" {
  ami           = "ami-07b36ea9852e986ad"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.kubernetes_keypair.key_name  # Provide the key pair name

  security_groups = [aws_security_group.k8_sg.name]

  tags = {
    Name = "k8-worker-1"
  }

  root_block_device {
    volume_size = 15  # 15 GB storage
    volume_type = "gp2"
  }

  user_data = <<-EOF
              #!/bin/bash

              # Update packages
              sudo apt update
              sudo apt-get update && sudo apt-get upgrade -y

              # Add Kubernetes repository
              echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

              # Install necessary packages
              sudo apt-get install -y apt-transport-https curl
              curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
              sudo apt-get update
              sudo apt-get install -y vim git curl wget kubelet kubeadm kubectl
              sudo apt-mark hold kubelet kubeadm kubectl

              # Disable firewall
              sudo ufw disable

              # Disable swap
              sudo swapoff -a
              sudo sed -i '/swap/d' /etc/fstab

              # Install CRI dependencies
              sudo tee /etc/modules-load.d/containerd.conf <<EOF1
              overlay
              br_netfilter
              EOF1

              sudo modprobe overlay
              sudo modprobe br_netfilter

              sudo tee /etc/sysctl.d/kubernetes.conf<<EOF2
              net.bridge.bridge-nf-call-ip6tables = 1
              net.bridge.bridge-nf-call-iptables = 1
              net.ipv4.ip_forward = 1
              EOF2

              sudo sysctl --system

              # Install Docker
              sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt update
              sudo apt install -y docker-ce

              # Install containerd
              sudo apt install -y containerd.io
              sudo mkdir -p /etc/containerd
              sudo containerd config default | sudo tee /etc/containerd/config.toml

              sudo systemctl restart containerd
              sudo systemctl enable containerd
              EOF
}

resource "aws_instance" "k8_worker_2" {
  ami           = "ami-07b36ea9852e986ad"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.kubernetes_keypair.key_name  # Provide the key pair name

  security_groups = [aws_security_group.k8_sg.name]

  tags = {
    Name = "k8-worker-2"
  }

  root_block_device {
    volume_size = 15  # 15 GB storage
    volume_type = "gp2"
  }

  user_data = <<-EOF
              #!/bin/bash

              # Update packages
              sudo apt update
              sudo apt-get update && sudo apt-get upgrade -y

              # Add Kubernetes repository
              echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

              # Install necessary packages
              sudo apt-get install -y apt-transport-https curl
              curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
              sudo apt-get update
              sudo apt-get install -y vim git curl wget kubelet kubeadm kubectl
              sudo apt-mark hold kubelet kubeadm kubectl

              # Disable firewall
              sudo ufw disable

              # Disable swap
              sudo swapoff -a
              sudo sed -i '/swap/d' /etc/fstab

              # Install CRI dependencies
              sudo tee /etc/modules-load.d/containerd.conf <<EOF1
              overlay
              br_netfilter
              EOF1

              sudo modprobe overlay
              sudo modprobe br_netfilter

              sudo tee /etc/sysctl.d/kubernetes.conf<<EOF2
              net.bridge.bridge-nf-call-ip6tables = 1
              net.bridge.bridge-nf-call-iptables = 1
              net.ipv4.ip_forward = 1
              EOF2

              sudo sysctl --system

              # Install Docker
              sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt update
              sudo apt install -y docker-ce

              # Install containerd
              sudo apt install -y containerd.io
              sudo mkdir -p /etc/containerd
              sudo containerd config default | sudo tee /etc/containerd/config.toml

              sudo systemctl restart containerd
              sudo systemctl enable containerd
              EOF
}