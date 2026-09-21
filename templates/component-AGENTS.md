# AGENTS — {component-name}

Domain rules for this component. Supplements root [AGENTS.md](../../AGENTS.md)
and shared [.agents/component-common.md](../../.agents/component-common.md).

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

Component-specific rules only (authz groups, domain invariants, phase order).
Shared mount/l10n/authz/verify rules: `.agents/component-common.md`.

## Verify

- ServiceRun: `{path.Services.verb#Noun}` (see `.agents/dev-loop.md` for curl)
- Screen: `/qapps/{subscreens-item-name}/`
- REST: `/rest/s1/{resourceName}/`
