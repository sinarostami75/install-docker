# install-docker
Script for install docker 
## 🎥 Video Tutorial

A step-by-step video walkthrough of this project is available on YouTube:  
👉 https://youtu.be/HTRxW7JWz8Q

The video explains how to use the script and shows the full installation process in real time.

### Docker Installation Script for Ubuntu

This script automates the installation of Docker on Ubuntu-based systems. It checks whether Docker is already installed, and if not, it installs Docker along with its required dependencies.
Features

    Docker check: The script first checks if Docker is already installed on the system. If Docker is found, the script will exit without making any changes.
    System update: Updates the package list to ensure the system is up-to-date before proceeding with the installation.
    Install prerequisites: Installs necessary tools and packages required for Docker installation, such as apt-transport-https, ca-certificates, curl, and software-properties-common.
    Add Docker GPG key: Downloads and adds the official Docker GPG key to verify Docker packages.
    Add Docker repository: Adds the Docker repository to your APT sources list so you can install the latest Docker packages.
    Install Docker: Installs Docker and related components (docker-ce, docker-ce-cli, containerd.io) on the system.
    Enable Docker: Enables Docker to start automatically with the system and starts the Docker service.
    Verify installation: After installation, the script verifies that Docker has been installed correctly by checking its version.

Requirements

    Ubuntu 18.04 or higher
    Internet connection to download Docker packages
    Root or sudo privileges to install packages

Installation Steps

    Open a terminal on your Ubuntu machine.
    Copy the script into a new .sh file, for example install_docker.sh.
    Give the script execute permissions:

chmod +x install_docker.sh

Run the script:

    ./install_docker.sh

Notes

    The script automatically handles the entire Docker installation process, including adding the Docker repository and GPG key.
    If Docker is already installed, the script will exit and notify you that Docker is already present on your system.

Troubleshooting

    If the script encounters an error during installation, ensure your system’s package lists are updated, and try running the script again.

License

This script is open source. Feel free to modify or distribute it as needed.
