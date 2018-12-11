#!/usr/bin/env bash

set -e

. $PWD/bin/common.sh --source-only

log_success "Begin: Moving Artifact"
log_info "[$ARTIFACT] is moving to server $RUSER@$RHOST:/opt/$APP_NAME/..."

ssh $RUSER@$RHOST "mkdir -p /opt/$APP_NAME/releases/$APP_VSN"

if [ "$UPGRADE" = "true" ]; then
  log_info "--- Upgrade ---"
  scp $PWD/rel/artifacts/$APP_VSN/$ARTIFACT $RUSER@$RHOST:/opt/$APP_NAME/releases/$APP_VSN/$ARTIFACT
else
  scp $PWD/rel/artifacts/$ARTIFACT $RUSER@$RHOST:/opt/$APP_NAME/$ARTIFACT

  log_success "Begin: Artifact Extraction"

  ssh $RUSER@$RHOST "cd /opt/$APP_NAME/ && tar -xvzf $ARTIFACT && rm $ARTIFACT"

  log_success "End: Artifact Extraction"
fi

log_success "End: Moving Artifact"


exit 0