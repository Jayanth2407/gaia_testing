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

# Function to display the menu
show_menu() {
    echo ""
    echo "🌌 Welcome to the Gaia Node Manager! - Made by HASHTAG"
    echo "🌌 For Doubts, Dm me on Telegram: https://t.me/Jayanth24 "
    echo ""
    echo "📝 Select an option:"
    echo "1). Install Packages and CUDA Toolkit"
    echo "2). Install Nodes (Max-50)"
    echo "3). Start Nodes"
    echo "4). Stop Nodes"
    echo "5). Get NodeId and DeviceId"
    echo "6). Create Nodes Data Backup File"
    echo "7). Recover Nodes Data From Backup File ( nodes_backup.json )"
    echo "8). Delete All Nodes"
    echo "9). Exit"
}

# Function to install packages and CUDA
install_packages_and_cuda() {
    echo "📦 Installing packages and CUDA Toolkit..."
    
    # Download the packageskit.sh script from GitHub
    curl -O https://raw.githubusercontent.com/Jayanth2407/gaia_testing/main/packageskit.sh
    
    # Make the script executable
    chmod +x packageskit.sh
    
    # Execute the script
    ./packageskit.sh
    
    echo "✅ Packages and CUDA installation completed."
}

# Function to create a single node
create_node() {
    local node_number=$1
    local config_link=$2
    local folder_name="gaia-node-$node_number"
    local port_number=$((8000 + node_number))

    echo "🔄 Processing node: $node_number (Folder: $folder_name, Port: $port_number)"

    # Check if the folder exists
    if [ -d "$HOME/$folder_name" ]; then
        echo "⚠️ Folder $folder_name already exists. Skipping folder creation."
    else
        echo "🚀 Creating node $node_number..."
        mkdir -p "$HOME/$folder_name"
        echo "📂 Folder created: $folder_name"
    fi

    # Install or update the node
    echo "🔧 Installing or updating GaiaNet node in $folder_name..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --base "$HOME/$folder_name" || { echo "❌ Failed to install node"; return 1; }
    source ~/.bashrc

    # Initialize the node with the provided config link
    echo "⚙️ Initializing node with config: $config_link"
    gaianet init --base "$HOME/$folder_name" --config "$config_link" || { echo "❌ Failed to initialize node"; return 1; }

    # Assign the port number
    echo "🔧 Changing port to $port_number..."
    gaianet config --base "$HOME/$folder_name" --port "$port_number" || { echo "❌ Failed to change port"; return 1; }

    # Final re-initialization
    echo "⚙️ Re-initializing node..."
    gaianet init --base "$HOME/$folder_name" || { echo "❌ Failed to re-initialize node"; return 1; }

    echo "✅ Node $node_number setup completed successfully with config: $config_link and port: $port_number"
}

# Function to install multiple nodes
install_nodes() {
    echo "📝 Enter config link for all nodes:"
    while :; do
        read -r config_link
        if [[ "$config_link" =~ ^https?:// ]]; then
            break
        else
            echo "❌ Invalid config link. Please enter a valid URL starting with http:// or https://"
        fi
    done

    echo "Enter number of nodes to create (1-50):"
    read -r count
    if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -lt 1 ] || [ "$count" -gt 50 ]; then
        echo "❌ Invalid input! Please enter a number between 1 and 50."
        return 1  # Exit function to prevent further execution
    fi

    for ((i = 1; i <= count; i++)); do
        echo "🚀 Setting up node $((100 + i))..."
        if ! create_node "$((100 + i))" "$config_link"; then
            echo "⚠️ Failed to set up node $((100 + i)). Continuing with the next node..."
        fi
        echo "════════════════════════════════════════════════════════════════════════════════"
    done

    echo "✅ All nodes have been processed."
}

# Function to start nodes with CUDA support (if available)
start_nodes() {
    echo "🚀 Checking for CUDA support..."

    # Check if CUDA is installed
    if command -v nvidia-smi &>/dev/null && nvidia-smi --query-gpu=name --format=csv,noheader | grep -q .; then
        echo "✅ CUDA detected! Running nodes with GPU acceleration."
        use_cuda=true
    else
        echo "⚠️ CUDA not detected! Running nodes on CPU."
        use_cuda=false
    fi

    echo "🚀 Starting nodes sequentially..."
    
    for node_folder in "$HOME"/gaia-node-*; do
        # Ensure that the node_folder is a valid directory
        if [[ -d "$node_folder" ]]; then
            node_number=$(basename "$node_folder" | grep -o '[0-9]\+')
            echo "🔧 Starting gaia-node-$node_number..."

            if [[ "$use_cuda" == true ]]; then
                # Run with CUDA
                CUDA_VISIBLE_DEVICES=0 gaianet start --base "$node_folder"
            else
                # Run normally (CPU)
                gaianet start --base "$node_folder"
            fi

            if [[ $? -eq 0 ]]; then
                echo "✅ Finished gaia-node-$node_number successfully."
            else
                echo "❌ Failed to start gaia-node-$node_number. Skipping..."
            fi

            echo "════════════════════════════════════════════════════════════════════════════════"
        fi
    done

    echo "✅ All nodes have been processed."
}

# Function to stop nodes safely
stop_nodes() {
    echo "🛑 Checking for running nodes..."
    
    for node_folder in "$HOME"/gaia-node-*; do
        # Ensure it's a valid directory
        if [[ -d "$node_folder" ]]; then
            node_number=$(basename "$node_folder" | grep -o '[0-9]\+')

            # Check if the node is already running
            if pgrep -f "gaianet.*--base $node_folder" > /dev/null; then
                echo "🔧 Stopping gaia-node-$node_number..."
                
                # Stop the node and handle errors properly
                if gaianet stop --base "$node_folder"; then
                    echo "✅ Stopped gaia-node-$node_number"
                else
                    echo "❌ Failed to stop gaia-node-$node_number. Skipping..."
                fi
            else
                echo "⚠️ gaia-node-$node_number is not running. Skipping..."
            fi

            echo "════════════════════════════════════════════════════════════════════════════════"
        fi
    done

    echo "✅ All nodes have been processed."
}

# Function to display NodeId and DeviceId
get_node_info() {
    echo "📄 Displaying NodeId and DeviceId..."
    
    for node_folder in "$HOME"/gaia-node-*; do
        # Ensure it's a valid directory
        if [[ -d "$node_folder" ]]; then
            node_number=$(basename "$node_folder" | grep -o '[0-9]\+')
            echo "🔍 Retrieving info for gaia-node-$node_number..."

            # Execute gaianet info and handle potential failures
            if gaianet info --base "$node_folder"; then
                echo "✅ Successfully retrieved info for gaia-node-$node_number."
            else
                echo "❌ Failed to get info for gaia-node-$node_number. Skipping..."
            fi

            echo "════════════════════════════════════════════════════════════════════════════════"
        fi
    done

    echo "✅ All nodes have been processed."
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
        1) install_packages_and_cuda ;;
        2) install_nodes ;;
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
