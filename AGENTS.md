# AGENTS

Moqui is a business automation/ERP framework with XML DSLs for entities,
services, and screens. This file is the portable always-on contract for
Cursor, Codex, and OpenCode.

## Repository boundary

This git tree is **moqui-framework**. `runtime/` is a separate checkout
(`moqui-runtime`). It is listed in `.gitignore` so it is **not committed
into this repo**. That is a git boundary only.

`runtime/` is on disk and is the **primary working tree** for apps and
installed components. Search it. Read it. Edit local components under
`runtime/component/`. Do not treat gitignore as "unavailable", do not
announce that search tools may skip it, and do not substitute GitHub or
official docs for files that exist locally.

How to search (tools that honor `.gitignore` skip `/runtime` from the
repo root):

1. Confirm `runtime/` exists. If not: `./gradlew getRuntime`.
2. Always pass an explicit path: Grep/Glob `path` /
   `target_directory` = `runtime/` or a component dir
   (`runtime/component/knowledge-base`, `runtime/mantle/mantle-udm`, …).
3. List installed components from
   `runtime/base-component/*/component.xml`,
   `runtime/mantle/*/component.xml`,
   `runtime/component/*/component.xml`,
   `runtime/ecomponent/*/component.xml`
   (later dirs override earlier ones with the same name).
4. Read/Write by full path always works. Cursor: `.cursorignore`
   un-ignores `runtime/` for Agent search; still pass an explicit path.

Skip generated trees when searching: `runtime/log/`, `runtime/db/`,
`runtime/sessions/`, `runtime/txlog/`.

## Component-specific instructions

When working in a component directory:

1. Read that directory's `AGENTS.md` if it exists. It overrides this file.
2. Official components usually have no `AGENTS.md`. Infer from
   `component.xml`, `MoquiConf.xml`, and `data/*SeedData.xml`.
3. For a new local component, copy [templates/component-AGENTS.md](templates/component-AGENTS.md)
   to `{component}/AGENTS.md` and fill it in.

## Project skills

Do not use `.cursor/rules` or `.cursor/skills` as the source of truth.
Project skills live in `.agents/skills/`. If the agent does not
auto-discover them, **read the file**. Start from
[.agents/skills/moqui-xml-dsls/SKILL.md](.agents/skills/moqui-xml-dsls/SKILL.md)
for XML work, then only the matching reference.

| Task | Read first |
|------|-----------|
| Entity, `extend-entity`, EECA | [.agents/skills/moqui-xml-dsls/references/entity.md](.agents/skills/moqui-xml-dsls/references/entity.md) |
| Service, SECA, REST | [.agents/skills/moqui-xml-dsls/references/service.md](.agents/skills/moqui-xml-dsls/references/service.md) |
| Screen, form | [.agents/skills/moqui-xml-dsls/references/screen.md](.agents/skills/moqui-xml-dsls/references/screen.md) |
| Data XML | [.agents/skills/moqui-xml-dsls/references/data.md](.agents/skills/moqui-xml-dsls/references/data.md) |
| UI / Status / service copy (en/zh) | [.agents/skills/moqui-xml-dsls/references/l10n.md](.agents/skills/moqui-xml-dsls/references/l10n.md) |
| New component, first app or REST | [.agents/skills/create-moqui-component/SKILL.md](.agents/skills/create-moqui-component/SKILL.md) |

## Quick start

- URL: `http://localhost:8080`
- Demo credentials (after demo data): `john.doe` / `moqui`
- Log: `runtime/log/moqui.log`
- Default DB is embedded H2. Docker Postgres is also fine
  (`docker/postgres-compose.yml`). Do not assume
  `runtime/db/h2/moqui.mv.db` exists.
- OpenSearch is optional unless the work uses search/elastic features.

Healthy if port 8080 is listening **and** a request succeeds.

```bash
# Unix: is 8080 open?
ss -ltn | grep 8080

# Windows PowerShell
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue

# Needs mantle + demo data; otherwise open /qapps or /Login
curl -s -u john.doe:moqui http://localhost:8080/rest/s1/mantle/parties
```

One-time (after runtime exists): `./gradlew load`, then start `moqui.war`.
Add `downloadOpenSearch startElasticSearch` only if search is required.

## Architecture

- **Framework** (`framework/`): Java/Groovy APIs, low-level services,
  entities, screens
