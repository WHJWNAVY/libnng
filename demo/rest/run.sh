#!/bin/sh

INSTALL_DIR=${INSTALL_PKGEXE_PATH}
NNG_REST_SERVER=${INSTALL_DIR}/nng-rest-server

env PORT=8888  # default
${NNG_REST_SERVER} & rest_server=$!

curl -d ABC http://127.0.0.1:8888/api/rest/rot13; echo
curl -d ABC http://127.0.0.1:8888/api/rest/rot13; echo

kill $rest_server
