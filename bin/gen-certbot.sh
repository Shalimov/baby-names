#!/usr/bin/env bash

set -e

. $PWD/bin/common.sh --source-only

CERTBOT_REMOTE_CMD="
mkdir -p /opt/$APP_NAME &&\
cd /opt/$APP_NAME/ &&\
apt-get update -y &&\
apt-get install -y software-properties-common &&\
add-apt-repository universe &&\
add-apt-repository ppa:certbot/certbot &&\
apt-get update -y &&\
apt-get install -y certbot &&\
certbot certonly --standalone
"

log_success "Begin: SSL Cert Generation"

ssh $RUSER@$RHOST "$CERTBOT_REMOTE_CMD"

log_success "End: SSL Cert Generation"

exit 0
