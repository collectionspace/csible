# CSIBLE

[![Build Status](https://travis-ci.org/collectionspace/csible.svg?branch=master)](https://travis-ci.org/collectionspace/csible)

**This project is deprecated. See the [Converter Tool](https://github.com/collectionspace/cspace-converter) for import / migration support.**

A set of Rake tasks to interact with the CollectionSpace backend REST API and generate CollectionSpace XML records.

Configuration file
------------------

```bash
cp api.json.example api.json
```

Edit `api.json` as needed. See [collectionspace-client](https://github.com/lyrasis/collectionspace-client.git) for more detail on the `services` configuration.

The `templates` section is for record generation. The `urn` value should be set to the domain configured for the CollectionSpace instance, which may or may not be the domain used in the `url`. The `templates_path` setting should set the path to the templates configuration (by default "templates"). Custom templates can be downloaded to "custom_templates" (which is git ignored by default) or elsewhere according to preference. Custom templates must follow the same directory structure as "templates" but can supply user defined configuration csv and erb templates.

Installation
------------

Clone this repository.
```
git clone https://github.com/collectionspace/csible.git
cd csible
cp api.json.example api.json
```

**Ruby**

Ruby version 1.9.3+ is required to run csible commands.  Using `chruby` or `rbenv` to manage your Ruby environment is recommended.

If you're not a Ruby developer and are planning to just run and use csible, you can install the required version of Ruby onto Ubuntu 14.04+ with these commands based on a PAA by brightbox.com -see https://www.brightbox.com/docs/ruby/ubuntu/

```
sudo apt-get install software-properties-common
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get update
sudo apt-get install ruby-switch
sudo apt-get install ruby2.2
sudo apt-get install ruby2.2-dev
ruby-switch --list
sudo ruby-switch --set ruby2.2
```

Finally use these commands to add the final csible pre-reqs:

```
sudo apt-get install make libxslt-dev libxml2-dev ruby-dev zlib1g-dev
sudo gem install bundler nokogiri rake
bundle install
```

Quickstart
----------

**Tasks**

```bash
rake -T # list all tasks
rake cs:config # dump api.json to terminal
```

**Templates**

```bash
# convert CollectionSpace csv to XML
rake template:cs:acquisitions:process[path/to/acquisitions.csv]
```

**API**

```bash
# GET
rake cs:get:path[media]
rake cs:get:path[locationauthorities/38cc1b61-a597-4b12-b820/items,kw=EwoodPark702918,xml] # xml output

# GET items list
rake cs:get:list[media]

# POST
rake cs:post:directory[locationauthorities/38cc1b61-a597-4b12-b820/items,locations,1]
rake cs:post:directory["vocabularies/urn:cspace:name(contentobjecttype)/items",imports]
rake cs:post:file[locationauthorities/XYZ/items,examples/locations/1.xml]
rake cs:post:sync["materialauthorities/urn:cspace:name(material_shared)","impTimout=3600&forceSync=true"]

# DELETE
rake cs:delete:path[locationauthorities/38cc1b61-a597-4b12-b820/items/a22a97ec-57fc-4b86-a366]
rake cs:delete:file[deletes.txt] # assumes file of urls
rake cs:delete:file[deletes.txt,path] # file of paths
```

Depending on the actions it may be necessary to clear the `imports` and / or `tmp` folders:

```bash
rake cs:clear:imports
rake cs:clear:tmp
```

These tasks ensure that only XML files are removed.

**Parsing responses**

Pass element as CSS selector:

```bash
rake cs:parse_xml["relation-list-item > uri"]
```

By default `response.xml` is the input and `response.txt` is the output.

License
---

The project is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

---
