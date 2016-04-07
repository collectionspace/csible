MYMUSEUM
========

For the `cache` process and `relations` endpoint `redis` is required:

```bash
docker pull redis
docker run -p 6379:6379 --name redis -d redis
redis-cli # 127.0.0.1:6379>
```

Create a `mymuseum` folder with a `.gitignore` file containing "*". Put site related csv files in that folder with sub-folders per service endpoint:

```bash
##### PROCESS TEMPLATES

# SEE mymuseum.sh
rake template:concepts:process[mymuseum/mymuseum-concept.csv,mymuseum/concepts]
rake template:locations:process[mymuseum/mymuseum-onsite.csv,mymuseum/onsite]
rake template:locations:process[mymuseum/mymuseum-offsite.csv,mymuseum/offsite]
rake template:organizations:process[mymuseum/mymuseum-org.csv,mymuseum/orgs]
rake template:persons:process[mymuseum/mymuseum-person.csv,mymuseum/persons]
rake template:cataloging:process[mymuseum/mymuseum-cat.csv,mymuseum/cat]
rake template:acquisitions:process[mymuseum/mymuseum-acq.csv,mymuseum/acq]
rake template:conditioncheck:process[mymuseum/mymuseum-cond.csv,mymuseum/cc]
rake template:groups:process[mymuseum/mymuseum-grp.csv,mymuseum/grp]
rake template:loansout:process[mymuseum/mymuseum-loans.csv,mymuseum/loans]
rake template:media:process[mymuseum/mymuseum-media.csv,mymuseum/media]
rake template:valuationcontrol:process[mymuseum/mymuseum-val.csv,mymuseum/vc]

##### IMPORT AND RELATE AUTHORITIES

rake cs:get:list[conceptauthorities]
rake cs:post:directory[REPLACE/items,mymuseum/concepts] # concept

rake cs:get:list[locationauthorities]

rake cs:post:directory[REPLACE/items,mymuseum/onsite] # location
rake cs:relate:authorities[REPLACE/items,locations,mymuseum/mymuseum-onsite.csv]

rake cs:post:directory[REPLACE/items,mymuseum/offsite] # offsite_sla
rake cs:relate:authorities[REPLACE/items,locations,mymuseum/mymuseum-offsite.csv]

rake cs:get:list[orgauthorities]
rake cs:post:directory[REPLACE/items,mymuseum/orgs] # organization

rake cs:get:list[personauthorities]
rake cs:post:directory[REPLACE/items,mymuseum/persons] # person

rake clear:all

##### IMPORT RECORDS

rake cs:post:directory[collectionobjects,mymuseum/cat]
rake cs:post:directory[acquisitions,mymuseum/acq]
rake cs:post:directory[conditionchecks,mymuseum/cc]
rake cs:post:directory[groups,mymuseum/grp]
rake cs:post:directory[loansout,mymuseum/loans]
rake cs:post:directory[media,mymuseum/media]
rake cs:post:directory[valuationcontrols,mymuseum/vc]

##### GET RECORD CSIDS

rake cs:get:list[collectionobjects,objectNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/collectionobjects.csv]
rake cs:get:list[acquisitions,acquisitionReferenceNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/acquisitions.csv]
rake cs:get:list[conditionchecks,conditionCheckRefNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/conditionchecks.csv]
rake cs:get:list[groups,title~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/groups.csv]
rake cs:get:list[loansout,loanOutNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/loansout.csv]
rake cs:get:list[media,identificationNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/media.csv]
rake cs:get:list[valuationcontrols,valuationcontrolRefNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/valuationcontrols.csv]

##### POPULATE CACHE (redis required)

# SEE mycache.sh
rake cs:cache[mymuseum/csv/collectionobjects.csv]
rake cs:cache[mymuseum/csv/acquisitions.csv]
rake cs:cache[mymuseum/csv/conditionchecks.csv]
rake cs:cache[mymuseum/csv/groups.csv]
rake cs:cache[mymuseum/csv/loansout.csv]
rake cs:cache[mymuseum/csv/media.csv]
rake cs:cache[mymuseum/csv/valuationcontrols.csv]

##### PROCESS RELATIONS (redis required)

rake cs:relate:records[mymuseum/mymuseum-acq.csv]
rake cs:relate:records[mymuseum/mymuseum-cond.csv]
rake cs:relate:records[mymuseum/mymuseum-media.csv]
rake cs:relate:records[mymuseum/mymuseum-val.csv]

rake cs:relate:records[mymuseum/mymuseum-loans-items.csv]
rake cs:relate:records[mymuseum/mymuseum-grp-master.csv]
rake cs:relate:records[mymuseum/mymuseum-grp-export.csv]
rake cs:relate:records[mymuseum/mymuseum-grp-publish.csv]

rake cs:post:directory[relations,tmp,0.01]
```

