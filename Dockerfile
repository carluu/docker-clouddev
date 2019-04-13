FROM ubuntu:latest

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
      -y

############### Install Azure CLI
#RUN . /etc/os-release\
#    UBUNTU_CODENAME=$UBUNTU_CODENAME

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
RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py

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

############### Install GCP Cloud SDK

ENV EDITOR vim