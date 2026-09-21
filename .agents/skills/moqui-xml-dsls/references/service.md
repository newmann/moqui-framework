# Service and REST XML

XSD: `framework/xsd/service-definition-3.xsd`. File path is the namespace:
`service/my/app/Services.xml` plus `<service verb="get" noun="Widget">`
→ `my.app.Services.get#Widget`.

Prefer `<actions>` XML. `src/` compiled classes do **not** get `ec`
automatically. Scripts: `type="script" location="component://..."`.

```xml
<!-- good -->
<service verb="get" noun="Widget" authenticate="true">
    <in-parameters>
        <parameter name="widgetId" required="true"/>
    </in-parameters>
    <out-parameters>
        <parameter name="widget" type="Map"/>
    </out-parameters>
    <actions>
        <entity-find-one entity-name="my.app.Widget" value-field="widget"/>
    </actions>
</service>
```

```xml
<!-- bad: wrong name (folder ignored), custom Java for a simple find -->
<service verb="getWidget" type="java" location="com.example.WidgetBean"/>
```

- `entity-auto` is fine for simple CRUD on one entity (`noun` = entity name).
- SECA: `service/*.secas.xml`. SECA/EECA changes need a restart; service
  body XML hot-reloads after ~5 seconds.
- Test with ServiceRun `runJson` ([.agents/dev-loop.md](../../../dev-loop.md)).
  Do not require REST first.
- User-facing `addError` / `addMessage` must call `ec.l10n.localize`
  (or `ec.resource.expand` for `${}` templates). See [l10n.md](l10n.md).

## REST (`service/*.rest.xml`)

XSD: `rest-api-3.xsd`. Root `<resource name>` → `/rest/s1/{name}/...`.
Needs matching `ApiSeedData.xml` (`AT_REST_PATH`, `artifactName="/{name}"`).
See `.agents/skills/create-moqui-component/SKILL.md`.

Verb habit: GET find, POST create/do, PUT store, PATCH update, DELETE delete.
Method child is `<service name="..."/>` or `<entity name="short-alias"
operation="list|one|create|update|delete|store"/>`.
