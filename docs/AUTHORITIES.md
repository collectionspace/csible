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
rake cs:relate:authorities[/locationauthorities/38cc1b61-a597-4b12-b820/items,locations,templates/locations/onsite.csv]

rake clear:all

# repeat as needed
rake template:locations:items:process[templates/locations/offsite.csv]
rake cs:post:directory[/locationauthorities/add50144-321a-4355-840b/items,imports,1]
rake cs:relate:authorities[/locationauthorities/add50144-321a-4355-840b/items,locations,templates/locations/offsite.csv]

# to "undo"
rake cs:delete:file[response.txt]
```

**Names:**

Names are entered in direct format. This is the `display` name:

```
Tuto
Clementine Hunter
Robert M. Wilson
```

To parse names split on space characters:

- if 1 one result use `display` name only (no `first`, `middle`, `last` qualifications)
- if 2 results use `display`, `first` [0], `last` [1]
- if 3 results use `display`, `first` [0], `middle` [1], `last` [2] except:
  - if [1] is "([Dd]e|V[ao]n)" concatenate [1] and [2] as `last` (exclude `middle`)
  - the parsing rules should be reassessed with each migration

---