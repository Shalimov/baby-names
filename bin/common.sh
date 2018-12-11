FRED="\033[31m" # foreground red
FGRN="\033[32m" # foreground green
FBLU="\033[1;36m" # foreground yellow

log_success() {
  echo -e "$FGRN$1"
}

log_error() {
  echo -e "$FRED$1"
}

log_info() {
  echo -e "$FBLU$1"
}

APP_NAME="$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')"
APP_VSN="$(grep 'version:' mix.exs | cut -d '"' -f2)"
APP_NAME_VSN="$APP_NAME-$APP_VSN"
ARTIFACT="$APP_NAME.tar.gz"

# Set default user
if [ -z "$RUSER" ]; then
: "${RUSER:=root}"
log_info "RUSER is not set, using \"root\" by default"
fi

# Set default user
if [ -z "$PORT" ]; then
: "${PORT:=80}"
log_info "PORT is not set, using \"80\" by default"
fi