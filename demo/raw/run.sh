#!/bin/sh

INSTALL_DIR=${INSTALL_PKGEXE_PATH}
HTTP_RAWDEMO=${INSTALL_DIR}/nng-rawdemo

export URL="tcp://127.0.0.1:55995"
# start the server
${HTTP_RAWDEMO} $URL -s &
# start a bunch of clients
# Note that these all run concurrently!
${HTTP_RAWDEMO} $URL 2 &
${HTTP_RAWDEMO} $URL 2 &
${HTTP_RAWDEMO} $URL 2 &
${HTTP_RAWDEMO} $URL 2 &
${HTTP_RAWDEMO} $URL 2 &