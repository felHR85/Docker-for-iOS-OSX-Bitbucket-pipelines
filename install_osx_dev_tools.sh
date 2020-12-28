#!/bin/bash

#TODO: Xcode version as argument

XCODE_VERSION="12.1"

# Install Xcode cli tools by installing brew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

#Install Xcode 
curl -sL -O https://github.com/neonichu/ruby-domain_name/releases/download/v0.5.99999999/domain_name-0.5.99999999.gem
gem install domain_name-0.5.99999999.gem
gem install --conservative xcode-install
rm -f domain_name-0.5.99999999.gem

xcversion install ${XCODE_VERSION}