#!/bin/bash

INSTALL_DIR=${INSTALL_PKGEXE_PATH}
ASYNC_SERVER_EXE=${INSTALL_DIR}/nng-async-server
ASYNC_CLIENT_EXE=${INSTALL_DIR}/nng-async-client

ADDR=ipc:///tmp/async_demo
COUNT=10

${ASYNC_SERVER_EXE} $ADDR &
SERVER_PID=$!
trap "kill $SERVER_PID" 0
typeset -a CLIENT_PID
i=0
sleep 1
while (( i < COUNT ))
do
	i=$(( i + 1 ))
	rnd=$(( RANDOM % 1000 + 500 ))
	echo "Starting client $i: server replies after $rnd msec"
	${ASYNC_CLIENT_EXE} $ADDR $rnd &
	eval CLIENT_PID[$i]=$!
done

i=0
while (( i < COUNT ))
do
	i=$(( i + 1 ))
	wait ${CLIENT_PID[$i]}
done
kill $SERVER_PID
