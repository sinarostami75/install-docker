#!/bin/bash

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "Docker is already installed. Exiting."
    exit 0
fi

echo "Updating packages..."
sudo apt update -y

echo "Installing prerequisites..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Adding Docker repository..."
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
EOF

echo "Updating package list..."
sudo apt update -y

echo "Installing Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io

echo "Enabling and starting Docker..."
sudo systemctl enable --now docker

echo "Verifying Docker installation..."
docker --version && echo "Docker installation completed!" || echo "Docker installation failed!"

