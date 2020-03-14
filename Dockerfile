FROM ubuntu:latest

ARG AZURE_CLI_LOGIN_TENANT_ID
ARG AZURE_CLI_LOGIN_SP_ID
ARG AZURE_CLI_LOGIN_SP_SECRET

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install prerequisites
RUN apt-get update -qq && \
    apt-get install -y\
      apt-transport-https \      
      software-properties-common\
      dirmngr\
      python2.7\
      python3\
      python3-distutils\
      curl\
      unzip\
      git

# Install helm by retrieving install script from git and executing
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > install_helm.sh &&  /bin/sh install_helm.sh

# Add Azure CLI source
RUN . /etc/os-release &&\
      echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $UBUNTU_CODENAME main" | \
            tee /etc/apt/sources.list.d/azure-cli.list

# Add package keys    
RUN apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
      --keyserver packages.microsoft.com \
      --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF

# Install the CLI    
RUN apt-get update -qq &&\
    apt-get install -y azure-cli

# Source the auto complete script
RUN echo "source /etc/bash_completion.d/azure-cli" >> /root/.bashrc

############### End Install Azure CLI

############### Install AWS CLI

# Install PIP
RUN curl -O https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py

# Install AWS CLI
RUN pip3 install awscli --upgrade --user --no-warn-script-location

# Add AWS CLI to path
RUN echo "export PATH=/root/.local/bin:$PATH" >> /root/.bashrc

############### End Install AWS CLI


############### Install GCP Cloud SDK

# Add Cloud SDK source
RUN . /etc/os-release &&\
      echo "deb http://packages.cloud.google.com/apt cloud-sdk-$UBUNTU_CODENAME main" | \
            tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Add package keys
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -            

RUN apt-get update && apt-get install -y google-cloud-sdk

############### End Install GCP Cloud SDK

############### Install Azure Python SDK for Python Dev
RUN pip3 install azure
############### End Install Azure Python SDK for Python Dev

############### Install Terraform
RUN curl https://releases.hashicorp.com/terraform/0.12.23/terraform_0.12.23_linux_amd64.zip > /tmp/terraform.zip
RUN mkdir -p ${HOME}/bin && cd ${HOME}/bin && unzip /tmp/terraform.zip && rm /tmp/terraform.zip
RUN echo 'export PATH=${HOME}/bin:${PATH}' >> ~/.bashrc
############### End Install Terraform

# Log in to Azure
RUN az login --service-principal --username $AZURE_CLI_LOGIN_SP_ID --password $AZURE_CLI_LOGIN_SP_SECRET --tenant $AZURE_CLI_LOGIN_TENANT_ID

ENV EDITOR vim