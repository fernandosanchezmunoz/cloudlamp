# CloudLAMP Dockerfile
# Copyright 2018 Google, LLC.
# Authors: Fernando Sanchez <fersanchez@google.com>, Sebastian Weigand <tdg@google.com>

ARG SDK_VERSION=latest

FROM google/cloud-sdk:${SDK_VERSION}

# Update and upgrade the container:
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y unzip

# Download and install terraform:
ENV TF_VERSION "0.11.7"
ENV TF_FILENAME terraform_"${TF_VERSION}"_linux_amd64.zip
ENV TF_URL "https://releases.hashicorp.com/terraform/${TF_VERSION}/${TF_FILENAME}"
ENV TF_BIN "terraform"

RUN curl -O ${TF_URL}
RUN unzip ${TF_FILENAME}
RUN mv ${TF_BIN} /usr/bin

COPY . /terraform
WORKDIR /terraform

# Run init script:
ENTRYPOINT ["/terraform/run.sh"]