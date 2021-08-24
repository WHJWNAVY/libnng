#!/bin/sh

INSTALL_DIR=${INSTALL_PKGEXE_PATH}
NNGPAIR_EXE=${INSTALL_DIR}/nng-pair

${NNGPAIR_EXE} node0 ipc:///tmp/pair.ipc & node0=$!
${NNGPAIR_EXE} node1 ipc:///tmp/pair.ipc & node1=$!
sleep 3
kill $node0 $node1