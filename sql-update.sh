# Updates for the contentConcepts cataloging field
psql -U csadmin -d watermill_watermill -f csible/sql-batch/update-general-subject-terms-refnames.sql

# Updates for the productionPlace cataloging field
psql -U csadmin -d watermill_watermill -f csible/sql-batch/places-refnames.sql

# Updates for the material cataloging field
psql -U csadmin -d watermill_watermill -f csible/sql-batch/concepts-refnames.sql
