# docker-clouddev

A docker container to auto spin up:

| Tool               |  Default Version (if blank) | Custom Version Support | Custom Version Example | Notes
| ------------------ | --------------------------  | :--------------------: | :--------------------: | ----------- |
| Git                |  Latest from apt            | No                     | N/A                    |             |
| Azure CLI          |  Latest from apt            | Yes                    | 2.2.0                  |             |
| AWS CLI            |  Latest from AWS site       | No (Possible?)         | N/A                    |               Using v2.x. For v1.x, need to edit dockerfile per instructions there |
| GCP CLI            |  Latest from apt            | Yes                    | 284.0.0                |             |
| Azure Python SDK   |  Latest from pip            | TBD                    | 4.0.0                  |             |
| Helm               |  Latest from helm site      | Yes                    | 3.1.2                  |             |
| Terraform          |  0.12.24                    | Yes (Required)         | 0.12.23                |             |
| Kubectl            |  Latest from apt            | Yes                    | 1.17.4                 |             |
| Az Functions Tools |  Latest from apt            | Yes                    | 3.0.2245               |             |

(Also installs all dependencies)

## Other capabilities

### Modular installation
Specify a version number of 0 to not install that tool

### Configs for all cloud credentials

| Cloud    |  Status  | 
| -------- | -------- |
| Azure    |  Done    |
| GCP      |  TODO    |
| AWS      |  TODO    |

### Git configuration
Sets user.name and user.email. Credentials are pulled from the VS Code credential helper, otherwise will need to handle credentials once in the container

## Instructions for use
Set environment variabes by populating .env.sample and renaming to .env
If using VS Code to develop in a container, will also need the .env in the root of the code folder

Build using:
`docker-compose build -f dev`

Run using (Using -d for detached mode):
`docker-compose up -d dev`
