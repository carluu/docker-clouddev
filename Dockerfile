FROM ubuntu:latest

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV AZURE_CLI_VERSION "0.10.13"
ENV NODEJS_APT_ROOT "node_6.x"
ENV NODEJS_VERSION "6.10.0"

# Install prerequisites
RUN apt-get update -qq && \
    apt-get install -y\
      apt-transport-https \
      lsb-release \
      software-properties-common\
      dirmngr\
      -y

# Install Azure CLI
RUN AZ_REPO=$(lsb_release -cs)\
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
      tee /etc/apt/sources.list.d/azure-cli.list
    
RUN apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
      --keyserver packages.microsoft.com \
      --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF\
    apt-get update -qq &&\
    apt-get install -y azure-cli

ENV EDITOR vim