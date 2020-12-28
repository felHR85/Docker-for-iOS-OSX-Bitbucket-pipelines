FROM ubuntu:18.04

WORKDIR /tmp

RUN apt-get clean && \
    apt-get update -qq

RUN apt-get -y install python3-pip
RUN pip3 install awscli
RUN apt-get install -y openssh-client
RUN apt-get install -y sshpass
RUN apt-get install -y jq
RUN apt-get install -y vim

COPY install_osx_dev_tools.sh /tmp/install_osx_dev_tools.sh
COPY README.md /tmp/README.md
COPY pipelines_aws.sh /tmp/pipelines_aws.sh
COPY pipelines_server.sh /tmp/pipelines_server.sh

# Labels
