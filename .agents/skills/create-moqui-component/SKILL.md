---
name: create-moqui-component
description: >-
  Scaffolds a Moqui component with component.xml, MoquiConf screen mount,
  seed ArtifactAuthz, optional REST, load, and verification. Use when the
  user asks to create a component, run createComponent, start a new app or
  REST package, or build the first screen/API in runtime/component/.
---

# Create a Moqui component

Read this file before creating files. Do not invent a parallel layout.

## Preconditions

- `runtime/` exists (`./gradlew getRuntime` if missing). Search it with
  an explicit path; do not skip it because it is gitignored.
- Server is stopped before `./gradlew load`.
- Prefer existing `mantle-udm` / `mantle-usl` over new entities/services.

`createComponent` is **interactive** (REST / screens / both, optional `src/`,
git, `myaddons.xml`). Use it only when a human can answer prompts:

```bash
./gradlew createComponent -Pcomponent=my-app
```

If the agent cannot drive stdin, create `runtime/component/{name}/` from the
templates below (same result as the `start` component after rename).

Install an existing catalog component instead of scaffolding:

```bash
./gradlew getComponent -Pcomponent=example
./gradlew getDepends
```

## Required files

| File | Why |
|------|-----|
| `component.xml` | Name, version, `depends-on` |
| `MoquiConf.xml` | Mount screens on `apps.xml` (skip mount if REST-only) |
| `data/AppSeedData.xml` | `AT_XML_SCREEN` authz for the app root |
| `data/ApiSeedData.xml` | `AT_REST_PATH` authz for `/rest/s1/{name}` |
| `data/{Prefix}L10nData.xml` | zh for menus, labels, Status/Enumeration (screens or Status/Enumeration) |
| `screen/App.xml` | App root (screens) |
| `service/{path}/Services.xml` | At least one testable service |
| `service/{name}.rest.xml` | Only if exposing REST |

Replace `my-app` / `my.app` with the real name. After files exist:
`./gradlew getDepends`, stop server, `./gradlew load`, start server, verify.

## component.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<component xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="http://moqui.org/xsd/moqui-conf-3.xsd"
        name="my-app" version="1.0.0">
    <depends-on name="mantle-udm"/>
    <depends-on name="mantle-usl"/>
    <depends-on name="SimpleScreens"/>
</component>
```

Add `SimpleScreens` when screens reuse party/status/enum templates or
extend catalog forms. See
`.agents/skills/moqui-xml-dsls/references/screen-ui-patterns.md`.

Missing deps fail at runtime. Fix with `./gradlew getDepends`.

## MoquiConf.xml (screens)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<moqui-conf xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="http://moqui.org/xsd/moqui-conf-3.xsd">
    <screen-facade>
        <screen location="component://webroot/screen/webroot/apps.xml">
            <subscreens-item name="my-app" menu-title="My App" menu-index="97"
                    location="component://my-app/screen/App.xml"/>
        </screen>
    </screen-facade>
</moqui-conf>
```

URL becomes `/qapps/my-app/` (or `/apps/`, `/vapps/`, `/qapps2/`). Do not
edit webroot screens to add a menu item. `MoquiConf.xml` changes require
a restart. Custom `<render-mode><text>` keeps `type="qvt"` / `qvue` /
`qjs`; `/qapps2` macros fall back. Do not add `qvt2`/`qvue2`/`qjs2`
unless the markup differs. See
`.agents/skills/moqui-xml-dsls/references/screen.md`.

REST-only: keep an empty `<moqui-conf>...</moqui-conf>` and skip App seed.

## App seed authz

`data/AppSeedData.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<entity-facade-xml type="seed">
    <moqui.security.ArtifactGroup artifactGroupId="MYAPP_APP"
            description="my-app screens"/>
    <moqui.security.ArtifactGroupMember artifactGroupId="MYAPP_APP"
            artifactTypeEnumId="AT_XML_SCREEN" inheritAuthz="Y"
            artifactName="component://my-app/screen/App.xml"/>
    <moqui.security.ArtifactAuthz artifactAuthzId="MYAPP_AUTHZ_ALL"
            userGroupId="ADMIN" artifactGroupId="MYAPP_APP"
            authzTypeEnumId="AUTHZT_ALWAYS" authzActionEnumId="AUTHZA_ALL"/>
</entity-facade-xml>
```

