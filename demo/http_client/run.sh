#!/bin/sh

INSTALL_DIR=${INSTALL_PKGEXE_PATH}
HTTP_CLIENT=${INSTALL_DIR}/nng-http-client

${HTTP_CLIENT} http://httpbin.org/ip