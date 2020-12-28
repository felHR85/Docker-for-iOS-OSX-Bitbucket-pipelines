#!/bin/bash

set -e

BITBUCKET_REPO="/opt/atlassian/pipelines/agent/build"
BASE_REPO=$(basename ${BITBUCKET_REPO})

USER=$(cat ${BITBUCKET_REPO}/config.json | jq -r .user)
PORT=$(cat ${BITBUCKET_REPO}/config.json | jq -r .ssh_port)
SSH_KEY=$(cat ${BITBUCKET_REPO}/config.json | jq -r .ssh_key)
RUN_SCRIPT=$(cat ${BITBUCKET_REPO}/config.json | jq -r .script)
POST_RUN_SCRIPT=$(cat ${BITBUCKET_REPO}/config.json | jq -r .post_script)
REMOTE_REPO=$(cat ${BITBUCKET_REPO}/config.json | jq -r .remote_repo)
IP=$(cat ${BITBUCKET_REPO}/config.json | jq -r .ip)
PASSWORD=$(cat ${BITBUCKET_REPO}/config.json | jq -r .password)

# SSH to the machine and execute run script
sshpass -p ${PASSWORD} scp -o StrictHostKeyChecking=no -P ${PORT} -r ${BITBUCKET_REPO}/ ${USER}@${IP}:${REMOTE_REPO}/
sshpass -p ${PASSWORD} ssh -p ${PORT} ${USER}@${IP} "cd ${REMOTE_REPO}/${BASE_REPO} && bash ${RUN_SCRIPT}"

# Execute post-run script
bash ${BITBUCKET_REPO}/${POST_RUN_SCRIPT} ${USER} ${IP} ${PORT} ${SSH_KEY} ${BITBUCKET_REPO} ${REMOTE_REPO}/${BASE_REPO} ${IP} ${PASSWORD}

exit 0