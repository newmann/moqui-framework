---
name: moqui-xml-dsls
description: >-
  Moqui XML DSL conventions for entity, service, screen, form, REST, and
  data files. Use when creating or editing entity/*.xml, service/*.xml,
  service/*.rest.xml, screen/*.xml, data/*.xml, ECA files, or when the
  user mentions entity-definition, verb#Noun, form-single, form-list,
  entity-facade-xml, or ArtifactAuthz seed data.
---

# Moqui XML DSLs

Read **only** the reference that matches the files you are changing:

| Changing | Read |
|----------|------|
| `entity/**/*.xml`, `*.eecas.xml` | [references/entity.md](references/entity.md) |
| `service/**/*.xml` (not REST) | [references/service.md](references/service.md) |
| `service/*.rest.xml` | [references/service.md](references/service.md) (REST section) |
| `screen/**/*.xml` | [references/screen.md](references/screen.md) and [references/screen-ui-patterns.md](references/screen-ui-patterns.md) (`qvt`/`qvue`/`qjs`; qapps2 falls back, no `*2` types) |
| `data/**/*.xml` | [references/data.md](references/data.md) |
| UI / Status / service copy (en/zh) | [references/l10n.md](references/l10n.md) |

XSDs live in `framework/xsd/`. Prefer existing `mantle-udm` / `mantle-usl`
artifacts: search with `path` = `runtime/component` (not workspace root,
not `runtime/`); do not search only `framework/` or a remote repo. After
edits, follow the feedback loop in
[.agents/dev-loop.md](../../dev-loop.md) (restart rules, ServiceRun
`runJson`, `runtime/log/moqui.log`).