- **Runtime** (`runtime/`): configuration, templates, base components
  (`webroot`, `tools`)
- **Components**: optional. Most apps need `mantle-udm` (entities) and
  `mantle-usl` (services). Look there first before adding new ones.

Each component `MoquiConf.xml` is merged in `depends-on` order after
framework defaults. Resources use `component://{componentName}/path`.

Typical layout: `component.xml`, `MoquiConf.xml`, `entity/`, `service/`,
`screen/`, `template/`, `data/`, optional `src/`.

## Create or install a component

Read the create-component skill and follow it. Checklist only:

```bash
./gradlew createComponent -Pcomponent=my-app
./gradlew getComponent -Pcomponent=example
./gradlew getDepends
```

`createComponent` is interactive (REST / screens / both). If the agent
cannot answer prompts, create the files from the skill instead.

Recognized with only `component.xml`. A usable app or API also needs:

- `component.xml` with `<depends-on>`
- `MoquiConf.xml` mounting a `subscreens-item` on
  `component://webroot/screen/webroot/apps.xml` (screens)
- `data/AppSeedData.xml` and/or `data/ApiSeedData.xml`
- `service/*.xml`; optional `service/{name}.rest.xml`, `entity/`, `screen/`

Catalog: `addons.xml` (do not edit). Local overrides: `myaddons.xml`.

## Core APIs

Access everything via ExecutionContext (`ec`):

- `ec.entity` — EntityFacade
- `ec.service` — ServiceFacade
- `ec.screen` — ScreenFacade
- `ec.web` — WebFacade
- `ec.user` — UserFacade
- `ec.message` — MessageFacade
- `ec.logger` — LoggerFacade
- `ec.l10n` — L10nFacade
- `ec.resource` — ResourceFacade
- `ec.cache` — CacheFacade
- `ec.transaction` — TransactionFacade
- `ec.artifactExecution` — ArtifactExecutionFacade
- `ec.elastic` — ElasticFacade

## DSLs

XSDs are in `framework/xsd/`. When editing XML, read
`.agents/skills/moqui-xml-dsls/` first.

- `entity-definition-3.xsd` — `entity/*.xml`
- `service-definition-3.xsd` — `service/*.xml`
- `xml-screen-3.xsd` / `xml-form-3.xsd` — screens and forms
- `xml-actions-3.xsd` — actions in services/screens
- `entity-eca-3.xsd` / `service-eca-3.xsd` / `email-eca-3.xsd` — ECA
- `rest-api-3.xsd` — `service/*.rest.xml` → `/rest/s1/{resourceName}/...`
- `moqui-conf-3.xsd` — `MoquiConf.xml` and `component.xml`

## Feedback loops

Implement, then verify against a running server. Do not declare success
from XML or compile output alone.

### When to restart

**Restart** after entity definitions, `MoquiConf.xml`, SECA/EECA, or other
conf. **No restart** for service XML, screen XML, or data files (data still
needs a load with the server stopped). After a service/screen save, wait
about 5 seconds for cache refresh.

### Server

Stop, then start from the repo root (`moqui.war` must exist;
`./gradlew build` if needed).

**Stop (Unix):**

```bash
pkill -9 -f "java.*moqui.war"; sleep 2
```

**Stop (Windows PowerShell):**

```powershell
Get-CimInstance Win32_Process |
  Where-Object { $_.CommandLine -match 'moqui\.war' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
```

**Start:**

```bash
java -jar moqui.war
# Optional explicit conf:
# java -jar moqui.war conf=conf/MoquiDevConf.xml
# Unix background:
# nohup java -jar moqui.war >> runtime/log/moqui-console.log 2>&1 &
```

Wait until `runtime/log/moqui.log` shows a Jetty connector on 8080, then
wait about 5 more seconds.

### Data

**Stop the server** before `./gradlew load`. Types on
`<entity-facade-xml type="...">`: `seed` (required system data),
`seed-initial` (framework reference data), `install` (one-time setup),
`demo` (dev/test). Default load is all types.

```bash
./gradlew load
./gradlew load -Ptypes=demo
./gradlew load -Ptypes=seed,seed-initial,install
```

Use full entity names in component `data/*.xml`. Ad-hoc (not a substitute
for committed data files): DataImport at
`/qapps/tools/Entity/DataImport`, EntityDataFind at
`/qapps/tools/Entity/DataEdit/EntityDataFind`.

