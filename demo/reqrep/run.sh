#!/bin/sh

INSTALL_DIR=${INSTALL_PKGEXE_PATH}
NNG_REQREP=${INSTALL_DIR}/nng-reqrep

${NNG_REQREP} server tcp://127.0.0.1:8899 &
${NNG_REQREP} client tcp://127.0.0.1:8899