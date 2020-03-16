FROM ubuntu:latest

ARG AZURE_CLI_LOGIN_TENANT_ID
ARG AZURE_CLI_LOGIN_SP_ID
ARG AZURE_CLI_LOGIN_SP_SECRET
ARG GIT_USERNAME
ARG GIT_USER_EMAIL

ARG AZURE_CLI_VERSION
ARG GCP_CLI_VERSION
ARG AZURE_SDK_VERSION
ARG HELM_VERSION
ARG TERRAFORM_VERSION
ARG KUBECTL_VERSION

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
      git && \
      curl -O https://bootstrap.pypa.io/get-pip.py && \
      python3 get-pip.py 

# Add Azure CLI/GCP/Kubectl source and package keys
RUN . /etc/os-release &&\
      echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $UBUNTU_CODENAME main" | \
            tee /etc/apt/sources.list.d/azure-cli.list && \
      apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
      --keyserver packages.microsoft.com \
      --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF && \
      echo "deb http://packages.cloud.google.com/apt cloud-sdk-$UBUNTU_CODENAME main" | \
            tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
      curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
      echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
      curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
      apt-get update -qq

# Install helm by retrieving install script from git and executing
RUN if [ -z "$HELM_VERSION" ] ; then \
      curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > install_helm.sh &&  /bin/sh install_helm.sh; \
    else \
      curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > install_helm.sh &&  /bin/sh install_helm.sh --version v${HELM_VERSION}; \
    fi

# Install the Azure CLI    
RUN if [ -z "$AZURE_CLI_VERSION" ] ; then \
      apt-get install -y azure-cli; \
    else \
      . /etc/os-release &&\
        apt-get install -y azure-cli=$AZURE_CLI_VERSION-1~$UBUNTU_CODENAME; \
    fi

# Source the auto complete script
RUN echo "source /etc/bash_completion.d/azure-cli" >> /root/.bashrc

############### End Install Azure CLI

############### Install AWS CLI

# Install PIP and AWS CLI and set PATH (Replace uncommente with commented if you want CLI v1)
#RUN  pip3 install awscli --upgrade --user --no-warn-script-location && \
#      echo "export PATH=/root/.local/bin:$PATH" >> /root/.bashrc
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
       cd /tmp && \
       unzip awscliv2.zip && \
       rm /tmp/awscliv2.zip && \
       /bin/sh ./aws/install
############### End Install AWS CLI


############### Install GCP Cloud SDK           

RUN if [ -z "$GCP_CLI_VERSION" ] ; then \
      apt-get install -y google-cloud-sdk; \
    else \
      apt-get install -y google-cloud-sdk=$GCP_CLI_VERSION-0; \
    fi

############### End Install GCP Cloud SDK

############### Install Azure Python SDK for Python Dev
RUN if [ -z "$AZURE_SDK_VERSION" ] ; then \
      pip3 install azure; \
    else \
      pip3 install azure=$AZURE_SDK_VERSION; \
    fi 
############### End Install Azure Python SDK for Python Dev

############### Install Terraform
RUN curl https://releases.hashicorp.com/terraform/0.12.23/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip && \
      mkdir -p ${HOME}/bin && \
       cd ${HOME}/bin && \
       unzip /tmp/terraform.zip && \
       rm /tmp/terraform.zip && \
       echo 'export PATH=${HOME}/bin:${PATH}' >> ~/.bashrc
############### End Install Terraform

# Install kubectl  by retrieving install script and executing
RUN if [ -z "$KUBECTL_VERSION" ] ; then \
      apt-get install -y kubectl; \
    else \
      apt-get install -y kubectl=$KUBECTL_VERSION-00; \
    fi


# Log in to Azure
RUN az login --service-principal --username $AZURE_CLI_LOGIN_SP_ID --password $AZURE_CLI_LOGIN_SP_SECRET --tenant $AZURE_CLI_LOGIN_TENANT_ID

# Configure Git (VS Code handles the credentials assuming I've used them there)
RUN git config --global user.name $GIT_USERNAME && git config --global user.email $GIT_USER_EMAIL

ENV EDITOR vim