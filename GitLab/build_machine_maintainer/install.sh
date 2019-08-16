#!/bin/sh

SHELL_DEST_FILE=/usr/local/bin/maintenance_build_machine
PLIST_DEST_FILE=/Library/LaunchDaemons/maintenance_build_machine.plist

if [ -e $PLIST_DEST_FILE ]; then
    sudo launchctl unload $PLIST_DEST_FILE
    sudo rm -f $PLIST_DEST_FILE
fi

sudo cp -r maintenance_build_machine.sh $SHELL_DEST_FILE
sudo chmod +x $SHELL_DEST_FILE

sudo cp -r maintenance_build_machine.plist $PLIST_DEST_FILE

plutil -lint $PLIST_DEST_FILE
sudo chown root $PLIST_DEST_FILE
sudo launchctl load $PLIST_DEST_FILE
