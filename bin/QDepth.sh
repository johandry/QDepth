#!/bin/sh

source ../configure/QDepth.conf

JAVA=${JAVA_HOME}/bin/java

MQ_JAR=${MQ_HOME}/lib/com.ibm.mq.jar
MQ_JMS_JAR=${MQ_HOME}/lib/com.ibm.mqjms.jar
MQ_CONNECTOR_JAR=${MQ_HOME}/lib/connector.jar
MQ_JMQI_JAR=${MQ_HOME}/lib/com.ibm.mq.jmqi.jar

CP=" -classpath ${MY_HOME}:${MQ_JAR}:${MQ_JMS_JAR}:${MQ_CONNECTOR_JAR}:${MQ_JMQI_JAR} "

verbose=${DEF_VERBOSE}
server=${DEF_SERVER}
port=${DEF_PORT}
channel=${DEF_CHANNEL}
qmgr=${DEF_QMGR}
queue=${DEF_QUEUE}

while [ $# -gt 0 ]
do
  case "$1" in
    -v)  verbose=true;;
    -s)  server=$2; shift;;
    -p)  port=$2; shift;;
    -c)  channel=$2; shift;;
    -qm) qmgr=$2; shift;;
    -h)  echo "Usage: $0 [-h] [-v] [-s server] [-p port] [-c channel] [-qm queue_manager] [queue]";
         echo ;
         echo "-s:  MQ Server to connect. By default is ${DEF_SERVER}";
         echo "-p:  MQ Port. By default is ${DEF_PORT}";
         echo "-c:  MQ Channel. By default is ${DEF_CHANNEL}";
         echo "-qm: Queue Manager. By default is ${DEF_QMGR}"
         echo "-v:  Execute in verbose mode. Useful to debug";
         echo "-h:  Print this help."
         echo ;
         echo "If there is no queue by default will use '${DEF_QUEUE}'";
         exit;;
    *)   queue=$1;; 
#    -q)  queue=$2; shift;;
  esac
  shift
done

properties="-DVerbose=${verbose} -DQueue=$queue -DServer=${server} -DPort=${port} -DChannel=${channel} -DQM=${qmgr}"

[ "$verbose" == "true" ] && echo "Execute: ${JAVA} ${CP} ${properties} QDepth"

${JAVA} ${CP} ${properties} QDepth
