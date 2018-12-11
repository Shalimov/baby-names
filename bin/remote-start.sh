#!/usr/bin/env bash

set -e

. $PWD/bin/common.sh --source-only

REMOTE_CMD="
export API_HOST=$RHOST;
export DB_HOST=$DBHOST;
export PORT=$PORT;
/opt/$APP_NAME/bin/$APP_NAME seed &&\
/opt/$APP_NAME/bin/$APP_NAME start;
"

log_success "Begin: Start remotely app in background"

ssh $RUSER@$RHOST "$REMOTE_CMD"

log_success "End: Start remotely app in background"

exit 0
