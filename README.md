* install docker

```bash
# Install Docker
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

# Add Docker's official GPG key

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$(lsb_release -cs)}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify Docker is running
sudo docker run hello-world
```

* configure nginx

```bash
# Create an Nginx configuration file
sudo nano /etc/nginx/sites-available/keycloak

# Paste the following configuration:
server {
    listen 443 ssl;
    server_name keycloak.labmtl.ca;

    # SSL certificates
    ssl_certificate /etc/nginx/ssl/keycloak.labmtl.ca/fullchain.crt;
    ssl_certificate_key /etc/nginx/ssl/keycloak.labmtl.ca/private.key;

    # Security headers
    include /etc/nginx/snippets/security-headers.conf;

    # Increase max body size for large uploads
    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}

# Create symlink to enable the site
sudo ln -s /etc/nginx/sites-available/keycloak /etc/nginx/sites-enabled/

# Remove default site if it exists
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

* create /sites-available/security-headers.conf

* start keycloak container

```bash
sudo docker run -d -p 8080:8080 --restart unless-stopped \
  --name keycloak \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -e KC_HOSTNAME=keycloak.labmtl.ca \
  -e KC_PROXY=edge \
  -e KC_HOSTNAME_PORT=443 \
  -e KC_HOSTNAME_SECURE=true \
  -e KC_HOSTNAME_ADMIN_URL=https://keycloak.labmtl.ca/admin \
  -e KC_HOSTNAME_ADMIN_PORT=443 \
  -v /srv/keycloak/data:/opt/keycloak/data \
  -v /srv/keycloak/logs:/opt/keycloak/logs \
  quay.io/keycloak/keycloak:latest start-dev
```

* create realm
