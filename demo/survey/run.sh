#!/bin/sh

INSTALL_DIR=${INSTALL_PKGEXE_PATH}
SURVEY_EXE=${INSTALL_DIR}/nng-survey

${SURVEY_EXE}  server ipc:///tmp/survey.ipc & server=$!
${SURVEY_EXE}  client ipc:///tmp/survey.ipc client0 & client0=$!
${SURVEY_EXE}  client ipc:///tmp/survey.ipc client1 & client1=$!
${SURVEY_EXE}  client ipc:///tmp/survey.ipc client2 & client2=$!
sleep 3 
kill $server $client0 $client1 $client2