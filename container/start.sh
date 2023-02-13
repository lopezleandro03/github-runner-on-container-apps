#!/bin/bash
GHUSER=$GHUSER
GHREPO=$GHREPO
GHPAT=$GHPAT
 
RUNNER_NAME="RUNNER-$(hostname)"
 
echo "Starting runner ${RUNNER_NAME}"

GHTOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GHPAT}" https://api.github.com/repos/${GHUSER}/${GHREPO}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner
./config.sh --unattended  \
   --url https://github.com/${GHUSER}/${GHREPO} \
   --token ${GHTOKEN} \
   --name ${RUNNER_NAME} \
   --ephemeral --disableupdate
 
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${GHTOKEN}
}
 
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
 
./run.sh & wait $!