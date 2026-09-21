# Component conventions (shared)

Read when editing `runtime/component/`. Component `AGENTS.md` files add
domain rules on top of this. Do not edit catalog/base components: see
root AGENTS.

## This component

- Mount screens from this component's `MoquiConf.xml`; do not edit
  `webroot` files.
- New services stay under this component's service path.
- Mantle-based screens: reuse `component://SimpleScreens/template/` and
  catalog `Edit*.xml` via include/extend; do not copy transitions or forms.
  See `.agents/skills/moqui-xml-dsls/references/screen-ui-patterns.md`.

## Authz and l10n

- Default `userGroupId` for new authz: `ADMIN` unless this app defines another.
- Skip seed ArtifactAuthz for a new app root screen or REST root path.
- UI original text stays English; Chinese only in `data/{Prefix}L10nData.xml`.
- User-facing service errors call `ec.l10n.localize` (or
  `ec.resource.expand`) first.

## Verify

ServiceRun `runJson` pattern: [dev-loop.md](dev-loop.md). Use
`{path.Services.verb#Noun}`.

- Screen: `/qapps/{subscreens-item-name}/` (also `/qapps2/...`)
- REST: `/rest/s1/{resourceName}/`
