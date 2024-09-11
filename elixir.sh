#!/bin/bash

# Step 1: Update and Install Dependencies
echo "Updating and installing necessary dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git jq lz4 build-essential unzip

# Step 2: Install Docker (Skip if already installed)
if ! command -v docker &> /dev/null; then
    echo "Docker not found, installing Docker..."
    sudo apt install -y ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    newgrp docker
else
    echo "Docker is already installed, skipping this step..."
fi

# Step 3: Install Validator Config
echo "Setting up the Elixir validator directory..."
mkdir -p ~/elixir && cd ~/elixir
wget https://files.elixir.finance/validator.env

# Step 4: Edit the Validator Configuration
echo "Please enter the following details to configure the validator:"
read -p "Enter STRATEGY_EXECUTOR_DISPLAY_NAME (Validator name): " display_name
read -p "Enter STRATEGY_EXECUTOR_BENEFICIARY (Your EVM Wallet address): " beneficiary
read -p "Enter SIGNER_PRIVATE_KEY (Your private key): " private_key

# Writing details to validator.env
echo "STRATEGY_EXECUTOR_DISPLAY_NAME=$display_name" >> validator.env
echo "STRATEGY_EXECUTOR_BENEFICIARY=$beneficiary" >> validator.env
echo "SIGNER_PRIVATE_KEY=$private_key" >> validator.env

# Step 5: Pull the Elixir Validator Docker Image
echo "Pulling the Elixir Validator Docker image..."
docker pull elixirprotocol/validator:v3

# Step 6: Launch the Elixir Validator
echo "Launching the Elixir Validator node..."
docker run -d --env-file ~/elixir/validator.env --name elixir --platform linux/amd64 elixirprotocol/validator:v3

# Step 7: Monitor the Node
echo "Checking if the Elixir node is running..."
docker container ls

echo "To view logs, use: docker logs -f [CONTAINER_ID]"
