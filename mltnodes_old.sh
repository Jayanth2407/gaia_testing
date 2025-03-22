#!/bin/bash

# Exit on error and log all output
set -e
trap "echo 'Script interrupted. Exiting...'; exit 1" SIGINT SIGTERM
LOG_FILE="gaia_node_manager.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Display banner
printf "\n"
cat <<EOF

██╗░░██╗░█████╗░░██████╗██╗░░██╗████████╗░█████╗░░██████╗░
██║░░██║██╔══██╗██╔════╝██║░░██║╚══██╔══╝██╔══██╗██╔════╝░
███████║███████║╚█████╗░███████║░░░██║░░░███████║██║░░██╗░
██╔══██║██╔══██║░╚═══██╗██╔══██║░░░██║░░░██╔══██║██║░░╚██╗
██║░░██║██║░░██║██████╔╝██║░░██║░░░██║░░░██║░░██║╚██████╔╝
╚═╝░░╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝░╚═════╝░

##########################################################################################
#                                                                                        #
#                🚀 THIS SCRIPT IS CREATED BY **HASHTAG**! 🚀                           #
#                                                                                        #
#       🌐 Join our revolution in decentralized networks and crypto innovation!          #
#                                                                                        #
# 📢 Stay updated:                                                                       #
#     • Dm me on Telegram: https://t.me/Jayanth24                                        #
##########################################################################################

EOF

# Add some space after the banner
printf "\n\n"

# Green color for advertisement
GREEN="\033[0;32m"
RESET="\033[0m"

# Backup file path
backup_file="$HOME/nodes_backup.json"

# Usage Example:
IS_WSL=false  # Set to true if using WSL

# Function to display the menu
show_menu() {
    echo ""
    echo "🌌 Welcome to the Gaia Node Manager! - Made by HASHTAG"
    echo "🌌 For Doubts, Dm me on Telegram: https://t.me/Jayanth24 "
    echo ""
    echo "📝 Select an option:"
    echo "0). Install CUDA Toolkit 12.8 (For for Gpu)"
    echo "1). Install Packages"
    echo "2). Install Nodes (Max-50)"
    echo "3). Start Nodes"
    echo "4). Stop Nodes"
    echo "5). Get NodeId and DeviceId"
    echo "6). Create Nodes Data Backup File"
    echo "7). Recover Nodes Data From Backup File"
    echo "8). Delete All Nodes"
    echo "9). Exit"
}

# Function to check for sudo permissions
check_permissions() {
    if [ "$EUID" -ne 0 ]; then
        echo "❌ Please run as root or use sudo."
        exit 1
    fi
}

# Function to install CUDA Toolkit 12.8 in WSL or Ubuntu 24.04
install_cuda() {
    check_permissions  # Check for permissions before proceeding

    if $IS_WSL; then
        echo "🖥️ Installing CUDA for WSL 2..."
        PIN_FILE="cuda-wsl-ubuntu.pin"
        PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin"
        DEB_FILE="cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
        DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
    else
        echo "🖥️ Installing CUDA for Ubuntu 24.04..."
        PIN_FILE="cuda-ubuntu2404.pin"
        PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin"
        DEB_FILE="cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
        DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
    fi

    echo "📥 Downloading $PIN_FILE from $PIN_URL..."
    wget "$PIN_URL" || { echo "❌ Failed to download $PIN_FILE"; exit 1; }
    sudo mv "$PIN_FILE" /etc/apt/preferences.d/cuda-repository-pin-600 || { echo "❌ Failed to move $PIN_FILE"; exit 1; }

    if [ -f "$DEB_FILE" ]; then
        echo "🗑️ Deleting existing $DEB_FILE..."
        rm -f "$DEB_FILE"
    fi
    echo "📥 Downloading $DEB_FILE from $DEB_URL..."
    wget "$DEB_URL" || { echo "❌ Failed to download $DEB_FILE"; exit 1; }
    sudo dpkg -i "$DEB_FILE" || { echo "❌ Failed to install $DEB_FILE"; exit 1; }

    sudo cp /var/cuda-repo-*/cuda-*-keyring.gpg /usr/share/keyrings/ || { echo "❌ Failed to copy CUDA keyring"; exit 1; }
    sudo apt-get update || { echo "❌ Failed to update package list"; exit 1; }
    sudo apt-get install -y cuda-toolkit-12-8 || { echo "❌ Failed to install CUDA Toolkit"; exit 1; }

    setup_cuda_env
}

# Function to set up CUDA environment variables
setup_cuda_env() {
    echo "🔧 Setting up CUDA environment variables..."
    echo 'export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}' | sudo tee /etc/profile.d/cuda.sh
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' | sudo tee -a /etc/profile.d/cuda.sh
    source /etc/profile.d/cuda.sh || { echo "❌ Failed to source CUDA environment variables"; exit 1; }
    echo "✅ CUDA environment setup completed."
}

