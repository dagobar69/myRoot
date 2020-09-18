#!/usr/bin/ksh

. /home/oracle/dball.env

WORK_DIR=/dball/INPAS/NAUTILUS
DATA_DIR=$WORK_DIR/data
LOG_DIR=$WORK_DIR/log
SQL_DIR=$WORK_DIR/sql
CFG_DIR=$WORK_DIR/cfg

if [[ $1 = "" ]]
then
	EPOCH_TIME=$(date '+%s')
	let EPOCH_TIME=$EPOCH_TIME-86400
	DATA=$(date -d @$EPOCH_TIME '+%Y%m%d')
	DATAE=$(date -d @$EPOCH_TIME '+%d/%m/%Y')
else
	DATA=$1
	DATAE=$(date '+%d/%m/%Y')
fi

RETENTION=5

DATA_FILE="NAU_ABAM_$DATA.csv"
OK_FILE="NAU_ABAM_$DATA.OK"
TAR_FILE="NAU_ABAM_$DATA.tar"
GZ_FILE="NAU_ABAM_$DATA.tar.gz"
LOG_FILE="CreaFileOpera.log"

HOSTS_FILE=HostsList.def
SFTP_SCRIPT=CreaFileOpera.ftp

if [[ -e $DATA_DIR/$GZ_FILE ]]
then
	echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - File $GZ_FILE per il giorno $DATAE gia' presente. Estrazione non necessaria" >> $LOG_DIR/$LOG_FILE
else
	echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Inizio estrazione allarmi per il giorno $DATAE" >> $LOG_DIR/$LOG_FILE

	sqlplus -s repoalarm/alarmrep0 <<EOF
set timing on
exec dballutil.creaNautilus('$DATA');
exit;
EOF

	echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Estratti $(wc -l $DATA_DIR/$DATA_FILE | awk '{print $1}') allarmi per il giorno $DATAE" >> $LOG_DIR/$LOG_FILE
fi

if [[ -e $DATA_DIR/$DATA_FILE && -e $DATA_DIR/$OK_FILE ]]
then
	if [[ ! -e $DATA_DIR/$TAR_FILE && ! -e $DATA_DIR/$GZ_FILE ]]
	then
		echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Creazione file $GZ_FILE per il giorno $DATAE" >> $LOG_DIR/$LOG_FILE
		cd $DATA_DIR
		tar cf $TAR_FILE $DATA_FILE $OK_FILE
		gzip $DATA_DIR/$TAR_FILE
		rm -f $DATA_DIR/$DATA_FILE $DATA_DIR/$OK_FILE
	else
		if [[ ! -e $DATA_DIR/$TAR_FILE ]]
		then
			echo -e "$(date '+%d/%m/%Y %H:%M:%S') - ERROR - ATTENZIONE !!! Il file $DATA_DIR/$TAR_FILE esiste gia'" >> $LOG_DIR/$LOG_FILE
		fi

		if [[ ! -e $DATA_DIR/$GZ_FILE ]]
		then
			echo -e "$(date '+%d/%m/%Y %H:%M:%S') - ERROR - ATTENZIONE !!! Il file $DATA_DIR/$GZ_FILE esiste gia'" >> $LOG_DIR/$LOG_FILE
		fi
	fi
else
	if [[ ! -e $DATA_DIR/$DATA_FILE ]]
	then
		echo -e "$(date '+%d/%m/%Y %H:%M:%S') - ERROR - ATTENZIONE !!! Il file $DATA_DIR/$DATA_FILE non e' stato prodotto" >> $LOG_DIR/$LOG_FILE
	fi

	if [[ ! -e $DATA_DIR/$OK_FILE ]]
	then
		echo -e "$(date '+%d/%m/%Y %H:%M:%S') - ERROR - ATTENZIONE !!! Il file $DATA_DIR/$OK_FILE non e' stato prodotto" >> $LOG_DIR/$LOG_FILE
	fi
fi

if [[ -e $DATA_DIR/$GZ_FILE ]]
then
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
			echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Inizio trasferimento file $GZ_FILE su $SFTP_HOST per $SFTP_DEST" >> $LOG_DIR/$LOG_FILE

			if [[ $SFTP_METHOD = "scp" ]]
			then
				scp -o StrictHostKeyChecking=no -qp $DATA_DIR/$GZ_FILE $SFTP_USER@$SFTP_HOST:$SFTP_PATH/$GZ_FILE

				if [[ $? -eq 0 ]]
				then
					echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Trasferimento completato con successo" >> $LOG_DIR/$LOG_FILE
				else
					echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Trasferimento non completato" >> $LOG_DIR/$LOG_FILE
				fi
			else
				echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Creazione sftp batch script" >> $LOG_DIR/$LOG_FILE
				echo "cd $SFTP_PATH" > $LOG_DIR/$SFTP_SCRIPT
				echo "put $DATA_DIR/$GZ_FILE" >> $LOG_DIR/$SFTP_SCRIPT
				echo "bye" >> $LOG_DIR/$SFTP_SCRIPT

				sftp -o StrictHostKeyChecking=no -b $LOG_DIR/$SFTP_SCRIPT $SFTP_USER@$SFTP_HOST

				rm -f $LOG_DIR/$SFTP_SCRIPT

				if [[ $? -eq 0 ]]
				then
					echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Trasferimento completato con successo" >> $LOG_DIR/$LOG_FILE
				else
					echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Trasferimento non completato" >> $LOG_DIR/$LOG_FILE
				fi
			fi
		fi
	done < $CFG_DIR/$HOSTS_FILE

	echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Cancellazione file tar piu' vecchi di $RETENTION giorni" >> $LOG_DIR/$LOG_FILE
	find $DATA_DIR -mtime +$RETENTION -exec rm -f {} \;
fi

#if [[ $1 = "" ]]
#then
	#echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Inizio inserimento allarmi su NAUTILUS per il giorno $DATAE" >> $LOG_DIR/$LOG_FILE

	#sqlplus -s repoalarm/alarmrep0 <<EOF
#set timing on
#exec dballutil.insNautilus('$DATA');
#exit;
#EOF
	#echo -e "$(date '+%d/%m/%Y %H:%M:%S') - INFO - Fine inserimento allarmi su NAUTILUS per il giorno $DATAE" >> $LOG_DIR/$LOG_FILE
#fi

exit 0
