import json
import time
import paho.mqtt.client as mqtt
from paho.mqtt.enums import CallbackAPIVersion
import random

# Config do Broker
BROKER_IP = "68.211.72.191"
PORTA = 1883
TOPICO = "sensores/"

client = mqtt.Client(CallbackAPIVersion.VERSION2)
client.connect(BROKER_IP, PORTA, 60)

print(f"Conectado ao broker {BROKER_IP}! Enviando mensagens...")

try:
    count = 1
    temp_atual = 24.5
    while True:
        variacao = random.uniform(-0.3, 0.3)
        temp_atual = round(max(18.0, min(35.0, temp_atual + variacao)), 2)
        # Estrutura de dados com JSON aninhado
        payload_dados = {
            "dispositivo": {
                "id": "arch-lab-02",
                "status": "online",
                "firmware": "1.3.0"
            },
            "leitura": {
                "mensagem_id": count,
                "temperatura": temp_atual,
                "umidade": 70,
                "sensores_ativos": ["temp_dht22", "pressao_bmp280"]
            },
            "localizacao": {
                "bloco": "B",
                "sala": 10
            },
            "timestamp": int(time.time())
        }

        mensagem_json = json.dumps(payload_dados)

        # Publica no topico
        client.publish(TOPICO, mensagem_json)
        print(f"[{count}] Mensagem JSON enviada com sucesso!")

        count += 1
        time.sleep(3)

except KeyboardInterrupt:
    print("\nEncerrando o publicador...")
    client.disconnect()