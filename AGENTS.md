# AGENTS

Moqui is a business automation/ERP framework with XML DSLs for entities,
services, and screens. This file is the portable always-on contract for
Cursor, Codex, and OpenCode.

## Search

This git tree is **moqui-framework**. `runtime/` is a separate checkout
(`moqui-runtime`), listed in `.gitignore`. That is a git boundary only.

`runtime/` is on disk and is the **primary working tree** for apps and
installed components. Search it. Read it. Edit local components under
`runtime/component/`. Do not treat gitignore as "unavailable", do not
announce that search tools may skip it, and do not substitute GitHub or
official docs for files that exist locally.

Grep/Glob honor `.gitignore` and nested repos:

1. Confirm `runtime/` exists. If not: `./gradlew getRuntime`.
2. Never Grep/Glob the workspace root without `path` for app or
   component code. Never use `path` / `target_directory` = `runtime/`
   (`runtime/.gitignore` hides `component/`).
3. First call must set `path` / `target_directory` to one of these
   (parallel if the location is unknown; do not fan out per component):
   - `runtime/component` — all components except webroot/tools
     (including `mantle-udm`, `mantle-usl`, local apps)
   - `runtime/base-component` — webroot, tools
   - `framework` — Java/XSD (or omit path)
4. Narrow to `runtime/component/{name}` only when you already know the
   component. Do not retry once per component after a zero-result search.
5. `.cursorignore` tries to keep these trees visible to Cursor. Tools
   may still honor `.gitignore`; the paths above are required either way.
   Read/Write by full path always works.

Skip generated trees: `runtime/log/`, `runtime/db/`, `runtime/sessions/`,
`runtime/txlog/`. Also do not edit `build/` or `framework/build/`.

List installed components from
`runtime/base-component/*/component.xml` and
`runtime/component/*/component.xml`
(`runtime/component` overrides `runtime/base-component` when names match).

## Edit

Prefer existing `mantle-udm` entities and `mantle-usl` services, and DSLs
over custom Java/Groovy. Keep diffs small.

App and business changes go in a **local** component under
`runtime/component/`. Do not edit `runtime/base-component/` (`webroot`,
`tools`) or catalog components (`mantle-udm`, `mantle-usl`,
`SimpleScreens`, `MarbleERP`). Add fields with `<extend-entity>`; hook
existing services/entities with SECA/EECA; mount screens from this
component's `MoquiConf.xml`. Framework work in `framework/` is exempt.
Resources: `component://{name}/path`; `MoquiConf.xml` merges in
`depends-on` order. Access APIs via ExecutionContext (`ec`).

## Lazy

- When editing a component, read its `AGENTS.md` (scoped rules; this
  search contract still applies). Nested AGENTS under `runtime/` are not
  auto-injected (gitignore). Do not read `component/doc/*.md` unless the
  task touches that area.
- When editing `runtime/component/`, also read
  [.agents/component-common.md](.agents/component-common.md).
- Start/stop server, load data, or verify:
  [.agents/dev-loop.md](.agents/dev-loop.md).
- XML or new-component work: matching file under
  [.agents/skills/](.agents/skills/) (start with
  [moqui-xml-dsls/SKILL.md](.agents/skills/moqui-xml-dsls/SKILL.md)).

Do not use `.cursor/rules` or `.cursor/skills` as the source of truth.

## Run

- URL: `http://localhost:8080` (`/qapps` or `/Login`)
- Demo credentials (after demo data): `john.doe` / `moqui`
- Log: `runtime/log/moqui.log`
- One-time (after runtime exists): `./gradlew load`, then
  `java -jar moqui.war`. Healthy when 8080 is listening and a request
  succeeds. OpenSearch only if search/elastic features are required.
