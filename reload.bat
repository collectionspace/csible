dropdb -U csadmin watermill_watermill
createuser -U csadmin piction_watermill
createdb -U csadmin -O nuxeo_watermill -T template1 watermill_watermill
pg_restore -U csadmin -d watermill_watermill watermill_watermill.dump
psql -U csadmin -d watermill_watermill -f grants.sql