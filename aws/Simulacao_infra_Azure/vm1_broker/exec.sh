sudo apt update
sudo apt install -y mosquitto mosquitto-clients

sudo systemctl start mosquitto.service
sudo systemctl enable mosquitto.service
sudo systemctl status mosquitto.service --no-pager
sudo systemctl restart mosquitto

# sudo nano /etc/mosquitto/conf.d/default.conf