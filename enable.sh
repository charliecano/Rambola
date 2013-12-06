#!/usr/bin/env bash
# Rambola installer (unlike Cache2RAM this is based on Login window hooks)

APP_NAME=Rambola

USER_NAME=$([ -z "${1}" ] && echo "${SUDO_USER}" || echo "${1}")
USER_NAME=$([  -z "${USER_NAME}" ] && echo "`whoami`" || echo "${USER_NAME}")

SOURCE="${BASH_SOURCE[0]}"
while [ -h "${SOURCE}" ]; do # resolve $SOURCE until the file is no longer a symlink
  APP_DEST="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
  SOURCE="$(readlink "${SOURCE}")"
  [[ $SOURCE != /* ]] && SOURCE="${DIR}/${SOURCE}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
APP_DEST="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"

source "${APP_DEST}/src/helper.sh" "${USER_NAME}"

function setup()
{
  echo "Adding ${APP_NAME} to LoginHook (needs root)..."
  $AS_USER defaults write com.apple.loginwindow LoginHook "${APP_DEST}/src/rambola.sh"
  $AS_USER defaults write com.apple.loginwindow LogoutHook "${APP_DEST}/src/logout.sh"
}

echo "This will install and setup ${APP_NAME} at ${APP_DEST}"
echo
read -p "Continue (y/n) :"

if [ "${REPLY}" == "y" ]; then
  setup
fi

log "Rambolo enabled!"

