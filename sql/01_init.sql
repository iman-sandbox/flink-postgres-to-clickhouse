CREATE TABLE postgres_test_source (
  id INT,
  name STRING,
  description STRING
) WITH (
  'connector' = 'postgres-cdc',
  'hostname' = 'postgres',
  'port' = '5432',
  'username' = 'postgres',
  'password' = 'postgres',
  'database-name' = 'postgres',
  'schema-name' = 'public',
  'table-name' = 'test',
  'slot.name' = 'flink'
);

CREATE TABLE clickhouse_sink (
  id INT,
  name STRING,
  description STRING
) WITH (
  'connector' = 'jdbc',
  'url' = 'jdbc:clickhouse://clickhouse:8123/default',
  'table-name' = 'postgres_test',
  'driver' = 'ru.yandex.clickhouse.ClickHouseDriver',
  'username' = 'default',
  'password' = ''
);

INSERT INTO clickhouse_sink
SELECT * FROM postgres_test_source;
