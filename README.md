# Docker for iOS/OSX Bitbucket pipelines

[![dockeri.co](https://dockeri.co/image/felhr85/docker-for-ios-bitbucket-pipelines)](https://hub.docker.com/r/felhr85/docker-for-ios-bitbucket-pipelines)

## Introduction
[Bitbucket Pipelines](https://bitbucket.org/product/en/features/pipelines) doesn't support iOS/OSX builds. This simple Docker image tries to solve this by connecting to:

- [An AWS Mac instance](https://aws.amazon.com/es/blogs/aws/new-use-mac-instances-to-build-test-macos-ios-ipados-tvos-and-watchos-apps/)
- Your own OSX machine with remote login. [This could be used with the multiple providers that offers Mac mini servers](https://www.datacenterknowledge.com/archives/2014/02/14/macminivault-expands-at-phoenix-nap)

## Pull Docker Image
```shell
docker pull felhr85/docker-for-ios-bitbucket-pipelines:1.0.0
```

## What do we need to add in out project?
The next files need to be added to the root of your Bitbucket project.

- Bitbucket pipelines standard yaml file.
- A config file (config.json) with configuration information.
- AWS config and credentials (aws_config and aws_credentials) files if necessary.
- A run.sh script that contains our build commands.
- A post_run.sh script for downloading whatever we need from the finished build process.
- A ssh key if using Aws.

## Example using AWS

[The first step is to create a new Mac OSX instance in EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-mac-instances.html). And we add to the project our aws credentials and the ssh key we will use.

***aws_config***
```
[default]
region = us-east-2
output = json
```

***aws_config***
```
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

Next we add a config.json file as follows
```javascript
{
    "instance_id" : "i-017f8354e2dc69c4f",
    "remote_repo": "~",
    "instance_user" : "ec2-user",
    "ssh_port" : 22,
    "ssh_key" : "test-key.pem",
    "script" : "run.sh",
    "post_script" : "post_run.sh"
}
```

We need to define what compile actions we want to perform and what files we want to bring back to our docker instance. That's done in both run.sh and post_run.sh scripts respectively.

***run.sh***
```shell
#!/bin/bash
xcodebuild -scheme Example build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED="NO" CONFIGURATION_BUILD_DIR=./outputs/
exit $?
```

***post_run.sh***
```shell
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
scp -o StrictHostKeyChecking=no -P ${PORT} -i /tmp/${SSH_KEY} -r ${USER}@${IP}:${REMOTE_REPO}/outputs/ .
exit $?
```

Finally we need a bitbucket_pipelines.yml
```yaml
steps:
  - step: &build_ios
      name: Build iOS
      image: felhr85/docker-for-ios-bitbucket-pipelines:latest
      script:
        - bash pipelines_aws.sh 
pipelines:
  branches:
    master:
      - step: *build_ios    
```

## Example using OSX with remote Login

First, enable remote login in your OSX machine

```shell
sudo systemsetup -f setremotelogin on
```

Next we add a config.json file as follows
```javascript
{

    "ip": "172.158.12.54",
    "user": "my_user",
    "password": "my_password",
    "remote_repo": "~",
    "ssh_port" : 22,
    "script" : "run.sh",
    "post_script" : "post_run.sh"
}
```
We need to define what compile actions we want to perform and what files we want to bring back to our docker instance. That's done in both run.sh and post_run.sh scripts respectively.

***run.sh***
```shell
#!/bin/bash
xcodebuild -scheme Example build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED="NO" CONFIGURATION_BUILD_DIR=./outputs/
exit $?
```

***post_run.sh***
```shell
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
exit $?
```
Finally we need a bitbucket_pipelines.yml
```yaml
steps:
  - step: &build_ios
      name: Build iOS
      image: felhr85/docker-for-ios-bitbucket-pipelines:latest
      script:
        - bash pipelines_server.sh 
pipelines:
  branches:
    master:
      - step: *build_ios    
```