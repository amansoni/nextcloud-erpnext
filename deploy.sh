#!/bin/bash

# Simple script to help with manual deployment updates on the server.
# Assumes you are running this script from the deployment directory (e.g., /opt/docker-stack).
# Assumes the .env file already exists and is configured.

# Exit immediately if a command exits with a non-zero status.
set -e

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

