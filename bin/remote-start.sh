#!/usr/bin/env bash

set -e

. $PWD/bin/common.sh --source-only

REMOTE_CMD="
export DB_HOST=$DBHOST;
export PORT=$PORT;
echo \"PORT: \$PORT | DH: \$DB_HOST\";
/opt/$APP_NAME_VSN/bin/$APP_NAME migrate &&\
/opt/$APP_NAME_VSN/bin/$APP_NAME seeds &&\
/opt/$APP_NAME_VSN/bin/$APP_NAME start;
"

log_success "Begin: Start remotely app in background"

ssh $RUSER@$RHOST "$REMOTE_CMD"

log_success "End: Start remotely app in background"

exit 0
