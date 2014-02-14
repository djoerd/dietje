CREATE DATABASE dietje;
--  for MySQL
CREATE USER dietje;
GRANT ALL PRIVILEGES ON dietje.* TO dietje@localhost IDENTIFIED BY 'changeit';
--  for PostgreSQL
-- CREATE USER dietje WITH PASSWORD 'changeit';
-- GRANT ALL PRIVILEGES ON DATABASE dietje TO dietje;



