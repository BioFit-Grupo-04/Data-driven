#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y docker.io docker-compose-v2
systemctl enable --now docker
cd /home/ubuntu

mkdir -p node-red-proxy
cd node-red-proxy
mkdir -p nginx

cat <<'EOF' > docker-compose.yml
services:
  node-red:
    image: nodered/node-red:latest
    restart: unless-stopped
    environment:
      - TZ=America/Sao_Paulo
    volumes:
      - node_red_data:/data
    networks:
      - app_net
    expose:
      - "1880"

  nginx:
    image: nginx:stable-alpine
    restart: unless-stopped
    depends_on:
      - node-red
    ports:
      - "80:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    networks:
      - app_net

volumes:
  node_red_data:

networks:
  app_net:
    driver: bridge
EOF

cd nginx

cat <<'EOF' > default.conf
server {
    listen 80;
    server_name _;

    client_max_body_size 10m;

    location / {
        proxy_pass http://node-red:1880;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_read_timeout 86400;
        proxy_send_timeout 86400;
    }
}
EOF

chown -R ubuntu:ubuntu /home/ubuntu/node-red-proxy
cd /home/ubuntu/node-red-proxy
docker compose up -d