#!/bin/bash
docker compose down -v
docker compose build
docker compose up -d

echo "Waiting for PostgreSQL to be ready..."
until docker exec postgres pg_isready -U postgres > /dev/null 2>&1; do sleep 1; done

echo "Waiting for ClickHouse to be ready..."
until docker exec clickhouse clickhouse-client -q 'SELECT 1' > /dev/null 2>&1; do sleep 1; done

echo "Initializing PostgreSQL..."
docker exec -i postgres psql -U postgres postgres <<'EOSQL'
DROP TABLE IF EXISTS test;
CREATE TABLE test (id SERIAL PRIMARY KEY, name VARCHAR(100), description VARCHAR(255));
ALTER TABLE test REPLICA IDENTITY FULL;
DO $$
BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO test (name, description) VALUES ('name ' || i, 'desc ' || i);
    END LOOP;
END;
$$;
EOSQL

echo "Creating ClickHouse target table..."
docker exec clickhouse clickhouse-client -q "CREATE TABLE IF NOT EXISTS default.postgres_test (id Int32, name String, description String) ENGINE = MergeTree() ORDER BY id"
