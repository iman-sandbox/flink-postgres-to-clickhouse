-- Postgres CDC source
CREATE TABLE postgres_test (
  id           INT,
  name         STRING,
  description  STRING
) WITH (
  'connector'      = 'postgres-cdc',
  'hostname'       = 'postgres',
  'port'           = '5432',
  'username'       = 'postgres',
  'password'       = 'postgres',
  'database-name'  = 'postgres',
  'schema-name'    = 'public',
  'table-name'     = 'test',
  'slot.name'      = 'flink'
);

-- ClickHouse sink (use the dedicated connector, not generic JDBC)
CREATE TABLE clickhouse_sink (
  id INT,
  name STRING,
  description STRING,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'clickhouse',
  'url' = 'jdbc:clickhouse://clickhouse:9009',
  'database-name' = 'default',
  'table-name' = 'postgres_test',
  'username' = 'default',
  'password' = '',
  'sink.batch-size' = '1000',
  'sink.flush-interval' = '1s',
  'sink.max-retries' = '3',
  'sink.ignore-delete' = 'true',
  'sink.update-strategy' = 'insert'
);



INSERT INTO clickhouse_sink
SELECT id, name, description FROM postgres_test;

