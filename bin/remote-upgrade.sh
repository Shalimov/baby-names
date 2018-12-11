#!/usr/bin/env bash

set -e

. $PWD/bin/common.sh --source-only

REMOTE_CMD="
/opt/$APP_NAME/bin/$APP_NAME migrate &&\
/opt/$APP_NAME/bin/$APP_NAME upgrade $APP_VSN;
"

log_success "Begin: Upgrade remotely app in background"

ssh $RUSER@$RHOST "$REMOTE_CMD"

log_success "End: Upgrade remotely app in background"

exit 0
