#!/bin/bash

set -e

echo "Starting Tron Full Node"
echo "java ${JAVA_OPTS} ${JVM_ARGUMENTS} -jar FullNode.jar -c main_net_config.conf"
java $JAVA_OPTS $JVM_ARGUMENTS -jar FullNode.jar -c main_net_config.conf
