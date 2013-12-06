# Rambola helper - configurations, helper functions

# Auto-filled variables
USER_NAME=$([ -z "${1}" ] && echo "${SUDO_USER}" || echo "${1}")
USER_NAME=$([  -z "${USER_NAME}" ] && echo "`whoami`" || echo "${USER_NAME}")
SELF=Rambola:$(basename $0)

# Constants
AS_USER="sudo -u ${USER_NAME} "
RSYNC="/usr/local/bin/rsync -aNHAXx --delete --fileflags --protect-decmpfs " 
SLEEP_DELAY=60 # re-check count every one minute
let SAFETY_BACKUP_INTERVAL=45 # backup interval in minutes

# Settings
RAMDISK_SIZE=2048
RAMDISK_NAME="${USER_NAME}RDisk"
SNAPSHOT_LOCATION="/Users/${USER_NAME}/Library/CachesSnapshot${RAMDISK_NAME}/"
TIMELY_BACKUP=yes

# Variables
COUNT=0

# Operational function declaration
function log
{
  MSG="${SELF}: $1"
  logger "${MSG}"
  echo "${MSG}"
}

function quit
{
  log "Quiting: $1"
  exit 0
}

function lock_ramdisk
{
   #log "Setting ramdisk lock"
   exec 5>"/Volumes/${RAMDISK_NAME}/.lock.${USER_NAME}"
}

function unlock_ramdisk
{
   #log "Unsetting ramdisk lock"
   exec 5>&-
   #log "Removing lock file"
   $AS_USER rm "/Volumes/${RAMDISK_NAME}/.lock.${USER_NAME}"
}

function create_ramdisk 
{
  # Check if ramdisk is not already created and mounted.
  if [ -z "$(mount | grep '${RAMDISK_NAME}')" ]; then
     #log "Creating Ram disk (\"${RAMDISK_NAME}\") with a size of: ${RAMDISK_SIZE}MB."
     #let RAMDISK_BLOCKSIZE=2048*${RAMDISK_SIZE} # Size in blocks.

     #BLOCK_DEVICE=$($AS_USER hdiutil attach -nomount ram://${RAMDISK_BLOCKSIZE})
     #$AS_USER diskutil eraseVolume HFS+ "${RAMDISK_NAME}" $BLOCK_DEVICE
     
     RAMDISK_BLOCKSIZE=3959731
     log "Creating RAID0 Ramdisk ${RAMDISK_NAME} with a size of: 3.5GB"
     BLOCK_DEVICE_R1=$($AS_USER hdiutil attach -nomount ram://${RAMDISK_BLOCKSIZE})
     BLOCK_DEVICE_R2=$($AS_USER hdiutil attach -nomount ram://${RAMDISK_BLOCKSIZE})
     $AS_USER diskutil erasevolume HFS+ "r1" $BLOCK_DEVICE_R1
     $AS_USER diskutil erasevolume HFS+ "r2" $BLOCK_DEVICE_R2
     $AS_USER diskutil createRAID stripe ${RAMDISK_NAME} HFS+ /Volumes/r1 /Volumes/r2
     
     # Update so every user can write to it while pertaining its own
     # user permissions.
     $AS_USER mount -u -o owner "/Volumes/${RAMDISK_NAME}/"
  else
     log "Ram disk (\"${RAMDISK_NAME}\") already created."
  fi

  #log "Setting global write to {$RAMDISK_NAME}"
  $AS_USER chmod g+w "/Volumes/${RAMDISK_NAME}/"
  #log "Setting ownership of {$RAMDISK_NAME} to root:staff"
  $AS_USER chown root:staff "/Volumes/${RAMDISK_NAME}/"
}

<<SCRATCHDISKSEX
1.25GB
diskutil erasevolume HFS+ "RaidRamDisk" \`hdiutil attach -nomount ram://2650000\`

2.2GB
diskutil erasevolume HFS+ "RaidRamDisk" \`hdiutil attach -nomount ram://4612000\`

3.5GB
diskutil erasevolume HFS+ "r1" \`hdiutil attach -nomount ram://3959731\`
diskutil erasevolume HFS+ "r2" \`hdiutil attach -nomount ram://3959731\`
diskutil createRAID stripe RaidRamDisk HFS+ /Volumes/r1 /Volumes/r2

5.3GB
diskutil erasevolume HFS+ "r1" \`hdiutil attach -nomount ram://3959731\`
diskutil erasevolume HFS+ "r2" \`hdiutil attach -nomount ram://3959731\`
diskutil erasevolume HFS+ "r3" \`hdiutil attach -nomount ram://3959731\`
diskutil createRAID stripe RaidRamDisk HFS+ /Volumes/r1 /Volumes/r2 /Volumes/r3

6.2GB
diskutil erasevolume HFS+ "r1" \`hdiutil attach -nomount ram://4612000\`
diskutil erasevolume HFS+ "r2" \`hdiutil attach -nomount ram://4612000\`
diskutil erasevolume HFS+ "r3" \`hdiutil attach -nomount ram://4612000\`
diskutil createRAID stripe RaidRamDisk HFS+ /Volumes/r1 /Volumes/r2 /Volumes/r3

8.2GB
diskutil erasevolume HFS+ "r1" \`hdiutil attach -nomount ram://4612000\`
diskutil erasevolume HFS+ "r2" \`hdiutil attach -nomount ram://4612000\`
diskutil erasevolume HFS+ "r3" \`hdiutil attach -nomount ram://4612000\`
diskutil erasevolume HFS+ "r4" \`hdiutil attach -nomount ram://4612000\`
diskutil createRAID stripe RaidRamDisk HFS+ /Volumes/r1 /Volumes/r2 /Volumes/r3 /Volumes/r4
SCRATCHDISKSEX

function restore_contents_from_snapshot
{
  # Check if snapshot path exists
  if [ ! -d ${SNAPSHOT_LOCATION} ]; then
      #log "Snapshot location missing: \"${SNAPSHOT_LOCATION}\" not found."
      log "Creating missing snapshot path"
      $AS_USER mkdir -p ${SNAPSHOT_LOCATION}
  fi
  
   DEST="/Volumes/${RAMDISK_NAME}/"
   log "Restoring snapshot from ${SNAPSHOT_LOCATION} to ${DEST}."
   $AS_USER $RSYNC "$SNAPSHOT_LOCATION" "$DEST"
   log "Finished restoring snapshot from \"${SNAPSHOT_LOCATION}\" to \"${DEST}\"."
}

function store_contents_on_snapshot
{
  SOURCE="/Volumes/${RAMDISK_NAME}/"
  if [ ! -d "$SOURCE" ]; then
   quit "Directory: \"$SOURCE\" does not exist."
  fi 
  
  log "Storing snapshot from \"${SOURCE}\" to \"${SNAPSHOT_LOCATION}\"."
  $AS_USER "$RSYNC '${SOURCE}' '${SNAPSHOT_LOCATION}'"
}


function store_periodically
{
   let COUNT=COUNT+1
   if [[ $COUNT -gt $SAFETY_BACKUP_INTERVAL ]]; then
    log "Starting power failure preventive backup."
    store_contents_on_snapshot
    let COUNT=0
   fi
}

function shutdown_rambola
{
  log "Shutdown request received."
  store_contents_on_snapshot
  unlock_ramdisk
  quit "Shutdown request finished."
}
