# Entity XML

XSD: `framework/xsd/entity-definition-3.xsd`. Files under `entity/`.
**Restart the server** after entity changes.

Full name is `{package}.{EntityName}`. `short-alias` is unique, lowercase,
plural (REST / shorthand).

```xml
<!-- good -->
<entity entity-name="Widget" package="my.app" short-alias="widgets">
    <field name="widgetId" type="id" is-pk="true"/>
    <field name="widgetName" type="text-medium" not-null="true"/>
    <field name="statusId" type="id"/>
    <relationship type="one" title="Status" related="moqui.basic.StatusItem">
        <key-map field-name="statusId"/>
    </relationship>
</entity>
```

```xml
<!-- bad: redefining a mantle entity; missing package; camel short-alias -->
<entity entity-name="Product" package="mantle.product" short-alias="Product">
    <field name="productId" type="id" is-pk="true"/>
</entity>
```

- Extend someone else's entity with `<extend-entity>`, not a second
  `<entity>` of the same name.
- Do not change PK or field types on a dependency entity.
- View-entity for joins/projections; ECA in `entity/*.eecas.xml`.
- Common types: `id`, `id-long`, `text-short`, `text-medium`, `text-long`,
  `date-time`, `number-decimal`, `number-integer`.
- Relationship `related` uses the full entity name. `one` / `one-nofk` /
  `many`.
- Data XML and finds use the full name: `my.app.Widget`.
- Seed `StatusItem` / `Enumeration` descriptions in English; add
  `LocalizedEntityField` in `*L10nData.xml`. See [l10n.md](l10n.md).
