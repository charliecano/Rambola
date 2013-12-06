#!/usr/bin/env bash
# Rambola timely backup, syncs cache snapshots on time

USER_NAME=$([ -z "${1}" ] && echo "${SUDO_USER}" || echo "${1}")
USER_NAME=$([  -z "${USER_NAME}" ] && echo "`whoami`" || echo "${USER_NAME}")

SOURCE="${BASH_SOURCE[0]}"
while [ -h "${SOURCE}" ]; do # resolve $SOURCE until the file is no longer a symlink
  APP_DEST="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
  SOURCE="$(readlink "${SOURCE}")"
  [[ $SOURCE != /* ]] && SOURCE="${DIR}/${SOURCE}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
APP_DEST="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"

source $APP_DEST/helper.sh "${USER_NAME}"
#SELF=Rambola:$(basename $0)
#log "SELF=${SELF}|SELFII=$$"
#USER_ID=$(id -u ${USER_NAME})

#OUR_PID=$(ps -ef | grep ${SELF} | grep -v 'grep' | awk -v uid="${USER_ID}" '$1==uid {print $2; exit;}') # Only first occurence from the current user.
#USER_ID=$(id | sed 's/uid=\([0-9]*\).*/\1/')

# Renice ourself to a low priority
#log "Lowering priority from $OUR_PID to 19."
#/usr/bin/renice 19 ${OUR_PID}
/usr/bin/renice 19 $$

# Main loop
while [ 1 ]; do
	sleep ${SLEEP_DELAY}
	
	# Store to snapshot every hour for extra safety (power failure, etc.)
	store_periodically
done
