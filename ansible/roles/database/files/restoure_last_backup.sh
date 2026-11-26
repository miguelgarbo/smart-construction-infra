#!/bin/bash

set -Eeuo pipefail

# Baixa o ultimo backup do banco no S3 e restaura em um Postgres TEMPORARIO.
# Nao toca no container de producao e nao publica nenhuma porta.

S3_BUCKET="s3://smart-construction-backup/database"

DB_CONTAINER="smart-construction-db-1" # so para copiar a imagem do Postgres
DB_NAME="smart_construction"
DB_USER="smart_migrator"

# para rodar em outra maquina: DB_IMAGE=postgres:16 ./test_restore.sh
DB_IMAGE="${DB_IMAGE:-$(docker inspect -f '{{.Config.Image}}' "$DB_CONTAINER")}"

TEST_DB="restore-test-db"
WORK_DIR=$(mktemp -d /tmp/restore_test.XXXXXX)

cleanup() {
  docker rm -f "$TEST_DB" > /dev/null 2>&1 || true
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

echo "Starting Restore Test Smart Construction database"

DUMP=$(aws s3 ls "$S3_BUCKET/" | awk '{print $4}' | sort | tail -n1 || true)
[ -n "$DUMP" ] || { echo "No database backup found in S3" >&2; exit 1; }

echo "Downloading $DUMP"
aws s3 cp "$S3_BUCKET/$DUMP" "$WORK_DIR/$DUMP"

echo "Starting temporary Postgres ($DB_IMAGE)"
docker run -d --name "$TEST_DB" \
  -e POSTGRES_USER="$DB_USER" \
  -e POSTGRES_PASSWORD=restore_test \
  -e POSTGRES_DB="$DB_NAME" \
  "$DB_IMAGE" > /dev/null

# espera o init terminar (o Postgres reinicia uma vez durante o init)
for _ in $(seq 1 60); do
  if [[ "$(docker logs "$TEST_DB" 2>&1)" == *"init process complete"* ]] \
    && docker exec "$TEST_DB" pg_isready -U "$DB_USER" -d "$DB_NAME" > /dev/null 2>&1; then
    break
  fi
  sleep 1
done

docker cp "$WORK_DIR/$DUMP" "$TEST_DB:/tmp/restore.dump"

FAILED=0
if docker exec "$TEST_DB" pg_restore -U "$DB_USER" -d "$DB_NAME" \
  --no-owner --no-privileges /tmp/restore.dump; then
  echo "pg_restore finished without errors"
else
  echo "WARNING: pg_restore reported errors, review the output above" >&2
  FAILED=1
fi

echo "Row count per table (top 15):"
docker exec -i "$TEST_DB" psql -U "$DB_USER" -d "$DB_NAME" <<'SQL'
SELECT table_name,
       (xpath('/row/c/text()',
              query_to_xml(format('select count(*) as c from %I.%I', table_schema, table_name),
                           false, true, '')))[1]::text::int AS rows
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY rows DESC
LIMIT 15;
SQL

echo "Restore test finished"

[ "$FAILED" -eq 0 ] || exit 1