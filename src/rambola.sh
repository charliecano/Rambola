#!/usr/bin/env bash
# Rambola LoginHook script, sets up ramdisk, spawns timely if configured

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
APP_HOME="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

source $APP_HOME/helper.sh $1
SELF=Rambola:$(/usr/bin/basename $0)

# Startup
create_ramdisk
lock_ramdisk 
restore_contents_from_snapshot

if [ "$TIMELY_BACKUP" == "yes" ]; then
  log "Spawning timely.sh for extra safety"
  $APP_HOME/timely.sh $1 &
fi

log "Rambola LoginHook finished."

