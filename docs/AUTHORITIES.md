Authorities
===========

Creating authority (item) records and setting relationships:

```bash
# get csids for location authorities
rake cs:get:list[/locationauthorities,uri~shortIdentifier]

# create import xml
rake template:locations:items:process[templates/locations/onsite.csv]
# import it using csid from csv
rake cs:post:directory[/locationauthorities/38cc1b61-a597-4b12-b820/items,imports,1]
# set relationships -- uses "from", "to" values from the same or a different file
rake cs:relationships[/locationauthorities/38cc1b61-a597-4b12-b820/items,locations,templates/locations/onsite.csv]

rake clear:all

# repeat as needed
rake template:locations:items:process[templates/locations/offsite.csv]
rake cs:post:directory[/locationauthorities/add50144-321a-4355-840b/items,imports,1]
rake cs:relationships[/locationauthorities/add50144-321a-4355-840b/items,locations,templates/locations/offsite.csv]

# to "undo"
rake cs:delete:file[response.txt]
```

---