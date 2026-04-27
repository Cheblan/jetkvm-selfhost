#!/usr/bin/env bash
set -e



rm -rf ./kvm ./cloud-api

git clone -b release/0.5.6 https://github.com/jetkvm/kvm.git
cp Dockerfile-ui ./kvm/Dockerfile-ui

rm -f kvm/ui/.env-cloud-production
cp env-ui kvm/ui/.env.cloud-production



git clone -b main https://github.com/jetkvm/cloud-api.git
rm -f ./cloud-api/.env.example

# have to double copy because Dockerfile uses .env.example and original compose uses .env
cp env-api ./cloud-api/.env
cp env-api ./cloud-api/.env.example



sudo docker compose up -d --build
