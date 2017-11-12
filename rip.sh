#!/bin/bash
DISK_INFO=$(makemkvcon -r --cache=1 info disc:9999 | grep DRV:0 | sed 's/,/\n/g' | tail -n 2)
DISK_LABEL=$(echo "$DISK_INFO" | head -n 1 | sed 's/"//g')
DISK_PATH=$(echo "$DISK_INFO" | tail -n 1 | sed 's/"//g')
DESTINATION=/out/$DISK_LABEL

if [ -d "$DESTINATION" ]; then
	echo "Disk $DISK_LABEL already ripped at $DESTINATION, skipping"
	exit 0
fi

mkdir -p "$DESTINATION"
chmod 0777 "$DESTINATION"

makemkvcon --decrypt -r --minlength=600 mkv disc:0 all "$DESTINATION"
echo "Completed ripping disk $DISK_LABEL"
eject $DISK_PATH