### Service

Always defined in `service/*.xml`. Prefer XML `<actions>`. Alternatives:
inline Groovy `<script>`, external
`type="script" location="component://..."`, or a compiled class (`src/`
has no automatic `ec`).

Naming: file `service/mantle/order/OrderServices.xml` plus
`<service verb="get" noun="OrderInfo">` is
`mantle.order.OrderServices.get#OrderInfo`.

Test **any** service without REST. UI:
`http://localhost:8080/qapps/tools/Service/ServiceRun`

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -u john.doe:moqui \
  -d '{"serviceName": "org.moqui.impl.BasicServices.get#GeoRegionsForDropDown", "geoId": "USA"}' \
  http://localhost:8080/apps/tools/Service/ServiceRun/runJson
```

Reuse this `runJson` pattern; only the JSON body changes. Custom REST
(`/rest/s1/...`) only after `*.rest.xml` plus API seed authz.

Groovy call:
`ec.service.sync().name("...").parameter("x", x).call()`

Find:
`ec.entity.find('mantle.product.Product').condition('productId', id).one()`

Loop: edit → wait 5s → `runJson` → on error read `runtime/log/moqui.log`
→ fix.

### Entity

Edit `entity/*.xml` → restart → EntityDataFind
`?selectedEntity=package.EntityName`. `/rest/e1/` needs ENTITY_REST
(`john.doe` does not have it).

### Screen

Edit `screen/*.xml` → reload the browser. The app URL is
`/qapps/{subscreens-item-name}/...` (also `/qapps2/...`) only after
`MoquiConf.xml` mounts it (see the create-component skill). Screens
display and transition; business work goes through `<service-call>`.
Custom `<render-mode><text>` uses `qvt` / `qvue` / `qjs`; `/qapps2`
macros fall back and do not require `qvt2` / `qvue2` / `qjs2`.

### Testing endpoints

- ServiceRun UI: `/qapps/tools/Service/ServiceRun` (also `/qapps2/...`)
- ServiceRun JSON: `/apps/tools/Service/ServiceRun/runJson` (pattern above)
- Entity browser: `/qapps/tools/Entity/DataEdit/EntityDataFind`
- Custom REST: `/rest/s1/{api}/...` (must be in `*.rest.xml`)
- Screen Info: `/qapps/tools` → Screen Info
- Groovy Shell: `/qapps/tools` → Groovy Shell (needs `GROOVY_SHELL_WEB`)
- `/rest/e1/` and `/rest/m1/`: restricted; not the default agent path

### Logs and common errors

Read `runtime/log/moqui.log` including the full stack.

- Service not found → name/path
- Entity not found → definition name
- Required parameter not found → in-parameters
- SQL constraint → field defs
- User does not have permission → seed ArtifactAuthz
- NPE → missing data or relationship
- Validation / service messages → `ec.message.errors` and
  `ec.message.validationErrors`

## Troubleshooting

- Port 8080 in use: stop the `moqui.war` process (commands above)
- Search features fail: `./gradlew startElasticSearch`
- Service change not visible: wait 5 seconds
- Entity change not visible: restart
- REST 404: use ServiceRun; 403: authz; 500: log
- Load fails: server must be stopped
- Screen path issues: Screen Info under `/qapps/tools`
- Live Groovy expressions: Groovy Shell under `/qapps/tools`

## Coding standards

- Prefer existing `mantle-udm` entities and `mantle-usl` services
- Prefer DSLs over custom Java/Groovy
- App and business changes go in a **local** component under
  `runtime/component/`. Do not edit `runtime/base-component/`,
  `runtime/mantle/`, or catalog components (`mantle-udm`, `mantle-usl`,
  `SimpleScreens`, `MarbleERP`, `webroot`). Add fields with
  `<extend-entity>`; hook existing services/entities with SECA/EECA;
  mount screens from this component's `MoquiConf.xml`. Framework work
  in `framework/` is exempt.
- Keep diffs small and match existing style
- Do not edit `build/`, `framework/build/`, `runtime/log/`, `runtime/db/`

## Documentation

- Framework: https://moqui.org/docs/framework
- Quick Tutorial: https://www.moqui.org/docs/framework/Quick+Tutorial
- Scaffold: https://github.com/moqui/start
- Reference component: https://github.com/moqui/example
- All pages: https://moqui.org/m/alldocs/framework
