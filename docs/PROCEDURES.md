Procedures
==========

**Acquisitions**

```bash
# generate
rake template:acquisitions:objects:process[templates/acquisitions/watermill-acq.csv]
rake cs:post:directory[/acquisitions,imports,0.08]
```

**Condition Check**

```bash
rake template:conditioncheck:objects:process[templates/conditioncheck/watermill-cond.csv]
rake cs:post:directory[/conditionchecks,imports,0.08]
```

**Valuation Control**

```bash
rake template:valuationcontrol:objects:process[templates/valuationcontrol/watermill-val.csv]
rake cs:post:directory[/valuationcontrols,imports,0.08]
```

---