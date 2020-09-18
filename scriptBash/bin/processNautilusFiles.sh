#!/usr/bin/bash

. ./cfg/nautilusFilesCfg.sh
. $SCRIPTS_DIR/nautilusFilesUtils.sh

# to test if needed UTILITY_NAME=`basename $0 .sh`
echo UTILITY_NAME $UTILITY_NAME


    # 
    # If non given data, yesterday is used
    #   else give date until today.
    #
# if [[ $1 = "" ]]
# then
	# EPOCH_TIME=$(date '+%s')
	# let EPOCH_TIME=$EPOCH_TIME-86400
	# DATA=$(date -d @$EPOCH_TIME '+%Y%m%d')
	# DATAE=$(date -d @$EPOCH_TIME '+%d/%m/%Y')
# echo DATA $DATA
# echo DATAE $DATAE
# else
	# DATA=$1
	# DATAE=$(date '+%d/%m/%Y')
# fi


# IFS=" "
todayTime=$(date '+%s')
let yesterdayTime=$todayTime-86400
expctdFT=$(date -d @$EPOCH_TIME '+%Y%m%d')
fmtExpctdFT=$(date -d @$EPOCH_TIME '+%d/%m/%Y')

foundCurrentFile=false

for origFile in $DATA_FILE_CHECK
do
      # get file data.
  fileTime=$(date '+%s')
  fileData=$(date -d @$fileTime '+%Y%m%d')
  fileDataFrmtd=$(date -d @$fileTime '+%d/%m/%Y')

  log_info "Trovato file $origFile del giorno $fileDataFrmtd"

  if [ $fileData = expctdFT ]
    foundCurrentFile=true;

  #
  # File conversion
  #
  log_info "Conversione del file $origFile"

  resFile=$RES_FN_PRFX$fileData$RES_FN_SFFX
  cat $origFile|./processNautilusFile.ksh >$TMP_DIR/$resFile

  gzResFile=$resFile.tar.gz
  tar -C $TMP_DIR -czf $TMP_DIR/$gzResFile $resFile

  dispatchFile.sh $TMP_DIR/$gzResFile

  echo rm $TMP_DIR/$resFile
  echo mv $origFile $TMP_DIR/$gzResFile $OLD_DATA_DIR

done

if [ $foundCurrentFile = false ]
fi

  log_error "File per il giorno $fmtExpctdFT non presente."
fi

log_info "Cancellazione file tar piu' vecchi di $RETENTION giorni"
find $OLD_DATA_DIR -mtime +$RETENTION -exec rm -f {} \;

exit 0
