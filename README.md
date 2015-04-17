CSIBLE
======

Use Ansible to interact with the CollectionSpace backend REST API. Using Ansible in this way is crude for detailed, branching operations, but can be effective for straightforward batch jobs (such as delete and import).

For more advanced use cases see [csapi](https://github.com/mark-cooper/csapi) and [cscli](https://github.com/mark-cooper/cscli).

Configuration file
------------------

```bash
cp api.json.example api.json
```

Edit `api.json` as needed.

Variables
---------

Recognized variables include:

```
# CONNECTION
url: absolute url for request (if defined overrides "base/services/path?params" url)
base: collectionspace base url
services: services path
path: path to backend service
params: optional params for request i.e. wf_deleted=false, pgSz=100
method: http method

# AUTH
user: username
password: password

# I/O
file: file with content for POST requests i.e. collectionobject.xml
directory: directory of xml files with content for POST requests i.e. media/
savefile: output file to capture response i.e. response.xml

# ANSIBLE URI MODULE HEADERS
HEADER_Content-Type: "application/xml"
```

Quickstart
----------

Requires `rake` (Ruby), or continue on to "Examples" to see ansible used directly.

```
gem install rake
gem install json

rake cs:config # dump api.json to terminal

# GET
rake cs:get:path[/media]
rake cs:get:path[/locationauthorities/38cc1b61-a597-4b12-b820/items,kw=EwoodPark702918]
rake cs:get:url[https://cspace.lyrasistechnology.org/cspace-services/locationauthorities]

# POST
rake cs:post:directory[/locationauthorities/38cc1b61-a597-4b12-b820/items,locations,1]
rake cs:post:file[/locationauthorities/XYZ/items,examples/locations/1.xml]

# DELETE
rake cs:delete:path[/locationauthorities/38cc1b61-a597-4b12-b820/items/a22a97ec-57fc-4b86-a366]
rake cs:delete:url[https://cspace.lyrasistechnology.org/cspace-services/locationauthorities/38cc1b61-a597-4b12-b820/items/a22a97ec-57fc-4b86-a366]
rake cs:delete:file[deletes.txt]
```

Examples
--------

In the examples `ap` is an alias for `ansible-playbook`.

**GET**

```bash
ap -i 'localhost,' services.yml --extra-vars="@api.json" # DEFAULT collectionobjects

# media records including those that are workflow deleted
ap -i 'localhost,' services.yml \
  --extra-vars="@api.json" \
  --extra-vars="path=media params=wf_deleted=true"

# need a search example with grep to pull uri
```

As demonstrated above `--extra-vars` can be used multiple times to specify file and command line arguments separately.

**Note:** `wf_deleted=false` (exclude deleted records) is a default parameter for GET requests.

**POST**

```bash
# import resource from file
ap -i 'localhost,' services.yml \
  --extra-vars="@api.json" \
  --extra-vars="method=POST file=examples/antioch.xml"

# import resources from a directory
ap -i 'localhost,' services.yml \
  --extra-vars="@api.json" \
  --extra-vars="method=POST directory=examples"
```

**Note:** for batch imports it may be preferable to loop over input files in a bash script (for example), passing each one as in the single file approach to have more control over the request rate.

**Note:** files in a directory must be of the same type (and suitable for `path`).

**PUT**

```bash
# update request with path and file of updated metadata
ap -i 'localhost,' services.yml \
  --extra-vars="@api.json" \
  --extra-vars="method=PUT path=collectionobjects/8079c5c8-258e-4e47-921b file=examples/antioch-updated.xml"

# update request with url and file of updated metadata
ap -i 'localhost,' services.yml \
  --extra-vars="@api.json" \
  --extra-vars="method=PUT url=https://cspace.lyrasistechnology.org/cspace-services/collectionobjects/8079c5c8-258e-4e47-921b file=examples/antioch-updated.xml"
```

**DELETE**

```bash
# delete resource at path
ap -i 'localhost,' services.yml \
  --extra-vars="@api.json" \
  --extra-vars="method=DELETE path=collectionobjects/dd887028-57a3-4ed8-b3c4"

# delete resource by specifying url
ap -i 'localhost,' services.yml \
  --extra-vars="@api.json" \
  --extra-vars="method=DELETE url=https://cspace.lyrasistechnology.org/cspace-services/collectionobjects/d87be7a7-2edc-45ce-b03e"

# delete resources using a file of resource urls
ap -i 'localhost,' services.yml \
  --extra-vars="@api.json" \
  --extra-vars="method=DELETE file=response.txt"
```

Task configuration files
------------------------

Configuration files can be used to wrap a "task", simplifying the command line arguments (or use `rake`).

```json
{
  "base": "https://cspace.lyrasistechnology.org",
  "path": "collectionobjects",
  "method": "POST",
  "user": "admin@cspace.lyrasistechnology.org",
  "password": "Administrator",
  "directory": "records/collectionobjects/",
  "savefile": "response.txt"
}
```

Save as `import_cobjects.json` then:

```bash
ap -i 'localhost,' services.yml --extra-vars="@import_cobjects.json"
```

Tidy XML output
---------------

CollectionSpace GET requests return XML. To improve readability:

```bash
sudo apt-get install libxml2-utils
xmllint --format response.xml
```

---
