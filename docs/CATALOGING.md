Cataloging
==========

**Search**

Cataloging record by id (not deleted):

```bash
# double quotes required to prevent bash background process
rake cs:get:path["collectionobjects,as=collectionobjects_common:objectNumber%3D%22123456%22&wf_deleted=false"]
```

This will return a single list item if found at `["list-item"][0]["csid"]`.

**Import**

```bash
# create import xml
rake template:cs:cataloging:process[templates/cataloging/watermill.csv]
# import it
rake cs:post:directory[collectionobjects,imports]

rake clear:all
```

---
