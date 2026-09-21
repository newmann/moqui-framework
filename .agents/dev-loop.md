# Dev loop — verify changes against a running server

Read this file when starting/stopping the server, loading data, or
verifying services, entities, or screens. Do not declare success from
XML or compile output alone.

## When to restart

**Restart** after entity definitions, `MoquiConf.xml`, SECA/EECA, or other
conf. **No restart** for service XML, screen XML, or data files (data still
needs a load with the server stopped). After a service/screen save, wait
about 5 seconds for cache refresh.

## Server

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
# Optional: java -jar moqui.war conf=conf/MoquiDevConf.xml
# Unix background: nohup java -jar moqui.war >> runtime/log/moqui-console.log 2>&1 &
```

Wait until `runtime/log/moqui.log` shows a Jetty connector on 8080, then
wait about 5 more seconds.

## Data

**Stop the server** before `./gradlew load`. Types on
`<entity-facade-xml type="...">`: `seed` (required system data),
`seed-initial` (framework reference data), `install` (one-time setup),
`demo` (dev/test). Default load is all types.

```bash
./gradlew load
./gradlew load -Ptypes=demo
./gradlew load -Ptypes=seed,seed-initial,install
```

Use full entity names in component `data/*.xml`. Ad-hoc only (not a
substitute for committed data files): `/qapps/tools/Entity/DataImport`
and EntityDataFind.

## Service

Always defined in `service/*.xml`. Prefer XML `<actions>`. Alternatives:
inline Groovy `<script>`, external `type="script" location="component://..."`,
or a compiled class (`src/` has no automatic `ec`).

Naming: file `service/mantle/order/OrderServices.xml` plus
`<service verb="get" noun="OrderInfo">` is
`mantle.order.OrderServices.get#OrderInfo`.

Test **any** service without REST. UI: `/qapps/tools/Service/ServiceRun`.
This `runJson` pattern is the authority; only the JSON body changes:

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -u john.doe:moqui \
  -d '{"serviceName": "org.moqui.impl.BasicServices.get#GeoRegionsForDropDown", "geoId": "USA"}' \
  http://localhost:8080/apps/tools/Service/ServiceRun/runJson
```

Custom REST (`/rest/s1/...`) only after `*.rest.xml` plus API seed authz.
Loop: edit → wait 5s → `runJson` → on error read `runtime/log/moqui.log`
→ fix.

## Entity

Edit `entity/*.xml` → restart → EntityDataFind
`?selectedEntity=package.EntityName`. `/rest/e1/` needs ENTITY_REST
(`john.doe` does not have it). `/rest/e1/` and `/rest/m1/` are not the
default agent path.

## Screen

Edit `screen/*.xml` → reload the browser. The app URL is
`/qapps/{subscreens-item-name}/...` (also `/qapps2/...`) only after
`MoquiConf.xml` mounts it (see the create-component skill). Screens
display and transition; business work goes through `<service-call>`.
Custom `<render-mode><text>` uses `qvt` / `qvue` / `qjs`; `/qapps2`
macros fall back and do not require `qvt2` / `qvue2` / `qjs2`.
Path issues: Screen Info under `/qapps/tools`.

## Logs and common errors

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
- Live Groovy: Groovy Shell under `/qapps/tools` (needs `GROOVY_SHELL_WEB`)
