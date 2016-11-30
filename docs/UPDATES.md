# Updating records example

Clear any import files:

```
rake clear:all
```

Retrieve csv of existing records to `response.csv`.

```
rake cs:get:list[acquisitions,"wf_deleted=false"]
```

Edit `response.csv` to contain fields required per [update.config.csv](../templates/collectionspace/updates/update.config.csv). You will need to add `type` (the record type in plural form i.e. acquisitions), `element` (a field to update) and `value` (the new data) fields.

Generate the stub upload payloads:

```
rake template:cs:update:process[response.csv]
```

Test an update:

```
cp imports/$CSID.xml tmp/$CSID.xml
rake cs:put:file[acquisitions/$CSID,tmp/$CSID.xml]
```

Check the `response.log` and confirm the update was applied in CollectionSpace.

Perform the update requests:

```
rake cs:put:directory[acquisitions,imports]
```

The first parameter is the path. As updates apply to individual records the csid is found from the filenames in the directory folder (in this case `imports`). So the actual path resolves to something like: `acquisitions/$CSID` where `$CSID` is determined from the filename (which we get via the default behavior for files generated using `
rake template:cs:update:process`).

---