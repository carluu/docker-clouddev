FROM ubuntu:latest

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install prerequisites
RUN apt-get update -qq && \
    apt-get install -y\
      apt-transport-https \      
      software-properties-common\
      dirmngr\
      -y

# Install Azure CLI
RUN . /etc/os-release\
    UBUNTU_CODENAME=$UBUNTU_CODENAME

RUN AZ_REPO=$(lsb_release -cs)\
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $UBUNTU_CODENAME main" | \
      tee /etc/apt/sources.list.d/azure-cli.list
    
RUN apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
      --keyserver packages.microsoft.com \
      --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF
    
RUN apt-get update -qq &&\
    apt-get install -y azure-cli

ENV EDITOR vim