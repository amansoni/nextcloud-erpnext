# Integrated Nextcloud, ERPNext, n8n Stack with Traefik

This repository contains the configuration files to deploy Nextcloud, ERPNext, OnlyOffice Document Server, n8n, and Traefik using Docker Compose on an Ubuntu server.

## Prerequisites

* Ubuntu Server (20.04/22.04 LTS recommended)
* Docker and Docker Compose installed.
* DNS records for your chosen subdomains pointing to your server's IP.
* Ports 80 and 443 open on the server firewall.
* `git` installed on the server.

## Setup on Server

1.  **Clone the Repository:**
    ```bash
    git clone <your-repo-url> /opt/docker-stack
    cd /opt/docker-stack
    ```

2.  **Create `.env` File:** Copy the example file and **edit it securely** to add your actual domains, passwords, and secrets:
    ```bash
    cp .env.example .env
    nano .env # Or your preferred editor
    # --- FILL IN ALL REQUIRED VALUES ---
    sudo chmod 600 .env # Restrict permissions
    ```
    **IMPORTANT:** Never commit your actual `.env` file to Git.

3.  **Prepare Traefik:** Create the directory and empty `acme.json` file with correct permissions:
    ```bash
    sudo mkdir -p /opt/docker-stack/traefik
    sudo touch /opt/docker-stack/traefik/acme.json
    sudo chmod 600 /opt/docker-stack/traefik/acme.json
    ```

4.  **Set Directory Ownership (Optional but Recommended):** Ensure the user running Docker commands has appropriate permissions. If running as a non-root user in the `docker` group:
    ```bash
    sudo chown $USER:$USER -R /opt/docker-stack
    ```

## Deployment

### Manual Deployment

1.  **Pull Changes:** If updating an existing deployment, navigate to `/opt/docker-stack` and pull the latest changes:
    ```bash
    git pull origin main # Or your deployment branch
    ```
2.  **Start/Update Stack:** Run Docker Compose:
    ```bash
    docker compose up -d --remove-orphans
    ```

### Automated Deployment (GitHub Actions)

This repository includes a GitHub Actions workflow (`.github/workflows/deploy.yml`). To enable it:

1.  **Generate SSH Key:** Create an SSH key pair specifically for deployment (do not reuse personal keys):
    ```bash
    ssh-keygen -t ed25519 -f ./deploy_key -N "" # No passphrase
    ```
    This creates `deploy_key` (private) and `deploy_key.pub` (public).
2.  **Add Public Key to Server:** Add the contents of `deploy_key.pub` to the `~/.ssh/authorized_keys` file for the user that will run the deployment commands on your Ubuntu server.
3.  **Add Secrets to GitHub:** In your GitHub repository settings, go to "Secrets and variables" -> "Actions". Add the following repository secrets:
    * `SSH_PRIVATE_KEY`: Paste the entire contents of the **private** key file (`deploy_key`).
    * `SSH_HOST`: Your Ubuntu server's IP address or hostname.
    * `SSH_USER`: The username on your Ubuntu server that has the public key added and can run Docker commands (e.g., `ubuntu` or your specific user).
    * `WORK_DIR`: The deployment directory on the server (e.g., `/opt/docker-stack`).
4.  **Trigger Deployment:** Pushing changes to the `main` branch (or the branch specified in the workflow file) will now automatically trigger the deployment action.

## Post-Deployment Configuration

Refer to the "Post-Deployment Configuration" steps outlined in the initial setup documentation (or previous conversation context) to configure ERPNext (OIDC Provider), Nextcloud (OIDC Client, OnlyOffice Connector), and n8n (Credentials) via their web interfaces.
