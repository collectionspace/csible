-- The list of term refnames to update came from the follow SQL statment
--     select refname from concepts_common where inauthority = 'f9189dfa-3e9b-402a-a82b';
-- This SQL statement provided a list of the refnames for all the terms that were
-- part of the "Associate Concept" authority.  The "Associated Concept" authority's
-- short ID is "concept".  The set of SQL update statements below essentially reassign
-- the terms to be part of the "Classification" concept authority with short ID "classification".
--
-- Update the URN's short ID part to use the new classification short ID with this SQL
-- SQL pseudo statement:update concepts_common set refname = 'newRefName' where refname = 'oldRefName'
--
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(ArchitecturalelementsQXJjaGl0ZWN0dXJhbGVsZW1lbnRz)''Architectural elements''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(ArchitecturalelementsQXJjaGl0ZWN0dXJhbGVsZW1lbnRz)''Architectural elements''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(JewelrySmV3ZWxyeQ)''Jewelry''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(JewelrySmV3ZWxyeQ)''Jewelry''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(WoodproductsV29vZHByb2R1Y3Rz)''Wood products''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(WoodproductsV29vZHByb2R1Y3Rz)''Wood products''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(FurnitureRnVybml0dXJl)''Furniture''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(FurnitureRnVybml0dXJl)''Furniture''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(MegalithsTWVnYWxpdGhz)''Megaliths''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(MegalithsTWVnYWxpdGhz)''Megaliths''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(CostumeQ29zdHVtZQ)''Costume''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(CostumeQ29zdHVtZQ)''Costume''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(PlantmaterialUGxhbnRtYXRlcmlhbA)''Plant material''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(PlantmaterialUGxhbnRtYXRlcmlhbA)''Plant material''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(VisualworksVmlzdWFsd29ya3M)''Visual works''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(VisualworksVmlzdWFsd29ya3M)''Visual works''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(PrintsUHJpbnRz)''Prints''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(PrintsUHJpbnRz)''Prints''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(BuiltenvironmentQnVpbHRlbnZpcm9ubWVudA)''Built environment''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(BuiltenvironmentQnVpbHRlbnZpcm9ubWVudA)''Built environment''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(ArmorQXJtb3I)''Armor''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(ArmorQXJtb3I)''Armor''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(MoneyTW9uZXk)''Money''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(MoneyTW9uZXk)''Money''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(DrawingsRHJhd2luZ3M)''Drawings''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(DrawingsRHJhd2luZ3M)''Drawings''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(DocumentRG9jdW1lbnQ)''Document''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(DocumentRG9jdW1lbnQ)''Document''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(ToysVG95cw)''Toys''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(ToysVG95cw)''Toys''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(WeaponsV2VhcG9ucw)''Weapons''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(WeaponsV2VhcG9ucw)''Weapons''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(ToolsandequipmentVG9vbHNhbmRlcXVpcG1lbnQ)''Tools and equipment''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(ToolsandequipmentVG9vbHNhbmRlcXVpcG1lbnQ)''Tools and equipment''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(BagsQmFncw)''Bags''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(BagsQmFncw)''Bags''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(VesselsVmVzc2Vscw)''Vessels''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(VesselsVmVzc2Vscw)''Vessels''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(DocumentsRG9jdW1lbnRz)''Documents''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(DocumentsRG9jdW1lbnRz)''Documents''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(PaintingsUGFpbnRpbmdz)''Paintings''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(PaintingsUGFpbnRpbmdz)''Paintings''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(CollagesQ29sbGFnZXM)''Collages''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(CollagesQ29sbGFnZXM)''Collages''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(ContainersQ29udGFpbmVycw)''Containers''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(ContainersQ29udGFpbmVycw)''Containers''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(FurnishingsRnVybmlzaGluZ3M)''Furnishings''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(FurnishingsRnVybmlzaGluZ3M)''Furnishings''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(SculptureU2N1bHB0dXJl)''Sculpture''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(SculptureU2N1bHB0dXJl)''Sculpture''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(ScoresU2NvcmVz)''Scores''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(ScoresU2NvcmVz)''Scores''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(BooksQm9va3M)''Books''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(BooksQm9va3M)''Books''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(MusicalinstrumentsTXVzaWNhbGluc3RydW1lbnRz)''Musical instruments''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(MusicalinstrumentsTXVzaWNhbGluc3RydW1lbnRz)''Musical instruments''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(TextilesVGV4dGlsZXM)''Textiles''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(TextilesVGV4dGlsZXM)''Textiles''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(PhotographsUGhvdG9ncmFwaHM)''Photographs''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(PhotographsUGhvdG9ncmFwaHM)''Photographs''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(Foundobject1435614131420)''Found object''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(Foundobject1435614131420)''Found object''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(Vessel1445286258494)''Vessel''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(Vessel1445286258494)''Vessel''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(Container1445286269729)''Container''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(Container1445286269729)''Container''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(Basket1445286277036)''Basket''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(Basket1445286277036)''Basket''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(Pot1445286289632)''Pot''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(Pot1445286289632)''Pot''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(Pitcher1445286298123)''Pitcher''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(Pitcher1445286298123)''Pitcher''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(Vase1445286305912)''Vase''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(Vase1445286305912)''Vase''';
update concepts_common set refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(Vessel1445287562466)''Vessel''' where refname = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(Vessel1445287562466)''Vessel''';

-- Now we need to update all the terms' parent to be the "classification" authority
-- The first CSID is that of the "Classification" concept authority.  The second is that of the old
-- concept (aka, Associate Concept) authority
update concepts_common set inauthority = '1564dda5-e0b8-4d0a-89c4' where inauthority = 'f9189dfa-3e9b-402a-a82b';

-- Next we need to update all the catalog records' "General Subject Terms" fields to use new classification refname
-- SQL pseudo statement, update collectionobjects_common_contentconcepts set item = '{newRefName}' where item = '{oldRefName}';
--
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(DrawingsRHJhd2luZ3M)''Drawings''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(DrawingsRHJhd2luZ3M)''Drawings''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(MusicalinstrumentsTXVzaWNhbGluc3RydW1lbnRz)''Musical instruments''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(MusicalinstrumentsTXVzaWNhbGluc3RydW1lbnRz)''Musical instruments''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(ToysVG95cw)''Toys''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(ToysVG95cw)''Toys''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(TextilesVGV4dGlsZXM)''Textiles''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(TextilesVGV4dGlsZXM)''Textiles''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(BooksQm9va3M)''Books''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(BooksQm9va3M)''Books''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(WeaponsV2VhcG9ucw)''Weapons''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(WeaponsV2VhcG9ucw)''Weapons''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(ArchitecturalelementsQXJjaGl0ZWN0dXJhbGVsZW1lbnRz)''Architectural elements''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(ArchitecturalelementsQXJjaGl0ZWN0dXJhbGVsZW1lbnRz)''Architectural elements''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(JewelrySmV3ZWxyeQ)''Jewelry''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(JewelrySmV3ZWxyeQ)''Jewelry''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(PaintingsUGFpbnRpbmdz)''Paintings''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(PaintingsUGFpbnRpbmdz)''Paintings''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(SculptureU2N1bHB0dXJl)''Sculpture''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(SculptureU2N1bHB0dXJl)''Sculpture''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(CostumeQ29zdHVtZQ)''Costume''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(CostumeQ29zdHVtZQ)''Costume''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(ScoresU2NvcmVz)''Scores''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(ScoresU2NvcmVz)''Scores''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(DocumentsRG9jdW1lbnRz)''Documents''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(DocumentsRG9jdW1lbnRz)''Documents''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(VisualworksVmlzdWFsd29ya3M)''Visual works''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(VisualworksVmlzdWFsd29ya3M)''Visual works''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(VesselsVmVzc2Vscw)''Vessels''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(VesselsVmVzc2Vscw)''Vessels''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(CollagesQ29sbGFnZXM)''Collages''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(CollagesQ29sbGFnZXM)''Collages''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(ToolsandequipmentVG9vbHNhbmRlcXVpcG1lbnQ)''Tools and equipment''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(ToolsandequipmentVG9vbHNhbmRlcXVpcG1lbnQ)''Tools and equipment''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(MoneyTW9uZXk)''Money''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(MoneyTW9uZXk)''Money''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(PrintsUHJpbnRz)''Prints''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(PrintsUHJpbnRz)''Prints''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(Foundobject1435614131420)''Found object''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(Foundobject1435614131420)''Found object''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(FurnitureRnVybml0dXJl)''Furniture''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(FurnitureRnVybml0dXJl)''Furniture''';
update collectionobjects_common_contentconcepts set item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(classification):item:name(PhotographsUGhvdG9ncmFwaHM)''Photographs''' where item = 'urn:cspace:collection.watermillcenter.org:conceptauthorities:name(concept):item:name(PhotographsUGhvdG9ncmFwaHM)''Photographs''';
























