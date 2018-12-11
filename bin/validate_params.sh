#!/usr/bin/env bash

set -e

. $PWD/bin/common.sh --source-only

# NB!: Connected to creator host now
# NB!: Requires ssh-agent to be working
# NB!: Requires ssh-add -K to be added

if [ -z "$(ssh-add -L)" ]; then
  log_error "Credentials for connection should be provied via agent"
  exit 1
fi

if [ -z "$RHOST" ]; then
  log_error "RHOST should be provided"
  exit 1
fi

if [ -z "$DBHOST" ]; then
  log_error "Remote Database Host should be provided"
  exit 1
fi