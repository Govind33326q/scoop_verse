#!/bin/bash
# One-time server setup for Ubuntu 24.04.  Usage:
#   bash setup-ubuntu.sh 'postgres://scoopadmin:PASSWORD@RDS-ENDPOINT:5432/scoopverse'
set -e
if [ -z "$1" ]; then echo "Give the database URL as the first argument."; exit 1; fi
sudo apt-get update -y
sudo apt-get install -y nginx nodejs npm rsync postgresql-client
mkdir -p ~/app
echo "DATABASE_URL=$1" | sudo tee /etc/scoopverse.env >/dev/null
sudo chmod 600 /etc/scoopverse.env
sudo tee /etc/systemd/system/scoopverse.service >/dev/null <<'UNIT'
[Unit]
Description=Scoopverse app
After=network.target
[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/app
EnvironmentFile=/etc/scoopverse.env
ExecStart=/usr/bin/env node server.js
Restart=always
[Install]
WantedBy=multi-user.target
UNIT
sudo tee /etc/nginx/conf.d/scoopverse.conf >/dev/null <<'NG'
server{listen 80 default_server;server_name _;client_max_body_size 1m;
location /{proxy_pass http://127.0.0.1:3000;proxy_set_header Host $host;proxy_set_header X-Real-IP $remote_addr;proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;}}
NG
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl daemon-reload
sudo systemctl enable nginx scoopverse
sudo systemctl restart nginx
echo "Server ready. Next: push your code to GitHub so the pipeline deploys it."
