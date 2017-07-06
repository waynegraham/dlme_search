# DLME Application Profile and Schema Mapping

## Assumptions for initial prototype

* DLME needs to aggregate data about cultural heritage objects sourced from
multiple institutions using various schemas into a common index
* Any application profile, model, used etc. for DLME should be based on a
preexisting application profile, and document any needed divergences
* For the prototype phase, any downstream publication or production of RDF
should be considered secondary
* Subsequently, context classes may not be applicable if data is only available
as literals

## Application profile


The DLME Prototype Application Profile a subset of the [Europeana Data Model](http://pro.europeana.eu/share-your-data/data-guidelines/edm-documentation).
Currently, the Application Profile only focuses on implementation of EDM's core
classes (i.e. `ore:Aggregation`, `edm:ProvidedCHO`, and `edm:WebResource`), plus
the [EDM Profile for IIIF](http://pro.europeana.eu/files/Europeana_Professional/Share_your_data/Technical_requirements/EDM_profiles/IIIFtoEDM_profile_042016.pdf).

![Drawing of basic model](model.png)

### Expectation key

| Code   | Description |
| ------ | ----------- |
| **M**  | Mandatory   |
| **M+** | Mandatory if applicable |
| **R**  | Recommended |
| **R+** | Recommended if applicable |

### Namespaces

```turtle
@prefix dc: <http://purl.org/dc/elements/1.1/> .
@prefix dct: <http://purl.org/dc/terms/> .
@prefix doap: <http://usefulinc.com/ns/doap#> .
@prefix edm: <http://www.europeana.eu/schemas/edm/> .
@prefix ore: <http://www.openarchives.org/ore/terms/> .
@prefix owl: <https://www.w3.org/2002/07/owl#> .
@prefix svcs: <http://rdfs.org/sioc/services#> .
```

### `edm:ProvidedCHO`

| Solr field name  | Property          | Req? | Cardinality | Value type  | Notes                      |
| ---------------- | ----------------- | ---- | ----------- | ----------- | -------------------------- |
| cho_alternative  | `dct:alternative` |      | 0...n       | literal     |                            |
| cho_contributor  | `dc:contributor`  | R    | 0...n       | literal     |                            |
| cho_coverage     | `dc:coverage`     | R    | 0...n       | literal     |                            |
| cho_creator      | `dc:creator`      | R    | 0...n       | literal     |                            |
| cho_date         | `dc:date`         | R    | 0...n       | literal     |                            |
| cho_dc_rights    | `dc:rights`       |      | 0...n       | literal/ref | Use to give the name of the rights holder of the CHO if possible or for more general rights information; prefer `edm:rights` if more applicable |
| cho_description  | `dc:description`  | R    | 0...n       | literal     |                            |
| cho_edm_type     | `edm:type`        | R    | 0...n       | literal     | constrained list for facets |
| cho_extent       | `dct:extent`      |      | 0...n       | literal     |                            |
| cho_format       | `dc:format`       |      | 0...n       | literal     |                            |
| cho_has_part     | `dct:hasPart`     |      | 0...n       | literal/ref |                            |
| cho_has_type     | `edm:hasType`     | R    | 0...n       | literal     |                            |
| cho_identifier   | `dc:identifier`   |      | 0...n       | literal/ref |                            |
| cho_is_part_of   | `dct:isPartOf`    |      | 0...n       | literal/ref |                            |
| cho_language     | `dc:language`     | M+   | 0...n       | literal     | Mandatory for text in Europeana; determine if BCP47 language tags are feasible |
| cho_medium       | `dct:medium`      |      | 0...n       | literal     |                            |
| cho_provenance   | `dct:provenance`  | R+   | 0...n       | literal     | Recommended if available   |
| cho_publisher    | `dc:publisher`    |      | 0...n       | literal     |                            |
| cho_relation     | `dc:relation`     |      | 0...n       | literal/ref |                            |
| cho_same_as      | `owl:sameAs`      | R+   | 0...n       | reference   |                            |
| cho_source       | `dc:source`       |      | 0...n       | literal/ref |                            |
| cho_spatial      | `dct:spatial`     | R    | 0...n       | literal     |                            |
| cho_subject      | `dc:subject`      | R    | 0...n       | literal     |                            |
| cho_temporal     | `dct:temporal`    | R    | 0...n       | literal     |                            |
| cho_title        | `dc:title`        | M    | 1...n       | literal     |                            |
| cho_type         | `dc:type`         | R    | 0...n       | literal     | cf `edm:type` for faceting |

### `ore:Aggregation`

| Solr field name    | Property            | Req? | Cardinality | Value type  | Notes                      |
| ------------------ | ------------------- | ---- | ----------- | ----------- | -------------------------- |
| id                 | n/a                 | M    | 1...1       | literal     | Used to generate URIs in application. Should be generated by combination of source data ID and a provider ID |
| agg_aggregated_cho | `edm:aggregatedCHO` | M    | 1...1       | reference   | Solr document represents aggregation; inferred 1:1 relationship with the ProvidedCHO instance. derive from data if possible |
| agg_data_provider  | `edm:dataProvider`  | M    | 1...1       | literal     |                            |
| agg_dc_rights      | `dc:rights`         |      | 0...n       | literal     | Ideally this should be applied to the `edm:WebResource` or the `edm:ProvidedCHO`. |
| agg_edm_rights     | `edm:rights`        | R    | 1...n       | reference   | The rights statement that applies to an associated `edm:WebResource` when it doesn't have its own |
| agg_has_view       | `edm:hasView`       |      | 0...n       | JSON literal | The URL of a web resource which is a digital representation of the CHO. |
| agg_is_shown_at    | `edm:isShownAt`     | M+   | 0...1       | JSON literal | The URL of a web view of the object in full information context. |
| agg_is_shown_by    | `edm:isShownBy`     | M+   | 0...1       | JSON literal | The URL of a web view of the object. (Europeana presumes this is renderable in the browser) |
| agg_preview        | `edm:preview`       | M+   | 0...1       | JSON literal | The URL of a web view of the object used as a thumbnail. This must be an image regardless of the type of object. |
| agg_provider       | `edm:provider`      | M    | 1...1       | literal     |                            |
| agg_same_as        | `owl:sameAs`        | R+   | 0...n       | reference   |                            |

### `edm:WebResource`

| JSON property name  | Property             | Req? | Cardinality | Value type   | Notes                      |
| ------------------- | -------------------- | ---- | ----------- | ------------ | -------------------------- |
| wr_id               | See notes            | M    | 1...1       | reference    | represents the URI for the `edm:WebResource` associated with a `ore:Aggregation` using `edm:hasView`, `edm:isShownAt`, `edm:isShownBy`, or `edm:preview` |
| wr_creator          | `dc:creator`         |      | 0...n       | literal      |                            |
| wr_dc_rights        | `dc:rights`          |      | 0...n       | literal      | prefer `edm:rights` if available |
| wr_description      | `dc:description`     |      | 0...n       | literal      |                            |
| wr_edm_rights       | `edm:rights`         | R    | 0...1       | reference    |                            |
| wr_format           | `dc:format`          | R    | 0...n       | literal      |                            |
| wr_has_service      | `svcs:has_service`   | R*   | 0...n       | JSON literal | for associating IIIF image resources see [EDM Profile for IIIF](http://pro.europeana.eu/files/Europeana_Professional/Share_your_data/Technical_requirements/EDM_profiles/IIIFtoEDM_profile_042016.pdf) |
| wr_is_referenced_by | `dct:isReferencedBy` | R*   | 0...n       | reference    | for associating IIIF presentation API resources; see [EDM Profile for IIIF](http://pro.europeana.eu/files/Europeana_Professional/Share_your_data/Technical_requirements/EDM_profiles/IIIFtoEDM_profile_042016.pdf) |

### `svcs:Service`

| JSON property name  | Property             | Req? | Cardinality | Value type   | Notes                      |
| ------------------- | -------------------- | ---- | ----------- | ------------ | -------------------------- |
| service_id          | See notes            | M    | 1...1       | reference    | represents the URI for the `svcs:Service` associated with a `edm:WebResource` using `svcs:has_service` |
| service_conforms_to | `dct:conformsTo`     | M    | 1...n       | reference    | for associating IIIF image services; see [EDM Profile for IIIF](http://pro.europeana.eu/files/Europeana_Professional/Share_your_data/Technical_requirements/EDM_profiles/IIIFtoEDM_profile_042016.pdf) |
| service_implements  | `doap:implements`    | R    | 0...1       | reference    | for associating IIIF image profiles; see [EDM Profile for IIIF](http://pro.europeana.eu/files/Europeana_Professional/Share_your_data/Technical_requirements/EDM_profiles/IIIFtoEDM_profile_042016.pdf) |


### JSON example

**IIIF resource**

```json
{
  "id": "llgc_1294670",
  "agg_data_provider": "National Library of Wales",
  "agg_edm_rights": "http://rightsstatements.org/vocab/CNE/1.0",
  "agg_is_shown_at": {
    "wr_id": "http://hdl.handle.net/10107/1294670"
  },
  "agg_is_shown_by": {
    "wr_id": "http://dams.llgc.org.uk/iiif/image/2.0/1294670/full/512,/0/default.jpg",
    "wr_format": "image/jpeg",
    "wr_has_service": [{
      "service_id": "http://dams.llgc.org.uk/iiif/image/2.0/1294670",
      "service_conforms_to": "http://iiif.io/api/image",
      "service_implements": "http://iiif.io/api/image/2/level1.json"
    }],
    "wr_is_referenced_by": "http://dams.llgc.org.uk/iiif/2.0/1294670/manifest.json"
  },
  "agg_preview": {
    "wr_id": "http://dams.llgc.org.uk/iiif/image/2.0/1294670/full/256,/0/default.jpg"
  },
  "agg_provider": "National Library of Wales",
  "agg_same_as": "http://hdl.handle.net/10107/1294670#id",
  "cho_coverage": ["England", "Kinsham"],
  "cho_creator": "Abery, P. B. (Percy Benzie), 1877-1948",
  "cho_date": "[191-?]",
  "cho_edm_type": "Image",
  "cho_extent": "119 x 163 mm.",
  "cho_is_part_of": "P. B. Abery Photographic Collection",
  "cho_medium": "1 negative : glass, b&w",
  "cho_same_as": "http://hdl.handle.net/10107/1294670",
  "cho_spatial": ["England", "Kinsham"],
  "cho_subject": ["Driveways", "Trees"],
  "cho_title": "The drive Kinsham Court",
  "cho_type": "Photograph"
}
```
