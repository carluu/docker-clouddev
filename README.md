# docker-cloudclis

A docker container to auto spin up CLIs for:
- Azure
- AWS
- GCP

Features to add:
* Configs for all cloud credentials
* Auto pulldown of ARM templates for Azure

Build using:
docker-compose build cli

Run using (Using -d for detahced mode):
docker-compose up -d cli

Exec into:
docker exec -it <containerid> /bin/bash

Notes:
- Currently mounts a volume for source code, configure to your use