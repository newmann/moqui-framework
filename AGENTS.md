# AGENTS

Moqui is a business automation/ERP framework. Entities, services, and
screens are XML DSLs.

## Search

`runtime/` is on disk and is the working tree for apps. Read and edit it
by full path. Do not skip it because it is gitignored, and do not replace
local files with GitHub or official docs.

Grep/Glob `path` must be one of:

- `runtime/component` — apps and catalog (`mantle-udm`, `mantle-usl`, local apps)
- `runtime/base-component` — webroot, tools
- `framework` — Java/XSD (or omit path)

Pick one tree from the task. Search all three in parallel only when the
artifact's tree is unknown. Do not search the workspace root or set `path`
to `runtime/` (`runtime/.gitignore` hides `component/`). Do not retry once
per component after zero results. Narrow to `runtime/component/{name}` only
when the name is already known.

Skip `runtime/log/`, `runtime/db/`, `runtime/sessions/`, and `runtime/txlog/`.
Do not edit `build/` or `framework/build/`.

If `runtime/component` cannot be read, run `./gradlew getRuntime`.

## Edit

Write app changes only in the local component that owns the feature.
Before editing, read `runtime/component/{name}/AGENTS.md` by full path.
No such file means catalog: read only, do not modify, do not add AGENTS.md.

Do not modify `runtime/base-component/` (`webroot`, `tools`), `mantle-udm`,
`mantle-usl`, `SimpleScreens`, or any other installed component without an
AGENTS.md. `*-zh_CN` components are translation overlays only.

Prefer existing mantle entities and services. Extend with `<extend-entity>`,
SECA/EECA, and this component's `MoquiConf.xml`. Framework work in
`framework/` is exempt.

Before writing XML, read the matching skill under `.agents/skills/`:
`create-moqui-component/SKILL.md` for a new component; otherwise
`moqui-xml-dsls/SKILL.md`, then only the reference for the files you change.

## Read next

- Editing `runtime/component/{name}`: its `AGENTS.md`, then
  `.agents/component-common.md`. Nested AGENTS.md files are not
  auto-injected. Do not read `component/doc/*.md` unless the task
  touches that area.
- Start, stop, load, or verify: `.agents/dev-loop.md`.

This file and `.agents/` are the source of truth. Do not use
`.cursor/rules` or `.cursor/skills`.

## Run

- `http://localhost:8080` (`/qapps`, `/Login`). Demo: `john.doe` / `moqui`.
- Log: `runtime/log/moqui.log`.
- Start, stop, load, and whether to restart: `.agents/dev-loop.md` only.
