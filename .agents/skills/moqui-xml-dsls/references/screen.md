# Screen and form XML

XSD: `framework/xsd/xml-screen-3.xsd` (forms in `xml-form-3.xsd`).
Screens hot-reload; **`MoquiConf.xml` mount does not** — restart.

**Generating or editing screens:** also read
[screen-ui-patterns.md](screen-ui-patterns.md) — FK display names, inline
`form-single` layout, and SimpleScreens template reuse.

The menu URL is the `subscreens-item@name` on
`component://webroot/screen/webroot/apps.xml`, not the file name alone.
Mount from **this component's** `MoquiConf.xml`. Do not edit webroot.

Subscreen sources (later wins): directory `subscreens/`, screen XML
`<subscreens-item>`, component `MoquiConf.xml`, then DB
`moqui.screen.SubscreensItem` (legacy).

```xml
<!-- good: simple app root; mount it in MoquiConf.xml -->
<screen default-menu-title="My App" require-authentication="true">
    <widgets>
        <form-single name="FindWidget" transition="search">
            <field name="widgetName"><default-field><text-line/></default-field></field>
            <field name="submit"><default-field title="Find">
                <submit icon="fa fa-search"/></default-field></field>
        </form-single>
    </widgets>
</screen>
```

```xml
<!-- bad: assuming /qapps/App.xml works with no MoquiConf mount -->
<screen default-menu-title="My App"/>
```

```xml
<!-- bad: FK shown as raw id -->
<field name="statusId"><default-field><display/></default-field></field>
<!-- good -->
<field name="statusId"><default-field>
    <display-entity entity-name="moqui.basic.StatusItem"/>
</default-field></field>
```

```xml
<!-- bad: every sub-form behind container-dialog on an edit page -->
<container-dialog id="AddItemDialog" button-text="Add Item">
    <form-single name="AddItemForm" transition="addItem">...</form-single>
</container-dialog>
<!-- good: inline form-single above form-list (see screen-ui-patterns.md) -->
<section name="AddItemSection"><widgets>
    <form-single name="AddItemForm" transition="addItem">...</form-single>
</widgets></section>
```

```xml
<!-- bad: reimplement party search in local component -->
<transition name="searchPartyList">...</transition>
<!-- good -->
<transition-include name="searchPartyList"
        location="component://SimpleScreens/template/party/PartyForms.xml"/>
```

- Screens display and transition. Business work goes through
  `<service-call>` in a transition (or a service it calls), not inline
  in widgets. After a form submit that changes data, redirect.
- `form-single` for one record; `form-list` for tables. Both need a
  `transition` for submits.
- Protect the app root with `AppSeedData.xml` (`AT_XML_SCREEN`,
  `inheritAuthz="Y"`). 403 is usually missing seed.
- `no-sub-path="true"` on a `subscreens-item` overrides a parent path
  without adding a URL segment.
- After XML save, reload the browser; check `runtime/log/moqui.log` for
  render errors. Verify under `/qapps/{app}/` and `/qapps2/{app}/` when
  the screen has custom `<render-mode>` text.
- `/qapps` and `/qapps2` share the `/apps` screen tree. AJAX extensions
  differ; qapps2 macros treat the `/qapps` names as compatible fallbacks.
  Generated screens keep writing `qvt` / `qvue` / `qjs`. Do **not** add
  `qvt2` / `qvue2` / `qjs2` unless the markup itself differs.

  | Use | `/qapps` | `/qapps2` |
  |-----|----------|-----------|
  | Vue template (default) | `qvt` | `qvt2` (falls back to `qvt`) |
  | Vue SFC | `qvue` | `qvue2` (falls back to `qvue`) |
  | Plain JS (`define(` / AMD) | `qjs` | `qjs2` (falls back to `qjs`) |
- Keep `menu-title`, labels, form titles, and button text in English.
  Chinese goes in `data/*L10nData.xml`. See [l10n.md](l10n.md).
- In custom `qvue`/`qvt`, do not use native HTML date controls
  (`q-input type="date"`, `type="datetime-local"`, `type="time"`).
  Those follow the browser/OS UI language, not the Moqui user locale
  (Chinese Chrome shows 年/月/日, 清除, 今天 even for English users).
  Use `m-date-time` (`name` required; `type="date"` or `type="date-time"`).
  In form XML use `<date-find>` / `<date-time>`.
- Put `icon` on common action `<submit>`, `<link>`, and
  `container-dialog` / `dynamic-dialog`. Theme fallback matches the
  **localized** button text, so Chinese titles get no icon unless
  `icon` is set. Use Font Awesome classes (`fa fa-*`):

  | English title | `icon` |
  |---------------|--------|
  | Create, Add, New | `fa fa-plus` |
  | Save, Update | `fa fa-save` |
  | Delete, Remove | `fa fa-trash` |
  | Find, Search | `fa fa-search` |
  | Edit | `fa fa-pencil` |
  | Cancel | `fa fa-times` |
  | Upload | `fa fa-upload` |
  | Download | `fa fa-download` |
  | Enable, Complete, Approve | `fa fa-check` |
  | Disable | `fa fa-ban` |
  | Copy | `fa fa-copy` |
  | Refresh | `fa fa-refresh` |
