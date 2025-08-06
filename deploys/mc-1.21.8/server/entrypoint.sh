#!/usr/bin/env sh

cd world-data/



log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*"
}



if [ -z "$(ls -A)" ]; then

  log "Initializing Files"
  java -Xms6144M -Xmx6144M -jar $SERVER_JAR nogui

  log "Agreeing to EULA"
  echo eula=true > eula.txt

  log "Allowing for cracked players"
  if [ -f server.properties ]; then
    if grep -q '^online-mode=' server.properties; then
      sed -i 's/^online-mode=.*/online-mode=false/' server.properties
    else
      echo 'online-mode=false' >> server.properties
    fi
  else
    echo "server.properties file does not exist."
  fi

  log "Copying Plugins"
  mv $SERVER_PLUGINS plugins/.

  log "Making Backup Folder"
  mkdir -p backup
fi


#Makes a backup everytime server container is restarted
export BACKUP_FOLDER="backup/$(date '+%Y-%m-%d %H:%M:%S')"
mkdir -p "$BACKUP_FOLDER"
cp -r world "$BACKUP_FOLDER/."
cp -r world_nether "$BACKUP_FOLDER/."
cp -r world_the_end "$BACKUP_FOLDER/."


while [ true ]; do
    java -Xms6144M -Xmx6144M -jar $SERVER_JAR nogui
    echo Server restarting...
    echo Press CTRL + C to stop.
done



#### FOR MANUAL EDITS:

### ONLY IF YOU KNOW WHAT YOU ARE DOING

### MAKE SURE YOU ATTACH TO THE CONTAINER AND THEN RUN THESE COMMANDS

### cd world-data/
### java -Xms6144M -Xmx6144M -jar $SERVER_JAR nogui
### mv $SERVER_PLUGINS plugins/.