#!/bin/bash
source ../../../../CLI/env/.env
source ../../env/.env.replication

if grep -w "$1" ../tables; then
  echo '> Subscription already exist'
else
  echo "CREATE SUBSCRIPTION $1_sub CONNECTION 'dbname=${PARENT_REPLICATION_DB} host=master_node user=${PARENT_REPLICATION_USER} password=${PARENT_REPLICATION_PASSWORD}' PUBLICATION $1_pub" > ../../init/sub_$1.sql

  echo "> SQL: sub_$1 -> created"
  if [ "$(docker container inspect $DOCKER_CONTAINER -f '{{.State.Running}}')" == "true" ]; then
    docker exec -it "${DOCKER_CONTAINER}" psql -U $POSTGRES_USER -c "CREATE SUBSCRIPTION $1_sub CONNECTION 'dbname=${PARENT_REPLICATION_DB} host=master_node user=${PARENT_REPLICATION_USER} password=${PARENT_REPLICATION_PASSWORD}' PUBLICATION $1_pub";
  else
    echo "> Docker: $DOCKER_CONTAINER is offline skipping"
  fi

  echo $1 >> ../tables
  echo "> $1 added to tables subscribed"
fi