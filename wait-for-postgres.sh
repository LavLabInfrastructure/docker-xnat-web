#!/bin/sh
# wait-for-postgres.sh

set -e

cmd="$@"

until PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" -h db -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 5
done

>&2 echo "Postgres is up - executing command \"$cmd\""
exec $cmd