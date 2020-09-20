#!/usr/bin/bash

export UTILITY_NAME=`basename $0 .sh`

# WORK_DIR=/dball/INPAS/NAUTILUS
export export WORK_DIR=.
export DATA_DIR=$WORK_DIR/data
export OLD_DATA_DIR=$WORK_DIR/data
export SCRIPTS_DIR=$WORK_DIR/bin
export TMP_DIR=$WORK_DIR/tmp
export LOG_DIR=$WORK_DIR/log
export CFG_DIR=$WORK_DIR/cfg

export RETENTION=5

export DATA_FN_PRFX="alarms-"
export DATA_FN_SFFX=".csv"
export DATA_FILE_CHECK="$DATA_DIR/$DATA_FN_PRFX*$DATA_FN_SFFX"

export RES_FN_PRFX="NAU_ABAM_"
export RES_FN_SFFX=".csv"

export OK_FILE="$BASE_FILE_NAME.OK"
export CONV_FILE="$BASE_FILE_NAME.conv"
export TAR_FILE="$BASE_FILE_NAME.tar"
export GZ_FILE="$BASE_FILE_NAME.tar.gz"
export LOG_FILE="$LOG_DIR/$UTILITY_NAME.log"

export HOSTS_FILE=$CFG_DIR/HostsList.def
export SFTP_SCRIPT=$UTILITY_NAME.ftp

export DATA_FILE_EXT=.txt
export PRCSD_FILE_EXT=.prcsd


export RETENTION=5

export HOSTS_FILE=HostsList.def
export SFTP_SCRIPT=CreaFileOpera.ftp
