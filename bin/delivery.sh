#!/usr/bin/env bash

set -e

. $PWD/bin/common.sh --source-only

log_success "Begin: Moving Artifact"
log_info "[$ARTIFACT] is moving to server $RUSER@$RHOST:/opt/$APP_NAME_VSN/$ARTIFACT"

ssh $RUSER@$RHOST "mkdir -p /opt/$APP_NAME_VSN"
scp $PWD/rel/artifacts/$ARTIFACT $RUSER@$RHOST:/opt/$APP_NAME_VSN/$ARTIFACT

log_success "End: Moving Artifact"

log_success "Begin: Artifact Extraction"

ssh $RUSER@$RHOST "cd /opt/$APP_NAME_VSN/ && tar -xvzf $ARTIFACT && rm $ARTIFACT"

log_success "End: Artifact Extraction"

exit 0