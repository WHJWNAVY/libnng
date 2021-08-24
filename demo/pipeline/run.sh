#!/bin/sh

INSTALL_DIR=${INSTALL_PKGEXE_PATH}
PIPELINE_EXE=${INSTALL_DIR}/nng-pipeline

${PIPELINE_EXE} node0 ipc:///tmp/pipeline.ipc & node0=$! && sleep 1
${PIPELINE_EXE} node1 ipc:///tmp/pipeline.ipc "Hello, World!"
${PIPELINE_EXE} node1 ipc:///tmp/pipeline.ipc "Goodbye."
kill $node0