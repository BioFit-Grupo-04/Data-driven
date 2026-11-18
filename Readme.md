# Data-driven — Infraestrutura e Configurações

Este repositório atua como o **centralizador e versionador de toda a infraestrutura** do projeto **Data-driven**. Ele reúne os templates de provisionamento, scripts de automação e arquivos de configuração necessários para subir e manter as aplicações nos ambientes em nuvem (**AWS** e **Azure**).

---

## Estrutura do Repositório

```text
Data-driven/
├── aws/
│   ├── Simulacao_infra_Azure/
│   │   ├── vm1_broker/
│   │   │   ├── exec.sh
│   │   │   └── moquitto.conf
│   │   ├── vm2_TIG/
│   │   │   ├── docker-composer.yml
│   │   │   ├── exec.sh
│   │   │   ├── nginx.conf
│   │   │   └── telegraf.conf
│   │   ├── vm3_node_red/
│   │   │   ├── flows_integração.json
│   │   │   ├── flowsV1.json
│   │   │   └── flowsV2.json
│   │   ├── datadriven.yml
│   │   └── infra.yml
│   ├── dataIntegration.yml
│   ├── dataLake.yml
│   └── setup-amb.sh
├── azure/
│   ├── Broker/
│   │   ├── payload_sensor.py
│   │   └── TIG.py
│   ├── influxDB/
│   └── terraform/
├── requirements.txt
└── README.md
```

---

## Detalhamento das Pastas Principais

### 1. `/aws`
Contém os arquivos de infraestrutura como código (templates YAML), scripts de inicialização e o ambiente de simulação hospedado na AWS.

* **`Simulacao_infra_Azure/`**: Ambiente estruturado na AWS para simular a arquitetura projetada para a Azure, contendo os templates `datadriven.yml` e `infra.yml`, além das configurações divididas por máquina virtual:
  * **`vm1_broker/`**: Configurações do Broker MQTT (`moquitto.conf`) e script de execução (`exec.sh`).
  * **`vm2_TIG/`**: Stack de monitoramento e ingestão **TIG** (Telegraf, InfluxDB e Grafana), contendo `docker-composer.yml`, `telegraf.conf`, proxy reverso (`nginx.conf`) e `exec.sh`.
  * **`vm3_node_red/`**: Fluxos de integração e automação do Node-RED (`flows_integração.json`, `flowsV1.json` e `flowsV2.json`).
* **`dataIntegration.yml` & `dataLake.yml`**: Definições de infraestrutura voltadas para a camada de integração de dados e Data Lake.
* **`setup-amb.sh`**: Script shell para preparação e configuração inicial do ambiente.

### 2. `/azure`
Reúne o provisionamento e os componentes voltados para o ambiente Microsoft Azure.

* **`Broker/`**: Scripts em Python responsáveis pela comunicação e envio de dados dos sensores (`payload_sensor.py`) e integração com a stack TIG (`TIG.py`).
* **`influxDB/`**: Arquivos e configurações dedicados ao banco de dados de séries temporais InfluxDB.
* **`terraform/`**: Códigos Terraform (IaC) para provisionamento automatizado dos recursos na Azure.

### 3. Arquivos na Raiz
* **`requirements.txt`**: Lista de dependências Python necessárias para executar os scripts do projeto.
* **`README.md`**: Documentação central do repositório.

---

## Pendências e Próximos Passos

Espaço reservado para acompanhamento de melhorias, correções e tarefas pendentes na infraestrutura:

- [ ] **Broker**: Ajustar a configuração do docker da VM1_broker.
- [ ] *(Adicione aqui novas pendências do projeto)*