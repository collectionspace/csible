# Relations

To create relationship records between two object / procedure records:

```bash
# make sure the tmp directory is empty
bundle exec rake clear:tmp

# pre-populate redis (optional but faster!)
docker run -p 6379:6379 --name redis -d redis
# get id, csid pairs for each record type to be related
bundle exec rake cs:get:list[collectionobjects]
mv response.csv collectionobjects.csv
bundle exec rake cs:get:list[media]
mv response.csv media.csv

bundle exec rake cs:cache[collectionobjects.csv,objectNumber,csid]
bundle exec rake cs:cache[media.csv,identificationNumber,csid]

# generate relationship records and save the results in the `tmp` directory
bundle exec rake cs:relate:records[templates/relationships/$relations.csv]

# import the relationships
bundle exec rake cs:post:directory[relations,tmp]
```

**Finding relationships**

```bash
rake cs:get:path["relations","sbjType=CollectionObject&objType=CollectionObject"]
```

---
