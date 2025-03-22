#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try: sudo $0"
    exit 1
fi

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Fix Google Chrome GPG key issue
if ! test -f /etc/apt/trusted.gpg.d/google-chrome.asc; then
    echo "Adding Google Chrome GPG key..."
    wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/trusted.gpg.d/google-chrome.asc
else
    echo "Google Chrome GPG key already exists, skipping."
fi

# Update package lists
echo "Updating package list..."
apt update -q 

# Show upgradable packages
echo "Checking for upgradable packages..."
UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -v "Listing..." || true)

if [ -z "$UPGRADABLE" ]; then
    echo "All packages are up to date. Skipping upgrade."
else
    echo "Upgradable packages found:"
    echo "$UPGRADABLE"
    echo "Upgrading packages..."
    apt upgrade -y 
fi

# List of required packages
REQUIRED_PACKAGES=(
    nvtop
    sudo
    curl
    htop
    systemd
    fonts-noto-color-emoji
    git
    nano
    jq
    screen
    net-tools
    lsof
)

# Install required packages
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! is_installed "$pkg"; then
        echo "❌ $pkg is not installed. Installing $pkg..."
        apt install -y "$pkg"
    else
        echo "✅ $pkg is already installed, skipping."
    fi
done

echo "✅ All required packages have been installed or updated."

# Function to install CUDA Toolkit 12.8
install_cuda() {
    echo "📥 Downloading CUDA keyring..."
    wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb || { echo "❌ Failed to download CUDA keyring"; exit 1; }

    echo "🔧 Installing CUDA keyring..."
    dpkg -i cuda-keyring_1.1-1_all.deb || { echo "❌ Failed to install CUDA keyring"; exit 1; }

    echo "🔄 Updating package lists..."
    apt-get update || { echo "❌ Failed to update package list"; exit 1; }

    echo "🚀 Installing CUDA Toolkit 12.8..."
    apt-get -y install cuda-toolkit-12-8 || { echo "❌ Failed to install CUDA Toolkit"; exit 1; }

    echo "✅ CUDA installation complete!"
}

# Main execution
install_cuda
