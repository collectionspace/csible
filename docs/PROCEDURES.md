Procedures
==========

For setting relationships between cataloging and procedures see [RELATIONS](RELATIONS.md).

**Acquisitions**

```bash
# generate
rake template:acquisitions:process[templates/acquisitions/watermill-acq.csv]
rake cs:post:directory[acquisitions,imports]
```

**Condition Check**

```bash
rake template:conditioncheck:process[templates/conditioncheck/watermill-cond.csv]
rake cs:post:directory[conditionchecks,imports]
```

**Valuation Control**

```bash
rake template:valuationcontrol:process[templates/valuationcontrol/watermill-val.csv]
rake cs:post:directory[valuationcontrols,imports]
```

---
