#!/bin/sh

INSTALL_DIR=${INSTALL_PKGEXE_PATH}
NNGBUS_EXE=${INSTALL_DIR}/nng-bus

${NNGBUS_EXE} node0 ipc:///tmp/node0.ipc ipc:///tmp/node1.ipc ipc:///tmp/node2.ipc & node0=$!
${NNGBUS_EXE} node1 ipc:///tmp/node1.ipc ipc:///tmp/node2.ipc ipc:///tmp/node3.ipc & node1=$!
${NNGBUS_EXE} node2 ipc:///tmp/node2.ipc ipc:///tmp/node3.ipc & node2=$!
${NNGBUS_EXE} node3 ipc:///tmp/node3.ipc ipc:///tmp/node0.ipc & node3=$!
sleep 5
kill $node0 $node1 $node2 $node3