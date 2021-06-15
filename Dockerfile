FROM ubuntu:latest

# Install prerequisites (apt get option addresses WSL clock issue as per: https://github.com/microsoft/WSL/issues/4114)
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York
RUN rm /bin/sh && \
    ln -s /bin/bash /bin/sh && \
    apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false -qq  update&& \
    apt-get install -y\
      tzdata \
      apt-transport-https \      
      software-properties-common\
      dirmngr\
      python3\
      python3-dev\
      python3-distutils\
      python3-venv\
      curl\
      unzip\
      wget \
      git && \
      curl -O https://bootstrap.pypa.io/get-pip.py && \
      python3 get-pip.py 

# Install the Azure CLI  
ARG FORCE_REFRESH  
ARG AZURE_CLI_VERSION
ARG AZURE_CLI_LOGIN_SUBSCRIPTION_ID
ARG AZURE_CLI_LOGIN_TENANT_ID
ARG AZURE_CLI_LOGIN_SP_ID
ARG AZURE_CLI_LOGIN_SP_SECRET
RUN if [ "$AZURE_CLI_VERSION" == "0" ] ; then \
      exit 0; \
    fi && \
      curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
        tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null && \
      AZ_REPO=$(lsb_release -cs) && \
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
          tee /etc/apt/sources.list.d/azure-cli.list && \
    if [ -z "$AZURE_CLI_VERSION" ] ; then \
      apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && apt-get install -y azure-cli; \
    else \
      . /etc/os-release &&\
        apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && apt-get install -y azure-cli=$AZURE_CLI_VERSION-1~$UBUNTU_CODENAME; \
    fi && \
    echo "source /etc/bash_completion.d/azure-cli" >> /root/.bashrc && \
    az login --service-principal --username $AZURE_CLI_LOGIN_SP_ID --password $AZURE_CLI_LOGIN_SP_SECRET --tenant $AZURE_CLI_LOGIN_TENANT_ID && \
    az account set -s $AZURE_CLI_LOGIN_SUBSCRIPTION_ID
############### End Install Azure CLI

############### Install AWS CLI

# Install PIP and AWS CLI and set PATH (Replace uncommente with commented if you want CLI v1)
#RUN  pip3 install awscli --upgrade --user --no-warn-script-location && \
#      echo "export PATH=/root/.local/bin:$PATH" >> /root/.bashrc
ARG AWS_CLI_VERSION
RUN if [ "$AWS_CLI_VERSION" == "0" ] ; then \
      exit 0; \
    fi && \
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
       cd /tmp && \
       unzip awscliv2.zip && \
       rm /tmp/awscliv2.zip && \
       /bin/sh ./aws/install
############### End Install AWS CLI


############### Install GCP Cloud SDK           
ARG GCP_CLI_VERSION
RUN if [ "$GCP_CLI_VERSION" == "0" ] ; then \
      exit 0; \
    fi && \
    . /etc/os-release &&\
    echo "deb http://packages.cloud.google.com/apt cloud-sdk-$UBUNTU_CODENAME main" | \
          tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \ 
    if [ -z "$GCP_CLI_VERSION" ] ; then \
      apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && apt-get install -y google-cloud-sdk; \
    else \
      apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && apt-get install -y google-cloud-sdk=$GCP_CLI_VERSION-0; \
    fi

############### End Install GCP Cloud SDK

############### Install Azure Python SDK for Python Dev
ARG AZURE_SDK_VERSION
RUN if [ "$AZURE_SDK_VERSION" == "0" ] ; then \
      exit 0; \
    fi && \
    if [ -z "$AZURE_SDK_VERSION" ] ; then \
      pip3 install azure; \
    else \
      pip3 install azure=$AZURE_SDK_VERSION; \
    fi 
############### End Install Azure Python SDK for Python Dev

############### Install Terraform
ARG TERRAFORM_VERSION
RUN if [ "$TERRAFORM_VERSION" == "0" ] ; then \
      exit 0; \
    fi && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip && \
      mkdir -p ${HOME}/bin && \
       cd ${HOME}/bin && \
       unzip /tmp/terraform.zip && \
       rm /tmp/terraform.zip && \
       echo 'export PATH=${HOME}/bin:${PATH}' >> ~/.bashrc && \
       echo "export ARM_SUBSCRIPTION_ID=${AZURE_CLI_LOGIN_SUBSCRIPTION_ID}" >> ~/.bashrc && \
       echo "export ARM_TENANT_ID=${AZURE_CLI_LOGIN_TENANT_ID}" >> ~/.bashrc && \
       echo "export ARM_CLIENT_ID=${AZURE_CLI_LOGIN_SP_ID}" >> ~/.bashrc && \
       echo "export ARM_CLIENT_SECRET=${AZURE_CLI_LOGIN_SP_SECRET}" >> ~/.bashrc
############### End Install Terraform

# Install helm by retrieving install script from git and executing
ARG HELM_VERSION
RUN if [ "$HELM_VERSION" == "0" ] ; then \
      exit 0; \
    fi && \
    if [ -z "$HELM_VERSION" ] ; then \
      curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > install_helm.sh &&  /bin/sh install_helm.sh; \
    else \
      curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > install_helm.sh &&  /bin/sh install_helm.sh --version v${HELM_VERSION}; \
    fi

# Install kubectl  by retrieving install script and executing
ARG KUBECTL_VERSION
RUN if [ "$KUBECTL_VERSION" == "0" ] ; then \
      exit 0; \
    fi && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \ 
    if [ -z "$KUBECTL_VERSION" ] ; then \
      apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && apt-get install -y kubectl; \
    else \
      apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && apt-get install -y kubectl=$KUBECTL_VERSION-00; \
    fi

# Log in to Azure and Git (VS Code handles the credentials assuming I've used them there)

ARG GIT_USERNAME
ARG GIT_USER_EMAIL
RUN git config --global user.name $GIT_USERNAME && git config --global user.email $GIT_USER_EMAIL

# Install Azure Functions Core Tools for Functions Dev
ARG AZURE_FUNCTIONS_TOOLS_VERSION
RUN if [ "$AZURE_FUNCTIONS_TOOLS_VERSION" == "0" ] ; then \
      exit 0; \
    fi && \
    . /etc/os-release &&\
      wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb && \
      dpkg -i packages-microsoft-prod.deb && \ 
    if [ -z "$AZURE_FUNCTIONS_TOOLS_VERSION" ] ; then \
      apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && apt-get install -y azure-functions-core-tools-3; \
    else \
      apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Check-Date=false update && apt-get install -y azure-functions-core-tools-3=$AZURE_FUNCTIONS_TOOLS_VERSION-1; \
    fi

# Install Bicep
ARG BICEP_VERSION
RUN if [ "$BICEP_VERSION" == "0" ] ; then \
      exit 0; \
    fi && \
    curl -Lo bicep https://github.com/Azure/bicep/releases/$BICEP_VERSION/download/bicep-linux-x64 && \
    chmod +x ./bicep && \
    mv ./bicep /usr/local/bin/bicep && \
    echo $BICEP_VERSION

ENV EDITOR vim