# Function to install required packages
install_packages() {
    echo "📦 Installing required packages..."

    # Check if running as root
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root. Try: sudo $0"
        exit 1
    fi

    # Fix Google Chrome GPG key issue
    if ! test -f /etc/apt/trusted.gpg.d/google-chrome.asc; then
        echo "Adding Google Chrome GPG key..."
        wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/trusted.gpg.d/google-chrome.asc
    else
        echo "Google Chrome GPG key already exists, skipping."
    fi

    # Update package lists
    echo "Updating package list..."
    apt update -q || { echo "❌ Failed to update package list"; exit 1; }

    # Show upgradable packages
    echo "Checking for upgradable packages..."
    UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -v "Listing..." || true)

    if [ -z "$UPGRADABLE" ]; then
        echo "All packages are up to date. Skipping upgrade."
    else
        echo "Upgradable packages found:"
        echo "$UPGRADABLE"
        echo "Upgrading packages..."
        apt upgrade -y || { echo "❌ Failed to upgrade packages"; exit 1; }
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
        if ! dpkg -l | grep -qw "$pkg"; then
            echo "❌ $pkg is not installed. Installing $pkg..."
            apt install -y "$pkg" || { echo "❌ Failed to install $pkg"; exit 1; }
        else
            echo "✅ $pkg is already installed, skipping."
        fi
    done

    echo "✅ All required packages have been installed or updated."
}

# Function to create a single node
create_node() {
    local node_number=$1
    local config_link=$2
    local folder_name="gaia-node-$node_number"
    local port_number=$((8000 + node_number))

    # Check if the folder already exists
    if [ -d "$HOME/$folder_name" ]; then
        echo "⚠️ Folder $folder_name already exists. Skipping folder creation."

        echo "🔧 Installing or reconfiguring node in $folder_name..."
        curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --base "$HOME/$folder_name" || { echo "❌ Failed to install node"; return 1; }
        source ~/.bashrc
    else
        # If the folder doesn't exist, create it and install the node
        echo "🚀 Creating node $node_number..."
        mkdir -p "$HOME/$folder_name"
        echo "📂 Folder created: $folder_name"

        # Install the node
        curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --base "$HOME/$folder_name" || { echo "❌ Failed to install node"; return 1; }
        source ~/.bashrc
    fi

    # Initialize the node with the provided config link
    echo "⚙️ Initializing node with config: $config_link"
    gaianet init --base "$HOME/$folder_name" --config "$config_link" || { echo "❌ Failed to initialize node"; return 1; }

    # Update the port number (folder number + 8000)
    echo "🔧 Changing port to $port_number..."
    gaianet config --base "$HOME/$folder_name" --port "$port_number" || { echo "❌ Failed to change port"; return 1; }

    # Final re-initialization (if needed)
    echo "⚙️ Re-initializing node..."
    gaianet init --base "$HOME/$folder_name" || { echo "❌ Failed to re-initialize node"; return 1; }

    echo "✅ Node $node_number setup completed successfully with config: $config_link and port: $port_number"
}

# Function to start nodes one by one
start_nodes() {
    echo "🚀 Starting nodes sequentially..."
    
    for node_folder in "$HOME"/gaia-node-*; do
        if [ -d "$node_folder" ]; then
            node_number=$(basename "$node_folder" | grep -o '[0-9]\+')
            echo "🔧 Starting gaia-node-$node_number..."
            
            # Start the node and wait until it completes before moving to the next
            gaianet start --base "$node_folder"
            
            if [ $? -eq 0 ]; then
                echo "✅ Finished gaia-node-$node_number successfully."
            else
                echo "❌ Failed to start gaia-node-$node_number. Skipping..."
            fi

            echo "════════════════════════════════════════════════════════════════════════════════"
        fi
    done
}

# Function to stop nodes
stop_nodes() {
    echo "🛑 Stopping nodes..."
    for node_folder in "$HOME"/gaia-node-*; do
        if [ -d "$node_folder" ]; then
            node_number=$(basename "$node_folder" | grep -o '[0-9]\+')
            echo "🔧 Stopping gaia-node-$node_number..."
            gaianet stop --base "$node_folder" || { echo "❌ Failed to stop gaia-node-$node_number"; continue; }
            echo "✅ Stopped gaia-node-$node_number"
            echo "════════════════════════════════════════════════════════════════════════════════"
        fi
    done
}

# Function to display NodeId and DeviceId
get_node_info() {
    echo "📄 Displaying NodeId and DeviceId..."
    for node_folder in "$HOME"/gaia-node-*; do
        if [ -d "$node_folder" ]; then
            node_number=$(basename "$node_folder" | grep -o '[0-9]\+')
            echo "🔍 Found: gaia-node-$node_number"
            gaianet info --base "$node_folder" || { echo "❌ Failed to get info for gaia-node-$node_number"; continue; }
            echo "════════════════════════════════════════════════════════════════════════════════"
        fi
    done
}

