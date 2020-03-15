FROM ubuntu:latest

ARG AZURE_CLI_LOGIN_TENANT_ID
ARG AZURE_CLI_LOGIN_SP_ID
ARG AZURE_CLI_LOGIN_SP_SECRET
ARG GIT_USERNAME
ARG GIT_USER_EMAIL

ARG AZURE_CLI_VERSION
ARG AWS_CLI_VERSION
ARG GCP_CLI_VERSION
ARG AZURE_PYTHON_VERSION
ARG HELM_VERSION
ARG TERRAFORM_VERSION

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

# Add Azure CLI source
RUN . /etc/os-release &&\
      echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $UBUNTU_CODENAME main" | \
            tee /etc/apt/sources.list.d/azure-cli.list

# Add Azure CLI package keys    
RUN apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
      --keyserver packages.microsoft.com \
      --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF

# Add Google Cloud SDK source
RUN . /etc/os-release &&\
      echo "deb http://packages.cloud.google.com/apt cloud-sdk-$UBUNTU_CODENAME main" | \
            tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Add Google Cloud SDK package keys
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Run a final apt update before doing the rest
RUN apt-get update -qq

# Install helm by retrieving install script from git and executing
RUN if [ -z "$HELM_VERSION" ] ; then \
      curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > install_helm.sh &&  /bin/sh install_helm.sh; \
    else \
      curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > install_helm.sh &&  /bin/sh install_helm.sh --version ${HELM_VERSION}; \
    fi

# Install the Azure CLI    
RUN if [ -z "$AZURE_CLI_VERSION" ] ; then \
      apt-get install -y azure-cli; \
    else \
      apt-get install -y azure-cli=$AZURE_CLI_VERSION-1~$UBUNTU_CODENAME; \
    fi

# Source the auto complete script
RUN echo "source /etc/bash_completion.d/azure-cli" >> /root/.bashrc

############### End Install Azure CLI

############### Install AWS CLI

# Install PIP and AWS CLI and set PATH
RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
      python3 get-pip.py && \
      pip3 install awscli --upgrade --user --no-warn-script-location && \
      echo "export PATH=/root/.local/bin:$PATH" >> /root/.bashrc

############### End Install AWS CLI


############### Install GCP Cloud SDK           

RUN if [ -z "$GCP_CLI_VERSION" ] ; then \
      apt-get install -y google-cloud-sdk; \
    else \
      apt-get install -y google-cloud-sdk=$GCP_CLI_VERSION-1~$UBUNTU_CODENAME; \
    fi

############### End Install GCP Cloud SDK

############### Install Azure Python SDK for Python Dev
RUN pip3 install azure
############### End Install Azure Python SDK for Python Dev

############### Install Terraform
RUN curl https://releases.hashicorp.com/terraform/0.12.23/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > /tmp/terraform.zip
RUN mkdir -p ${HOME}/bin && cd ${HOME}/bin && unzip /tmp/terraform.zip && rm /tmp/terraform.zip &&  echo 'export PATH=${HOME}/bin:${PATH}' >> ~/.bashrc
############### End Install Terraform

# Log in to Azure
RUN az login --service-principal --username $AZURE_CLI_LOGIN_SP_ID --password $AZURE_CLI_LOGIN_SP_SECRET --tenant $AZURE_CLI_LOGIN_TENANT_ID

# Configure Git (VS Code handles the credentials assuming I've used them there)
RUN git config --global user.name $GIT_USERNAME && git config --global user.email $GIT_USER_EMAIL

ENV EDITOR vim