#!/usr/bin/bash

. ./cfg/nautilusFilesCfg.sh
. $SCRIPTS_DIR/nautilusFilesUtils.sh

fileName=$1

if [[ ! -e $fileName ]]
then

  log_error "File da inoltrare >$filename< non trovato."
  exit 1
fi


while read LINE
do

  SFTP_DEST=$(echo $LINE | awk -F"|" '{print $1}')
  SFTP_HOST=$(echo $LINE | awk -F"|" '{print $2}')
  SFTP_USER=$(echo $LINE | awk -F"|" '{print $3}')
  SFTP_PATH=$(echo $LINE | awk -F"|" '{print $4}')
  SFTP_METHOD=$(echo $LINE | awk -F"|" '{print $5}')
  SFTP_ENABLED=$(echo $LINE | awk -F"|" '{print $6}')

  if [[ $SFTP_ENABLED -eq 1 ]]
  then

    log_info "Inizio trasferimento file $GZ_FILE su $SFTP_HOST per $SFTP_DEST"

    if [[ $SFTP_METHOD = "scp" ]]
    then

      scp -o StrictHostKeyChecking=no -qp $fileName $SFTP_USER@$SFTP_HOST:$SFTP_PATH/$GZ_FILE

      if [[ $? -eq 0 ]]
      then

      log_info "Trasferimento completato con successo"

    else

      log_info "Trasferimento non completato"
    fi

  else

    log_info "Creazione sftp batch script"
    echo "cd $SFTP_PATH" > $LOG_DIR/$SFTP_SCRIPT
    echo "put $fileName" >> $LOG_DIR/$SFTP_SCRIPT
    echo "bye" >> $LOG_DIR/$SFTP_SCRIPT

    sftp -o StrictHostKeyChecking=no -b $LOG_DIR/$SFTP_SCRIPT $SFTP_USER@$SFTP_HOST

    rm -f $LOG_DIR/$SFTP_SCRIPT

    if [[ $? -eq 0 ]]
    then

      log_info "Trasferimento completato con successo"
    else
      log_error "Errore nel trasferimento"
    fi
  fi

done < $CFG_DIR/$HOSTS_FILE

exit 0
