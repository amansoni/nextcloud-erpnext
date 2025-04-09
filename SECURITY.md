.env File: The most critical point. NEVER commit the file with actual secrets. It MUST be created and managed securely on the target server. The .env.example file in the repo serves only as a template.

SSH Key: Use a dedicated SSH key pair for deployment only. Protect the private key and store it securely in GitHub secrets. Do not add a passphrase to this key if used by Actions, or configure the action to handle the passphrase.

GitHub Secrets: Store SSH_PRIVATE_KEY, SSH_HOST, SSH_USER, and WORK_DIR as encrypted secrets in your GitHub repository settings.

Server User Permissions: The SSH user (SSH_USER) on your server needs permission to run git, docker, and docker compose commands, and potentially sudo for file permissions (or ensure file ownership is correct). Adding the user to the docker group is common, but be aware of the security implications.