# Function to create backup of nodes
backup_nodes() {
    backup_file="$HOME/nodes_backup.json"
    echo "📦 Creating backup of NodeId and DeviceId..."
    backup_data="{}"

    for node_folder in "$HOME"/gaia-node-*; do
        if [ -d "$node_folder" ]; then
            folder_name=$(basename "$node_folder")
            node_id_file="$node_folder/nodeid.json"
            device_id_file="$node_folder/deviceid.txt"

            if [[ -f "$node_id_file" && -f "$device_id_file" ]]; then
                node_id=$(cat "$node_id_file")
                device_id=$(cat "$device_id_file")

                backup_data=$(echo "$backup_data" | jq ". + {\"$folder_name\": { \"nodeid\": $node_id, \"deviceid\": \"$device_id\" }}")
                echo "✅ Backup for $folder_name completed!"
            else
                echo "❌ Skipping $folder_name (missing files)"
            fi
        fi
    done

    echo "$backup_data" > "$backup_file"
    echo "🚀 Backup saved to $backup_file"
}

# Function to recover nodes
recover_nodes() {
    if ! command -v jq &> /dev/null; then
        echo "❌ 'jq' is not installed. Please install it first."
        exit 1
    fi

    echo "🔄 Recovering nodes from backup..."

    if [[ ! -f "$backup_file" ]]; then
        echo "❌ No backup file found at $backup_file"
        return
    fi

    if ! jq empty "$backup_file" &> /dev/null; then
        echo "❌ Backup file is corrupted or invalid."
        return
    fi

    cat "$backup_file" | jq -c 'to_entries[]' | while IFS= read -r entry; do
        folder_name=$(echo "$entry" | jq -r '.key')
        node_id=$(echo "$entry" | jq -c '.value.nodeid')
        device_id=$(echo "$entry" | jq -r '.value.deviceid')

        if [ -d "$HOME/$folder_name" ]; then
            echo "⚠️ Folder $folder_name already exists. Skipping."
        else
            echo "📂 Creating folder: $folder_name"
            mkdir -p "$HOME/$folder_name"

            echo "$node_id" > "$HOME/$folder_name/nodeid.json"
            echo "$device_id" > "$HOME/$folder_name/deviceid.txt"

            echo "✅ Node $folder_name recovered successfully!"
        fi
    done
}

# Function to delete nodes
delete_nodes() {
    echo "🗑️ Are you sure you want to delete all nodes? This action cannot be undone. (yes/no)"
    read -r confirmation
    if [[ "$confirmation" != "yes" ]]; then
        echo "❌ Node deletion canceled."
        return
    fi

    echo "🗑️ Deleting nodes..."
    for node_folder in "$HOME"/gaia-node-*; do
        if [ -d "$node_folder" ]; then
            folder_name=$(basename "$node_folder")
            echo "🛑 Stopping $folder_name..."
            gaianet stop --base "$node_folder" || echo "⚠️ Failed to stop $folder_name (may already be stopped)."
            echo "🗑️ Deleting $folder_name..."
            rm -rf "$node_folder"
            echo "✅ Deleted $folder_name"
            echo "════════════════════════════════════════════════════════════════════════════════"
        fi
    done
    echo "✅ All existing nodes have been deleted."
}

# Main script loop
while true; do
    show_menu
    read -rp "Enter your choice: " choice
    case $choice in
        0) install_cuda ;;
        1) install_packages ;;
        2) 
    echo "📝 Enter config link for all nodes:"
    while true; do
        read -r config_link
        if [[ $config_link =~ ^https?:// ]]; then
            break
        else
            echo "❌ Invalid config link. Please enter a valid URL starting with http:// or https://"
        fi
    done

    echo "Enter number of nodes to create (1-50):"
    read -r count
    if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -lt 1 ] || [ "$count" -gt 50 ]; then
        echo "❌ Invalid input! Please enter a number between 1 and 50."
    else
        for ((i = 1; i <= count; i++)); do
            echo "🚀 Setting up node $((100 + i))..."
            if ! create_node "$((100 + i))" "$config_link"; then
                echo "⚠️ Failed to set up node $((100 + i)). Continuing with the next node..."
            fi
            echo "════════════════════════════════════════════════════════════════════════════════"
        done
        echo "✅ All nodes have been processed."
    fi
    ;;
        3) start_nodes ;;
        4) stop_nodes ;;
        5) get_node_info ;;
        6) backup_nodes ;;
        7) recover_nodes ;;
        8) delete_nodes ;;
        9) echo "⏹️ Exiting..."; exit 0 ;;
        *) echo "❌ Invalid choice. Please enter a valid option." ;;
    esac
done
