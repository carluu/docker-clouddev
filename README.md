# docker-cloudclis

A docker container to auto spin up:
- Git
- Azure CLI
- AWS CLI
- GCP CLI
- Azure Python SDK
- Helm
- Terraform (Version 0.12.23 as no out of box way to retrieve latest)

(Also installs all dependencies)

Features to add:
* Configs for all cloud credentials


Column 1 | Column 2 
--- | --- | ---
Azure | Done 
GCP | TODO 
AWS | TODO

* Auto pulldown of ARM templates for Azure
* Custom versions for tools

Set environment variabes by populating .env.sample and renaming to .env
If using VS Code to develop in a container, will also need the .env in the root of the code folder

Build using:
docker-compose build dev

Run using (Using -d for detached mode):
docker-compose up -d dev

Notes:
- Currently mounts a volume for source code, configure to your use