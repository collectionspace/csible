# Updates for the contentConcepts cataloging field
psql -U csadmin -d watermill_watermill -f csible/sql-batch/update-concept-refnames.sql

# Updates for the productionPlace cataloging field
psql -U csadmin -d watermill_watermill -f imports/places/sql/places-refnames.sql

# Updates for the material cataloging field
psql -U csadmin -d watermill_watermill -f imports/concepts/sql/concepts-refnames.sql
