Authorities
===========

Creating authority (item) records and setting relationships:

**Concepts**

```bash
# get csids for concept authorities
rake cs:get:list[conceptauthorities]
# create import xml
rake template:cs:concepts:process[templates/concepts/watermill.csv]
# import it using csid from csv: `concept` authority
rake cs:post:directory[conceptauthorities/02ad348f-828f-4834-a830/items,imports]

rake clear:all

# to "undo"
rake cs:delete:file[response.txt]
```

**Locations**

```bash
# get csids for location authorities
rake cs:get:list[locationauthorities]

# create import xml
rake template:cs:locations:process[templates/locations/onsite.csv]
# import it using csid from csv: `location` authority
rake cs:post:directory[locationauthorities/38cc1b61-a597-4b12-b820/items,imports]
# set relationships -- uses "from", "to" values from the same or a different file
rake cs:relate:authorities[locationauthorities/38cc1b61-a597-4b12-b820/items,locations,templates/locations/onsite.csv]

rake clear:all

# repeat as needed
rake template:cs:locations:process[templates/locations/offsite.csv]
rake cs:post:directory[locationauthorities/add50144-321a-4355-840b/items,imports] # `offsite_sla` authority
rake cs:relate:authorities[locationauthorities/add50144-321a-4355-840b/items,locations,templates/locations/offsite.csv]

rake clear:all

# to "undo"
rake cs:delete:file[response.txt]
```

**Organizations:**

```
# get csids for org authorities
rake cs:get:list[orgauthorities]
# create import xml
rake template:cs:organizations:process[templates/organizations/watermill.csv]
# import it using csid from csv: `organization` authority
rake cs:post:directory[orgauthorities/f1dd741c-0c98-4033-9a1c/items,imports]
```

**Persons:**

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

```bash
# get csids for person authorities
rake cs:get:list[personauthorities]
# create import xml
rake template:cs:persons:process[templates/persons/watermill.csv]
# import it using csid from csv: `person` authority
rake cs:post:directory[personauthorities/92c6d196-d88e-4e0e-8dbb/items,imports]

rake clear:all

# to "undo"
rake cs:delete:file[response.txt]
```

---
