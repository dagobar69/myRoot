#!/usr/bin/bash

. ./cfg/nautilusFilesCfg.sh
. $SCRIPTS_DIR/nautilusFilesUtils.sh

if [ "$#" -ne 1 ]; then

    log_error "Passare il nome del file da inviare alla chiamata."
    exit 1;
fi

fileName=$1

if [[ ! -e $fileName ]]
then

  log_error "File da inoltrare >$fileName< non trovato."
  exit 1
fi

destFileName=`basename $fileName`


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

    log_info "Inizio trasferimento file $fileName su $SFTP_HOST per $SFTP_DEST"

    if [[ $SFTP_METHOD = "scp" ]]
    then

      echo scp -o StrictHostKeyChecking=no \
        -qp $fileName $SFTP_USER@$SFTP_HOST:$SFTP_PATH/$destFileName

      scp -o StrictHostKeyChecking=no \
        -qp $fileName $SFTP_USER@$SFTP_HOST:$SFTP_PATH/$destFileName

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

      sftp -o StrictHostKeyChecking=no \
        -b $LOG_DIR/$SFTP_SCRIPT $SFTP_USER@$SFTP_HOST

      if [[ $? -eq 0 ]]
      then

        log_info "Trasferimento completato con successo"
      else

        log_error "Errore nel trasferimento"
      fi

      rm -f $LOG_DIR/$SFTP_SCRIPT
    fi
  fi

done < $HOSTS_FILE

exit 0
