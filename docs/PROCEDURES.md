Procedures
==========

For setting relationships between cataloging and procedures see [RELATIONS](RELATIONS.md).

**Acquisitions**

```bash
# generate
rake template:cs:acquisitions:process[templates/acquisitions/watermill-acq.csv]
rake cs:post:directory[acquisitions,imports]
```

**Condition Check**

```bash
rake template:cs:conditioncheck:process[templates/conditioncheck/watermill-cond.csv]
rake cs:post:directory[conditionchecks,imports]
```

**Valuation Control**

```bash
rake template:cs:valuationcontrol:process[templates/valuationcontrol/watermill-val.csv]
rake cs:post:directory[valuationcontrols,imports]
```

---
