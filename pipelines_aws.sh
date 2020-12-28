#!/bin/bash

set -e

BITBUCKET_REPO="/opt/atlassian/pipelines/agent/build"
BASE_REPO=$(basename ${BITBUCKET_REPO})

USER=$(cat ${BITBUCKET_REPO}/config.json | jq -r .instance_user)
PORT=$(cat ${BITBUCKET_REPO}/config.json | jq -r .ssh_port)
SSH_KEY=$(cat ${BITBUCKET_REPO}/config.json | jq -r .ssh_key)
RUN_SCRIPT=$(cat ${BITBUCKET_REPO}/config.json | jq -r .script)
POST_RUN_SCRIPT=$(cat ${BITBUCKET_REPO}/config.json | jq -r .post_script)
INSTANCE_ID=$(cat ${BITBUCKET_REPO}/config.json | jq -r .instance_id)
REMOTE_REPO=$(cat ${BITBUCKET_REPO}/config.json | jq -r .remote_repo)

# Set AWS credentials from aws files in repo
mkdir -p ~/.aws
cp -f ${BITBUCKET_REPO}/aws_credentials ~/.aws/credentials
cp -f ${BITBUCKET_REPO}/aws_config ~/.aws/config

# Run AWS instance
cp ${BITBUCKET_REPO}/${SSH_KEY} /tmp/${SSH_KEY}
chmod 400 /tmp/${SSH_KEY}
aws ec2 start-instances --instance-ids ${INSTANCE_ID}

# Wait till instance is running
INSTANCE_STATUS=""
until [[ "${INSTANCE_STATUS}" =~ "running" ]]; do
    sleep 5
    INSTANCE_STATUS=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --query 'Reservations[0].Instances[0].State.Name')
    echo "Instance status: ${INSTANCE_STATUS}"
done

# It looks like more sleeping is necessary
sleep 10

# SSH to the machine and execute run script
IP=$(aws ec2 describe-instances --instance-id i-0c51830c386eaffaa --query 'Reservations[0].Instances[0].PublicIpAddress' | grep -vE '\[|\]' | awk -F'"' '{ print $2 }')
scp -o StrictHostKeyChecking=no -P ${PORT} -i /tmp/${SSH_KEY} -r ${BITBUCKET_REPO}/ ${USER}@${IP}:${REMOTE_REPO}/
ssh -p ${PORT} -i /tmp/${SSH_KEY} ${USER}@${IP} "cd ${REMOTE_REPO}/${BASE_REPO} && bash ${RUN_SCRIPT}"

# Execute post-run script
bash ${BITBUCKET_REPO}/${POST_RUN_SCRIPT} ${USER} ${IP} ${PORT} ${SSH_KEY} ${BITBUCKET_REPO} ${REMOTE_REPO}/${BASE_REPO}

# Cleanup
aws ec2 stop-instances --instance-ids ${INSTANCE_ID}

exit 0