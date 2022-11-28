#!/bin/bash

function getNextPort() {
        INIT_PORT="${1}"
        LIMIT_PORT="${2}"
        FINAL_PORT=$(( $INIT_PORT + $LIMIT_PORT ))
        for PORT in $(seq ${INIT_PORT} ${FINAL_PORT})
        do
                NETSTAT=$(netstat -utna | grep ${PORT})
                if [[ $NETSTAT == "" ]]; then
                        AVAILABLE_PORT=$PORT
                        break
                fi
        done
}

# Send error output and exit with status code 1
function errout {
  echo "ERROR: $*, exiting..." >&2
  echo "========================================================="
  docker-compose down
  sed -i "s/$HOSTNAME/HOST_NAME/g" docker-compose.yml
  rm -rf /etc/nginx/upstream/hapifhir.conf
  exit 1
}

HOSTNAME="localhost"
HOSTNAME_ENV=$(grep HOSTNAME .env | awk -F '=' '{printf $2}')

CONTAINERS=$(docker ps | grep "_${HOSTNAME}")
CONTAINERS_ENV=$(docker ps | grep "_${HOSTNAME_ENV}")

if [[ $CONTAINERS != "" ]]; then
  echo "HapiFHIR containers are already running in localhost."
  exit 1
fi

if [[ $CONTAINERS_ENV != "" ]]; then
  echo "HapiFHIR containers are already running with current hostname in .env: ${HOSTNAME_ENV}"
  exit 1
fi

echo "Installing docker and docker-compose"
apt update 1>&2 && apt install docker docker-compose jq unzip sendmail -y

echo "Setting hostname: $HOSTNAME"
sed -i "s/$HOSTNAME_ENV/$HOSTNAME/g" .env ./docker-compose.yml

# Change exposed port to the next available one. Parameters: Initial Port and Limit Port
HAPIFHIR_EXPOSED_PORT=$(grep HAPIFHIR_EXPOSED_PORT .env | awk -F '=' '{printf $2}')
getNextPort "$HAPIFHIR_EXPOSED_PORT" "1000"
sed -i "s/HAPIFHIR_EXPOSED_PORT=$HAPIFHIR_EXPOSED_PORT/HAPIFHIR_EXPOSED_PORT=$AVAILABLE_PORT/g" .env
echo "HapiFHIR docker service will be exposed on port: $AVAILABLE_PORT"
HAPIFHIR_EXPOSED_PORT=$AVAILABLE_PORT

POSTGRES_EXPOSED_PORT=$(grep POSTGRES_EXPOSED_PORT .env | awk -F '=' '{printf $2}')
getNextPort "$POSTGRES_EXPOSED_PORT" "1000"
sed -i "s/POSTGRES_EXPOSED_PORT=$POSTGRES_EXPOSED_PORT/POSTGRES_EXPOSED_PORT=$AVAILABLE_PORT/g" .env
echo "Postgres docker service will be exposed on port: $AVAILABLE_PORT"
POSTGRES_EXPOSED_PORT=$AVAILABLE_PORT

echo "Building and creating docker containers"
if ! docker-compose up --build -d; then
  errout "Failed docker-compose" 1>&2
fi

echo "Successfully installed HapiFHIR. You can access HapiFHIR in http://localhost:${HAPIFHIR_EXPOSED_PORT}"
