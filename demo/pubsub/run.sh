#!/bin/sh

INSTALL_DIR=${INSTALL_PKGEXE_PATH}
PUBSUB_EXE=${INSTALL_DIR}/nng-pubsub

${PUBSUB_EXE} server ipc:///tmp/pubsub.ipc & server=$! && sleep 1
${PUBSUB_EXE} client ipc:///tmp/pubsub.ipc client0 & client0=$!
${PUBSUB_EXE} client ipc:///tmp/pubsub.ipc client1 & client1=$!
${PUBSUB_EXE} client ipc:///tmp/pubsub.ipc client2 & client2=$!
sleep 5
kill $server $client0 $client1 $client2