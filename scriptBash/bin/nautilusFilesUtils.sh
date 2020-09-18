#!/usr/bin/bash

log_error()
{
  echo -e "$(date '+%d/%m/%Y %H:%M:%S') - ERROR - ATTENZIONE !!! $1" >> $LOG_FILE
}

log_info()
{
  echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - $1" >> $LOG_FILE
}

handle_date()
if [[ $1 = "" ]]
then
	EPOCH_TIME=$(date '+%s')
	let EPOCH_TIME=$EPOCH_TIME-86400
	export DATA=$(date -d @$EPOCH_TIME '+%Y%m%d')
	export DATAE=$(date -d @$EPOCH_TIME '+%d/%m/%Y')
else
	export DATA=$1
	export DATAE=$(date '+%d/%m/%Y')
fi
