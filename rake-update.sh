# Update cataloging's Production Place field
rake template:places:items:process[imports/places/items.csv,imports/places/payloads]
rake cs:post:directory[placeauthorities/urn:cspace:name\(place\)/items,imports/places/payloads,1]
rake cs:relate:authorities[placeauthorities/urn:cspace:name\(place\)/items,places,imports/places/relationships.csv]
rake template:places:refnames:items:process[imports/places/refnames-items.csv,sql-batch]

# Update catalogins's Material field
rake template:concepts:items:process[imports/concepts/items.csv,imports/concepts/payloads]
rake cs:post:directory[conceptauthorities/urn:cspace:name\(material_ca\)/items,imports/concepts/payloads,1]
rake cs:relate:authorities[conceptauthorities/urn:cspace:name\(material_ca\)/items,concepts,imports/concepts/relationships.csv]
rake template:concepts:refnames:items:process[imports/concepts/refnames-items.csv,sql-batch]