Cleanup:

```
rake cs:get:path["/relations","sbjType=CollectionObject&objType=CollectionObject"]
rake cs:parse_xml["relation-list-item > uri"]
rake cs:delete:file[response.txt,path]
```

---

Wrapper script `mymuseum.sh`:

```bash
#!/bin/bash

rake template:concepts:process[mymuseum/mymuseum-concept.csv,mymuseum/concepts]
rake template:locations:process[mymuseum/mymuseum-onsite.csv,mymuseum/onsite]
rake template:locations:process[mymuseum/mymuseum-offsite.csv,mymuseum/offsite]
rake template:organizations:process[mymuseum/mymuseum-org.csv,mymuseum/orgs]
rake template:persons:process[mymuseum/mymuseum-person.csv,mymuseum/persons]
rake template:cataloging:process[mymuseum/mymuseum-cat.csv,mymuseum/cat]
rake template:acquisitions:process[mymuseum/mymuseum-acq.csv,mymuseum/acq]
rake template:conditioncheck:process[mymuseum/mymuseum-cond.csv,mymuseum/cc]
rake template:groups:process[mymuseum/mymuseum-grp.csv,mymuseum/grp]
rake template:loansout:process[mymuseum/mymuseum-loans.csv,mymuseum/loans]
rake template:media:process[mymuseum/mymuseum-media.csv,mymuseum/media]
rake template:valuationcontrol:process[mymuseum/mymuseum-val.csv,mymuseum/vc]
```

Wrapper script `mycache.sh`:

```bash
#!/bin/bash

echo "Starting redis"
docker run -p 6379:6379 --name redis -d redis
sleep 10

echo "Getting csids"
rake cs:get:list[collectionobjects,objectNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/collectionobjects.csv]
rake cs:get:list[acquisitions,acquisitionReferenceNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/acquisitions.csv]
rake cs:get:list[conditionchecks,conditionCheckRefNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/conditionchecks.csv]
rake cs:get:list[groups,title~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/groups.csv]
rake cs:get:list[loansout,loanOutNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/loansout.csv]
rake cs:get:list[media,identificationNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/media.csv]
rake cs:get:list[valuationcontrols,valuationcontrolRefNumber~csid,"wf_deleted=false&pgSz=1000",mymuseum/csv/valuationcontrols.csv]

echo "Building cache"
rake cs:cache[mymuseum/csv/collectionobjects.csv]
rake cs:cache[mymuseum/csv/acquisitions.csv]
rake cs:cache[mymuseum/csv/conditionchecks.csv]
rake cs:cache[mymuseum/csv/groups.csv]
rake cs:cache[mymuseum/csv/loansout.csv]
rake cs:cache[mymuseum/csv/media.csv]
rake cs:cache[mymuseum/csv/valuationcontrols.csv]

echo "Creating templates"
rake cs:relate:records[mymuseum/mymuseum-acq.csv]
rake cs:relate:records[mymuseum/mymuseum-cond.csv]
rake cs:relate:records[mymuseum/mymuseum-media.csv]
rake cs:relate:records[mymuseum/mymuseum-val.csv]
rake cs:relate:records[mymuseum/mymuseum-loans-items.csv]
rake cs:relate:records[mymuseum/mymuseum-grp-master.csv]
rake cs:relate:records[mymuseum/mymuseum-grp-export.csv]
rake cs:relate:records[mymuseum/mymuseum-grp-publish.csv]
```

---
