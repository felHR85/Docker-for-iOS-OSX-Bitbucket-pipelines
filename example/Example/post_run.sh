#!/bin/bash
#---- These variables need to be here
USER=$1
IP=$2
PORT=$3
SSH_KEY=$4
BITBUCKET_REPO=$5
REMOTE_REPO=$6
IP=$7
PASSWORD=$8
#-----

mkdir -p build
sshpass -p ${PASSWORD} scp -o StrictHostKeyChecking=no -P ${PORT} -r ${USER}@${IP}:${REMOTE_REPO}/outputs/ .
# scp -o StrictHostKeyChecking=no -P ${PORT} -i /tmp/${SSH_KEY} -r ${USER}@${IP}:${REMOTE_REPO}/outputs/ .
exit $?