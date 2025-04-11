# Integrated Nextcloud, ERPNext, n8n Stack with Traefik

This repository contains the configuration files to deploy Nextcloud, ERPNext, OnlyOffice Document Server, n8n, and Traefik using Docker Compose on an Ubuntu server.

## Prerequisites

* Ubuntu Server (20.04/22.04 LTS recommended)
    - Ensure your Ubuntu server meets the prerequisites (Docker, Docker Compose installed, Firewall configured for ports 80/443, DNS records pointing to the server IP).
* Docker and Docker Compose installed.
* DNS records for your chosen subdomains pointing to your server's IP.
* Ports 80 and 443 open on the server firewall.
* `git` installed on the server.
* [Add deploy key if needed](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#deploy-keys)

## Setup on Server

1.  **Clone the Repository:**
    ```bash
    git clone git@github.com:amansoni/nextcloud-erpnext.git /opt/docker-stack # or your repo url
    cd /opt/docker-stack
    ```

2.  **Create `.env` File:** Copy the example file and **edit it securely** to add your actual domains, passwords, and secrets:
    ```bash
    cp .env.sample .env
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

5. Use `deploy.sh` to run the setup steps.

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

After the containers are running, you need to perform initial setup for the applications via their web interfaces:

1. **ERPNext Setup:**  
   * Access https://erp.yourdomain.com.  
   * Wait for initialization (can take several minutes on first boot). Frappe/ERPNext needs to build the site based on the environment variables.  
   * If the site doesn't automatically set up, you might need to run manual commands (check Frappe Docker documentation for the specific version). A common command might look like: docker compose exec erpnext-python bench new-site ${ERPNEXT\_SITE\_NAME} \--admin-password ${ADMIN\_PASSWORD} \--db-root-password ${MYSQL\_ROOT\_PASSWORD} \--install-app erpnext \--set-default (adapt as needed, ensure variables match your .env).  
   * Complete the web-based setup wizard using the Administrator password from your .env file (change it immediately\!).  
   * **Configure OIDC Provider:** In ERPNext settings, find "OAuth Provider Settings" or similar. Enable it and configure the details. Then go to "OAuth Client" and create a new client entry for Nextcloud. Note the **Client ID**, **Client Secret**, and the **Discovery URL** (usually https://erp.yourdomain.com/.well-known/openid-configuration).  
2. **Nextcloud Setup:**  
   * Access https://nextcloud.yourdomain.com.  
   * Complete the web-based setup wizard. Create the admin user using the credentials defined in .env (NEXTCLOUD\_ADMIN\_USER, NEXTCLOUD\_ADMIN\_PASSWORD). Configure the database connection (Type: PostgreSQL, Host: nextcloud-db, User/DB: nextcloud, Password from .env).  
   * Log in as admin, go to Apps (top-right user menu \-\> Apps).  
   * Install the **"OpenID Connect user backend" (user\_oidc)** app.  
   * Go to Administration Settings \-\> Security \-\> SSO & SAML authentication (or OpenID Connect).  
   * Add a new OpenID Connect provider. Use the Discovery URL, Client ID, and Client Secret obtained from ERPNext. Set appropriate scopes (e.g., openid, profile, email, roles). Map claims (like preferred\_username to UID, name to Display Name, email to Email).  
   * Install the **"ONLYOFFICE"** connector app.  
   * Go to Administration Settings \-\> ONLYOFFICE. Enter the Document Server URL: https://onlyoffice.yourdomain.com. Enter the **JWT Secret** from your .env file. Save.  
3. **OnlyOffice:** Access https://onlyoffice.yourdomain.com to ensure it's running. It should show the default landing page. No further configuration is typically needed here; interaction happens via Nextcloud.  
4. **n8n Setup:**  
   * Access https://n8n.yourdomain.com.  
   * Log in using the Basic Auth credentials from your .env file (N8N\_BASIC\_AUTH\_USER, N8N\_BASIC\_AUTH\_PASSWORD). Consider setting up more robust user management within n8n later.  
   * Go to "Credentials" in the n8n UI. Add new credentials for:  
     * **Nextcloud:** Use the Nextcloud base URL (https://nextcloud.yourdomain.com) and create an "App Password" within your Nextcloud user settings for n8n to use.  
     * **ERPNext:** Use the ERPNext base URL (https://erp.yourdomain.com) and generate an API Key and API Secret within an ERPNext user's settings (create a dedicated API user in ERPNext for n8n with appropriate permissions).  
   * Start building your integration workflows\!

## Security Issues

.env File: The most critical point. NEVER commit the file with actual secrets. It MUST be created and managed securely on the target server. The .env.example file in the repo serves only as a template.

SSH Key: Use a dedicated SSH key pair for deployment only. Protect the private key and store it securely in GitHub secrets. Do not add a passphrase to this key if used by Actions, or configure the action to handle the passphrase.

GitHub Secrets: Store SSH_PRIVATE_KEY, SSH_HOST, SSH_USER, and WORK_DIR as encrypted secrets in your GitHub repository settings.

Server User Permissions: The SSH user (SSH_USER) on your server needs permission to run git, docker, and docker compose commands, and potentially sudo for file permissions (or ensure file ownership is correct). Adding the user to the docker group is common, but be aware of the security implications.

**Disclaimer:** This setup provides a solid foundation. Production environments require careful consideration of security hardening (firewalls, intrusion detection), resource allocation (CPU/RAM limits for containers), robust backup and recovery strategies, monitoring, and regular updates for all components. Always test thoroughly before relying on this setup for critical operations.