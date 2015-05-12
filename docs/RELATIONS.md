Relations
=========

```bash
# make sure the tmp directory is empty
rake clear:tmp

# generate templates (this will query the services layer for `csid` values)
# and save the results in the `tmp` directory
rake cs:relate:records[templates/relationships/relations.example.csv]

# import the relationships
rake cs:post:directory[/relations,tmp,0.05]
```

---