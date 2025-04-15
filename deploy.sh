#!/bin/bash

# Simple script to help with manual deployment updates on the server.
# Assumes you are running this script from the deployment directory (e.g., /opt/docker-stack).
# Assumes the .env file already exists and is configured.
# Assumes you have Docker and Docker Compose installed and running.
# Assumes you have SSH access to the server and are running this script as a user with the necessary permissions.
# Assumes you have a working Git repository and are on the correct branch.
# Assumes you have a backup strategy in place for your .env file and other important files.
# Assumes that there is a public ssh key (~/.ssh/id_rsa_deploy) in the server's authorized_keys file for the user running this script.
# Assumes that the server has a firewall configured to allow traffic on the necessary ports (e.g., 80, 443).
# Assumes that the server has a reverse proxy (e.g., Traefik) configured to route traffic to the correct services.
# Exit immediately if a command exits with a non-zero status.
set -e

echo ">>> Setup SSH Agent using ~/.ssh/id_rsa_deploy ..."
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa_deploy

echo ">>> Pulling latest changes from Git..."
# Stash any local changes (like modified .env if not ignored properly)
# git stash push --include-untracked
git pull origin main # Or your deployment branch
# git stash pop # Apply stashed changes if needed, be careful with .env

echo ">>> Ensuring correct file permissions..."
# Re-apply permissions just in case
sudo chmod 600 .env
sudo chmod 600 traefik/acme.json || echo "acme.json not found, will be created by Traefik."

echo ">>> Starting/Updating Docker Compose stack..."
# Use --remove-orphans to clean up containers from services removed from the compose file
docker compose up -d --remove-orphans

echo ">>> Deployment script finished."
echo ">>> Monitor logs with: docker compose logs -f"

