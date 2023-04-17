FROM postgis/postgis

COPY schema.sql /docker-entrypoint-initdb.d/
