#!/usr/bin/env bash

set -e

APP_NAME="$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')"
APP_VSN="$(grep 'version:' mix.exs | cut -d '"' -f2)"

APP_NAME_VSN="$APP_NAME-$APP_VSN"
ARTIFACT="$APP_NAME_VSN.tar.gz"

# NB!: Connected to creator host now
# NB!: Requires ssh-agent to be working
# NB!: Requires ssh-add -K to be added

if [ -z "$(ssh-add -L)" ]; then
  echo "Credentials for connection should be provied via agent"
  exit 1
fi

if [ -z "$SERV_HOST" ] || [ -z "$SERV_USER" ]; then
  echo "Serv Host and Serv User should be provided"
  exit 1
fi

echo "Begin: Moving Artifact"
echo "[$ARTIFACT] is moving to server $SERV_USER@$SERV_HOST:/opt/$APP_NAME_VSN/$ARTIFACT"

ssh $SERV_USER@$SERV_HOST "mkdir -p /opt/$APP_NAME_VSN"
scp $PWD/rel/artifacts/$ARTIFACT $SERV_USER@$SERV_HOST:/opt/$APP_NAME_VSN/$ARTIFACT

echo "End: Moving Artifact"

echo "Begin: Artifact Extraction"

ssh $SERV_USER@$SERV_HOST "cd /opt/$APP_NAME_VSN/ && tar -xvzf $ARTIFACT && rm $ARTIFACT"

echo "End: Artifact Extraction"

exit 0