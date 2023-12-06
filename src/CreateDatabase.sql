-- Active: 1686291172146@@127.0.0.1@5435@postgres

SELECT
    pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE
    pg_stat_activity.datname = 'school21'
    AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS school21;

CREATE DATABASE school21;