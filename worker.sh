#!/bin/bash

# Get mnemonic phrase from user
read -p "Enter your mnemonic phrase: " mnemonic_phrase

mkdir allora-worker
cd allora-worker
git clone https://github.com/allora-network/allora-huggingface-walkthrough.git
cd allora-huggingface-walkthrough
mkdir worker-data 
touch worker-data/env_file
chmod -R 777 worker-data
rm docker-compose.yaml

cat << EOF > docker-compose.yaml
services:
  inference:
    container_name: inference-hf
    build:
      context: .
      dockerfile: Dockerfile
    command: python -u /app/app.py
    ports:
      - "8000:8000"

  worker:
    container_name: worker
    image: alloranetwork/allora-offchain-node:latest
    volumes:
      - ./worker-data:/data
    depends_on:
      - inference
    env_file:
      - ./worker-data/env_file
  
volumes:
  inference-data:
  worker-data:
EOF


cat <<EOF > config.json
{
    "wallet": {
        "addressKeyName": "test",
        "addressRestoreMnemonic": "$mnemonic_phrase",
        "alloraHomeDir": "",
        "gas": "1000000",
        "gasAdjustment": 1.0,
        "nodeRpc": "https://allora-rpc.testnet-1.testnet.allora.network/",
        "maxRetries": 1,
        "delay": 1,
        "submitTx": false
    },
    "worker": [
        {
            "topicId": 3,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 1,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "BTC"
            }
        },
        {
            "topicId": 4,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 3,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "BTC"
            }
        },
        {
            "topicId": 5,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 4,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "SOL"
            }
        },
        {
            "topicId": 6,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "SOL"
            }
        },
        {
            "topicId": 8,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 3,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "BNB"
            }
        }
        
    ]
}
EOF

chmod +x init.config
./init.config 

# Run docker containers
docker-compose up -d
