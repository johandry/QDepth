#!/bin/sh

source ../configure/QDepth.conf
source ../configure/QDepthMonitor.conf

ROOT_UID=0     # Only users with $UID 0 have root privileges.
E_NOTROOT=67   # Non-root exit error.

if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Must be root to run this script."
  exit $E_NOTROOT
fi

myname=${0##*/}
LOGFILE=${MY_HOME}/${myname%.*}.log

QD=${MY_HOME}/QDepth.sh
QD_OPT=""
CUT="cut -d: -f2"

function log(){  # Writes time and date to log file.
  echo -e "$(date):  $*" >&7     # This *appends* the date to the file.
}

function qcount {
  ${QD} ${QD_OPT} -q $1 | ${CUT}
}

exec 7>> ${LOGFILE}              # Append to ilog file

for q in "${queue[@]}"
do
  qName=$(echo ${q} | cut -d: -f1)
  qLow=$(echo ${q} | cut -d: -f2)
  qUpper=$(echo ${q} | cut -d: -f3)

  count=$(qcount $qName)
  
  # Testing
  #count=49001
  #echo "Count $count. Low: $qLow. Upper: $qUpper"

  status=$($EAG status)

  if [ $count -gt $qUpper ]
  then
    log "Status: $status - Action: \e[31mSTOP\033[0m the agent ($count > $qUpper)"
    ${EAG} stop 
  else
    if [ $count -le $qLow ] 
    then
      log "Status: $status - Action: \e[32mSTART\033[0m the agent ($count <= $qLow)"
       ${EAG} start
    else
      log "Status: $status - Action: \e[34mNONE\033[0m ($qLow < $count < $qUpper)"
    fi
  fi
  
done
