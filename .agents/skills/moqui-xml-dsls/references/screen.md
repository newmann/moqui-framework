# Screen and form XML

XSD: `framework/xsd/xml-screen-3.xsd` (forms in `xml-form-3.xsd`).
Screens hot-reload; **`MoquiConf.xml` mount does not** — restart.

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