`inheritAuthz="Y"` covers subscreens under that root. A 403 on the new app
is usually missing seed, not a bad screen.

## L10n seed (en / zh)

Keep screen and `MoquiConf` `menu-title` in English. Required when the
component has screens or seeds `StatusItem` / `Enumeration`.
`data/MyAppL10nData.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<entity-facade-xml type="seed">
    <moqui.basic.LocalizedMessage original="My App" locale="zh" localized="我的应用"/>
</entity-facade-xml>
```

If the component seeds `StatusItem` or `Enumeration`, add
`LocalizedEntityField` in the same file. After you change a menu or
label original, update the matching `original` and its `zh` row. Do
not duplicate `framework/data/CommonL10nData.xml`. Full rules:
`.agents/skills/moqui-xml-dsls/references/l10n.md`.

## REST + API seed

`service/my-app.rest.xml` — root `name` is the URL segment after `/rest/s1/`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<resource name="my-app" displayName="My App REST API" version="1.0.0">
    <resource name="ping">
        <method type="get">
            <service name="my.app.Services.ping"/>
        </method>
    </resource>
</resource>
```

`data/ApiSeedData.xml` — `artifactName` is `/{resourceName}`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<entity-facade-xml type="seed">
    <moqui.security.ArtifactGroup artifactGroupId="MYAPP_API"
            description="my-app REST API"/>
    <moqui.security.ArtifactGroupMember artifactGroupId="MYAPP_API"
            artifactTypeEnumId="AT_REST_PATH" inheritAuthz="Y"
            artifactName="/my-app"/>
    <moqui.security.ArtifactAuthz artifactAuthzId="MYAPP_API_AUTHZ_ALL"
            userGroupId="ADMIN" artifactGroupId="MYAPP_API"
            authzTypeEnumId="AUTHZT_ALWAYS" authzActionEnumId="AUTHZA_ALL"/>
</entity-facade-xml>
```

## Minimal screen and service

`screen/App.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<screen xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="http://moqui.org/xsd/xml-screen-3.xsd"
        default-menu-title="My App" require-authentication="true">
    <widgets>
        <label text="My App" type="h3"/>
    </widgets>
</screen>
```

Before adding Find/Edit screens: read
`.agents/skills/moqui-xml-dsls/references/screen-ui-patterns.md` (FK
widgets, inline forms, SimpleScreens includes). Search
`runtime/component/SimpleScreens` for matching `Edit*.xml` and
`template/` before writing new forms.

`service/my/app/Services.xml` → `my.app.Services.ping`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<services xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="http://moqui.org/xsd/service-definition-3.xsd">
    <service verb="ping" authenticate="anonymous-all">
        <out-parameters>
            <parameter name="ok" type="Boolean" default="true"/>
        </out-parameters>
    </service>
</services>
```

Official/catalog components usually have no `AGENTS.md`; infer from
`component.xml`, `MoquiConf.xml`, and `data/*SeedData.xml`. For a new
local component, copy `templates/component-AGENTS.md` into the
component as `AGENTS.md` and fill the placeholders.

## Load and verify

1. `./gradlew getDepends`
2. Stop `moqui.war` (see [.agents/dev-loop.md](../../dev-loop.md))
3. `./gradlew load` (or `-Ptypes=seed` if only seed changed)
4. Start the server; wait for 8080 plus ~5 seconds
5. ServiceRun (works without REST):

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -u john.doe:moqui \
  -d '{"serviceName": "my.app.Services.ping"}' \
  http://localhost:8080/apps/tools/Service/ServiceRun/runJson
```

6. Screen: `http://localhost:8080/qapps/my-app/` (also `/qapps2/my-app/`)
7. REST: `curl -s -u john.doe:moqui http://localhost:8080/rest/s1/my-app/ping`
8. On 403/500, read `runtime/log/moqui.log`. 403 → seed authz. Entity
   or `MoquiConf` edits need a restart.

XML field conventions: `.agents/skills/moqui-xml-dsls/SKILL.md`.
L10n: `.agents/skills/moqui-xml-dsls/references/l10n.md`.
