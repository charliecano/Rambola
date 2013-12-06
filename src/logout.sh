#!/usr/bin/env bash
# Rambola LogoutHook script, backs up ramdisk on logout/restart/shutdown

USER_NAME=$([ -z "${1}" ] && echo "${SUDO_USER}" || echo "${1}")
USER_NAME=$([  -z "${USER_NAME}" ] && echo "`whoami`" || echo "${USER_NAME}")

SOURCE="${BASH_SOURCE[0]}"
while [ -h "${SOURCE}" ]; do # resolve $SOURCE until the file is no longer a symlink
  APP_DEST="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
  SOURCE="$(readlink "${SOURCE}")"
  [[ $SOURCE != /* ]] && SOURCE="${DIR}/${SOURCE}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
APP_DEST="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"

source $APP_DEST/helper.sh $1
SELF=Rambola:$(/usr/bin/basename $0)

shutdown_rambola
