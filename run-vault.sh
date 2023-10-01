#!/usr/bin/env bash

set -e

function wait_for_vault() {
  while true; do
    sleep 1
    if docker exec vault ls /vault/file/init.json > /dev/null 2>&1; then
      TOKEN=$(docker exec vault token)
      if [ -n "$TOKEN" ]; then
        echo "Vault is ready"
        break
      fi
    fi
  done
}

docker pull quay.io/mynth/local-vault:latest
docker volume create vault > /dev/null
docker stop vault > /dev/null 2>&1 || true
docker rm vault > /dev/null 2>&1 || true
docker run \
    --cap-add IPC_LOCK \
    --name vault \
    -v vault:/vault/file \
    -p 8200:8200 \
    -d \
    --restart unless-stopped quay.io/mynth/local-vault \
        > /dev/null
wait_for_vault
