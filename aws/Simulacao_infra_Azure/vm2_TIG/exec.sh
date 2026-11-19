#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt update -y
apt install -y docker.io docker-compose-v2
systemctl enable --now docker

mkdir -p /home/ubuntu/docker/nginx /home/ubuntu/docker/telegraf
cd /home/ubuntu/docker

cat <<'EOF' > docker-compose.yml
services:
  influxdb:
    image: influxdb:2.7
    container_name: iot-influxdb
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=admin
      - DOCKER_INFLUXDB_INIT_PASSWORD=urubu100
      - DOCKER_INFLUXDB_INIT_ORG=faculdade
      - DOCKER_INFLUXDB_INIT_BUCKET=sensores
      # Token estático para o Telegraf
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=TokenSecretoEstaticoParaOTelegraf2026LabIoT
    volumes:
      - influxdb_data:/var/lib/influxdb2
    networks:
      - iot-network
    restart: unless-stopped

  telegraf:
    image: telegraf:1.30
    container_name: iot-telegraf
    volumes:
      - ./telegraf/telegraf.conf:/etc/telegraf/telegraf.conf:ro
    depends_on:
      - influxdb
    networks:
      - iot-network
    restart: unless-stopped

  grafana:
    image: grafana/grafana-oss:latest
    container_name: iot-grafana
    environment:
      - GF_SERVER_ROOT_URL=%(protocol)s://%(domain)s:%(http_port)s/grafana/
      - GF_SERVER_SERVE_FROM_SUB_PATH=true
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - influxdb
    networks:
      - iot-network
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    container_name: iot-nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - influxdb
    networks:
      - iot-network
    restart: unless-stopped

networks:
  iot-network:
    driver: bridge

volumes:
  influxdb_data:
  grafana_data:
EOF

cat <<'EOF' > telegraf/telegraf.conf
[agent]
interval = "5s"
round_interval = true
metric_batch_size = 1000
metric_buffer_limit = 10000
collection_jitter = "0s"
flush_interval = "5s"
flush_jitter = "0s"
precision = "0s"
hostname = "iot-server"
omit_hostname = true

[[inputs.mqtt_consumer]]
servers = ["tcp://10.0.0.4:1883"]
topics = ["sensores/#"]
data_format = "json_v2"

[[inputs.mqtt_consumer.json_v2]]
    measurement_name = "telemetria_iot"
    timestamp_path = "timestamp"
    timestamp_format = "unix"

    [[inputs.mqtt_consumer.json_v2.tag]]
    path = "dispositivo.id"
    rename = "dispositivo_id"
    type = "string"

    [[inputs.mqtt_consumer.json_v2.tag]]
    path = "dispositivo.status"
    rename = "status"
    type = "string"

    [[inputs.mqtt_consumer.json_v2.tag]]
    path = "localizacao.bloco"
    rename = "bloco"
    type = "string"

    [[inputs.mqtt_consumer.json_v2.tag]]
    path = "localizacao.sala"
    rename = "sala"
    type = "string"

    [[inputs.mqtt_consumer.json_v2.field]]
    path = "leitura.temperatura"
    rename = "temperatura"
    type = "float"

    [[inputs.mqtt_consumer.json_v2.field]]
    path = "leitura.umidade"
    rename = "umidade"
    type = "float"

    [[inputs.mqtt_consumer.json_v2.field]]
    path = "leitura.mensagem_id"
    rename = "mensagem_id"
    type = "int"

[[outputs.influxdb_v2]]
urls = ["http://influxdb:8086"]
token = "TokenSecretoEstaticoParaOTelegraf2026LabIoT"
organization = "faculdade"
bucket = "sensores"
EOF

cat <<'EOF' > nginx/default.conf
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://influxdb:8086/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 90s;
        proxy_read_timeout 90s;
    }

    location /grafana/ {
        proxy_pass http://grafana:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

chown -R ubuntu:ubuntu /home/ubuntu/docker
docker compose up -d