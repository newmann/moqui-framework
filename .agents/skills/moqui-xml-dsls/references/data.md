# Data XML

Root: `<entity-facade-xml type="seed|demo|...">`. Use **full** entity names
as element names. Loads are transactional: one error rolls back the file.

| `type` | Use |
|--------|-----|
| `seed` | Required for the app to run (users, authz, status, conf) |
| `seed-initial` | Framework reference data (geo, currency, setup) |
| `install` | One-time install / first-run setup |
| `demo` | Dev/test samples. Load after seed |

Name demo files with a `Zzz` prefix so they load after seed
(`data/ZzzDemoData.xml`).

```xml
<!-- good -->
<entity-facade-xml type="demo">
    <my.app.Widget widgetId="WGT_001" widgetName="Demo widget"/>
</entity-facade-xml>
```

```xml
<!-- bad: short name, mixed types in one file, running load with server up -->
<entity-facade-xml type="all">
    <Widget widgetId="1"/>
</entity-facade-xml>
```

- **Stop the server** before `./gradlew load`. Then start and verify.
- Screen authz: `AT_XML_SCREEN` on `component://.../screen/App.xml`.
- REST authz: `AT_REST_PATH` on `/{resourceName}`.
- Patterns are in `.agents/skills/create-moqui-component/SKILL.md`.
- DataImport / EntityDataFind are for ad-hoc checks, not committed data.
- Do not put secrets in `data/`.
- Screen/Status/service translations: `data/{Prefix}L10nData.xml`
  (`LocalizedMessage`, `LocalizedEntityField`). See [l10n.md](l10n.md).
