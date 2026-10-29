# Service and REST XML

XSD: `framework/xsd/service-definition-3.xsd`. File path is the namespace:
`service/my/app/Services.xml` plus `<service verb="get" noun="Widget">`
→ `my.app.Services.get#Widget`.

## Service body

Write the body in `<actions>`, the way
`runtime/component/mantle-usl/service` does. Use `entity-find` /
`entity-find-one`, `if`, `set`, `iterate`, `service-call`,
`entity-make-value`, `entity-create` / `entity-update` /
`entity-delete`, and `return`. Short expressions on `from` and
`condition` are fine (`from="a ?: b"`).

Finds, branches, and writes that those operations can express stay in
XML. Do not move that work into a Groovy class under `src/` (compiled
classes do not get `ec` automatically) or an external
`type="script" location="component://..."`.

When the logic is complex and XML is a poor fit, use an inline
`<script>` for that part only. Examples: JSON parse or serialize, a
regex split, a graph walk, YAML or zip, nested loops, temporary
structures, and calculations that are awkward as XML operations. Keep
the surrounding flow in `<actions>`.

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
