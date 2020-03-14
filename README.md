# docker-cloudclis

A docker container to auto spin up:

| Tool             |  Default Version       | 
| ---------------- | ---------------------- |
| Git              |  Latest from apt       |
| Azure CLI        |  Latest from apt       |
| AWS CLI          |  Latest from pip       |
| GCP CLI          |  Latest from apt       |
| Azure Python SDK |  Latest from pip       |
| Helm             |  Latest from helm site |
| Terraform        |  0.12.23               |

(Also installs all dependencies)

Features to add:
* Configs for all cloud credentials

| Cloud    |  Status  | 
| -------- | -------- |
| Azure    |  Done    |
| GCP      |  TODO    |
| AWS      |  TODO    |

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