#!/usr/bin/env bash

set -e

cd /opt/build

APP_NAME="$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')"
APP_VSN="$(grep 'version:' mix.exs | cut -d '"' -f2)"

mkdir -p /opt/build/rel/artifacts

# Install updated versions of hex/rebar
mix local.rebar --force
mix local.hex --if-missing --force

export MIX_ENV=prod

# Fetch deps and compile
mix deps.get
# Run an explicit clean to remove any build artifacts from the host
mix do clean, compile --force
# Build the release
# And Copy tarball to output
# TODO: Refactoring
if [ "$UPGRADE" = "true" ]; then
  echo "--- UPGRADE ---"
  mix release --upgrade
  mkdir -p /opt/build/rel/artifacts/$APP_VSN

  cp "_build/prod/rel/$APP_NAME/releases/$APP_VSN/$APP_NAME.tar.gz" rel/artifacts/$APP_VSN/"$APP_NAME.tar.gz"
else
  mix release
  
  cp "_build/prod/rel/$APP_NAME/releases/$APP_VSN/$APP_NAME.tar.gz" rel/artifacts/"$APP_NAME.tar.gz"
fi

exit 0
