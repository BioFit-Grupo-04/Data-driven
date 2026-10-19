import json
import time
import paho.mqtt.client as mqtt
from paho.mqtt.enums import CallbackAPIVersion
import random

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
        payload_dados = {
            "dispositivo": {
                "id": "academia-lab-01",
                "status": "online",
                "firmware": "1.0.0"
            },
            "equipamento": {
                "id": "esteira-03",
                "tipo": "esteira",
                "ocupado": True
            },
            "aluno": {
                "id": "aluno-2026-001",
                "batimento": 82,
                "spo2": 98,
                "temperatura_pele": 34.5
            },
            "localizacao": {
                "bloco": "A",
                "sala": 5
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