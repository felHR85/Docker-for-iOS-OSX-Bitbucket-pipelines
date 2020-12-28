#!/bin/bash
xcodebuild -scheme Example build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED="NO" CONFIGURATION_BUILD_DIR=./outputs/
exit $?