#!/bin/sh
set -e

# Start original postgres with passed arguments
echo "Starting Postgres with args: $@"
/usr/local/bin/docker-entrypoint.sh "$@" &

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until pg_isready -h localhost -p 5432 -U "$POSTGRES_USER"; do
  sleep 1
done

# Import dataset only if not already imported
if [ ! -f /var/lib/postgresql/data/.import_done ]; then
  echo "Running dataset import script..."
  /docker-entrypoint-initdb.d/dataset/import_postgresql.sh localhost 5432 "$POSTGRES_USER" "$POSTGRES_DB"
  touch /var/lib/postgresql/data/.import_done
else
  echo "Dataset already imported, skipping."
fi

wait
