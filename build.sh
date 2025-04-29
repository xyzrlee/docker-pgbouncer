#!/usr/bin/env bash

echo "PGBOUNCER_VERSION=${PGBOUNCER_VERSION}"

docker buildx build --progress plain --debug --build-arg PGBOUNCER_VERSION="${PGBOUNCER_VERSION}" -t pgbouncer .

