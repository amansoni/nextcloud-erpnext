Trigger: Runs automatically when code is pushed to the main branch (or manually via workflow_dispatch).

Runner: Uses a standard GitHub-hosted Ubuntu runner.

Checkout: Downloads your repository code onto the runner.

Setup SSH: Configures an SSH agent using a private key stored securely as a GitHub repository secret (SSH_PRIVATE_KEY).

Add Known Hosts: Adds your server's fingerprint to the runner's known_hosts file to allow the SSH connection without manual confirmation.

Deploy via SSH:

Connects to your server using the SSH user and host defined in GitHub secrets (SSH_USER, SSH_HOST).

Navigates to the working directory (WORK_DIR secret).

Runs git pull to get the latest code.

Sets permissions on .env and acme.json (as a safety measure).

Runs docker compose up -d --remove-orphans to apply changes and start the stack.