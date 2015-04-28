Cataloging
==========

```bash
# create import xml
rake template:cataloging:objects:process[templates/cataloging/watermill.csv]
# import it
rake cs:post:directory[/collectionobjects,imports,1]

rake clear:all
```

---