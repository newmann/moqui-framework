# AGENTS — {component-name}

Scoped rules for this component. This file overrides the repository root
`AGENTS.md` when you are working in this directory.

## Role

One sentence: what this component is for.

Depends on (from `component.xml`):

- `{dependency}`

## Find things here

- Entities: `entity/` — package prefix `{package}`
- Services: `service/` — namespace `{path.ServiceFile}`
- Screens: `screen/` — app root `{screen/App.xml}`
- REST: `service/{name}.rest.xml` — `/rest/s1/{resourceName}/`
- Seed: `data/AppSeedData.xml`, `data/ApiSeedData.xml`,
  `data/{Prefix}L10nData.xml`
- Demo: `data/ZzzDemoData.xml`

## Conventions

- Default `userGroupId` for new authz: `ADMIN` unless this app defines another
- Do not redefine mantle entities; extend with `<extend-entity>`,
  view-entity, SECA/EECA, or this component's own package
- New services stay under this component's service path
- Mount screens from this component's `MoquiConf.xml`
- UI original text stays English; Chinese only in `data/{Prefix}L10nData.xml`
- User-facing service errors call `ec.l10n.localize` (or `ec.resource.expand`) first

## Verify

After changes, use one of these (adjust names):

```bash
curl -s -X POST -H "Content-Type: application/json" \
  -u john.doe:moqui \
  -d '{"serviceName": "{path.Services.verb#Noun}"}' \
  http://localhost:8080/apps/tools/Service/ServiceRun/runJson
```

- Screen: `http://localhost:8080/qapps/{subscreens-item-name}/`
  (also `/qapps2/{subscreens-item-name}/`)
- REST: `http://localhost:8080/rest/s1/{resourceName}/`

## Do not

- Edit entities, services, or screens in a dependency or catalog
  component (`mantle-udm`, `mantle-usl`, `SimpleScreens`, `MarbleERP`,
  `webroot`). Use `<extend-entity>`, SECA/EECA, or this component's
  `MoquiConf.xml` instead
- Mount screens by editing `webroot` files; use this component's `MoquiConf.xml`
- Skip seed ArtifactAuthz for a new app root screen or REST root path
