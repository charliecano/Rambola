#!/usr/bin/env bash
# removes loginwindow hooks for Rambola

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

$AS_USER defaults delete com.apple.loginwindow LoginHook
$AS_USER defaults delete com.apple.loginwindow LogoutHook
#$AS_USER rm -rf "${SNAPSHOT_LOCATION}"
