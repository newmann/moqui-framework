# Screen UI patterns

Read this **before** generating or editing `screen/**/*.xml`. Base mount,
transition, authz, and l10n rules stay in [screen.md](screen.md).

Search SimpleScreens with `path` = `runtime/component/SimpleScreens` (not
workspace root). Do not edit catalog components; reference them read-only.

## Preconditions

- Mantle-based apps: add `<depends-on name="SimpleScreens"/>` in
  `component.xml` when using `component://SimpleScreens/...` includes.
- Prefer `mantle-udm` view entities (`*Detail`, `*And*`) for display and
  dropdown labels.

---

## 1. FK / status / enum: never show raw IDs

Any field ending in `Id` or `EnumId`, plus `statusId`, that references an
entity or enumeration must **not** use bare `<display/>` or `<text-line/>`
for user-facing values. Hidden PK fields are the exception.

### Widget decision table

| Field pattern | Read-only | Editable |
|---------------|-----------|----------|
| `*PartyId` | `<display-entity entity-name="mantle.party.PartyDetail" text="PartyNameTemplate"/>` | `<drop-down allow-empty="true"><dynamic-options transition="searchPartyList" server-search="true" min-length="2"/></drop-down>` plus `transition-include` from `PartyForms.xml` |
| `statusId` (display only) | `<display-entity entity-name="moqui.basic.StatusItem"/>` | — |
| `statusId` (workflow) | `section-include` from `StatusWidgets.xml` | same; do not use a text field |
| `*EnumId` | `<display-entity entity-name="moqui.basic.Enumeration"/>` | `widget-template-include` → `BasicWidgetTemplates.xml#enumDropDown` with `enumTypeId` |
| `productId` | `<display-entity entity-name="mantle.product.Product" text="ProductNameTemplate"/>` | `entity-options` or `dynamic-options` + `ProductTransitions.xml` |
| `facilityId` | `<display-entity entity-name="mantle.facility.Facility" text="FacilityNameTemplate"/>` | `entity-options` or `FacilityTransitions.xml` |
| `glAccountId` | `<display-entity entity-name="mantle.ledger.account.GlAccount" text="${accountCode}: ${accountName}"/>` | `dynamic-options` + `AccountTransitions.xml` |
| `workEffortId` | `<display-entity entity-name="mantle.work.effort.WorkEffort" text="WorkEffortNameTemplate"/>` | `entity-options` or `WorkTransitions.xml` |
| `assetId` | Label with pseudoId, serialNumber, productName — not bare assetId | `<drop-down>` / `dynamic-options` with readable `text` |

### Good / bad examples

```xml
<!-- bad: user sees internal statusId -->
<field name="statusId"><default-field><display/></default-field></field>

<!-- good -->
<field name="statusId"><default-field>
    <display-entity entity-name="moqui.basic.StatusItem"/>
</default-field></field>
```

```xml
<!-- bad: assetId in list -->
<field name="assetId"><default-field><display/></default-field></field>

<!-- good: meaningful label from list row or joined entity -->
<field name="assetId"><default-field title="Asset">
    <display text="${pseudoId?:assetId} ${serialNumber?:''}"/>
</default-field></field>
```

```xml
<!-- bad: enum as raw id -->
<field name="requestTypeEnumId"><default-field><text-line/></default-field></field>

<!-- good -->
<field name="requestTypeEnumId"><default-field title="Type">
    <widget-template-include location="component://webroot/template/screen/BasicWidgetTemplates.xml#enumDropDown">
        <set field="enumTypeId" value="RequestType"/>
    </widget-template-include>
</default-field></field>
```

```xml
<!-- good: party picker with shared transition -->
<transition-include name="searchPartyList"
        location="component://SimpleScreens/template/party/PartyForms.xml"/>
<!-- in form -->
<field name="assignToPartyId"><default-field title="Assignee">
    <drop-down allow-empty="true">
        <dynamic-options transition="searchPartyList" server-search="true" min-length="2"/>
    </drop-down>
</default-field></field>
```

### Pre-submit checklist (FK fields)

- [ ] Every FK column in `form-list` uses `display-entity`, formatted
      `display`, or a name template — not raw id.
- [ ] Every visible `*Id` / `*EnumId` / `statusId` in `form-single` is
      mapped (hidden PK excluded).
- [ ] Checked mantle-udm for a `*Detail` or `*And*` view before picking
      `entity-name` or dropdown `entity-find`.

---

## 2. Browse lists: entity-find inside form-list

A browse, find, or queue screen whose rows are columns of one entity uses
`form-list` built-in find. Do not add a sibling `form-single` Find form,
and do not preload the same query with `list#*` in `pre-actions`.

Reference: `runtime/component/SimpleScreens/screen/SimpleScreens/Survey/FindSurvey.xml`.

Keep a `list#*` service when REST or another caller needs it. The screen
does not call it.

Still preload through a service when a column is not an entity field, or
the query is not a single-table condition (a graph, an assembled DTO).

```xml
<form-list name="SurveyList" list="surveyList" skip-form="true" header-dialog="true"  show-page-size="true">
    <entity-find entity-name="moqui.screen.form.DbForm" list="surveyList">
        <search-form-inputs default-order-by="description"/>
    </entity-find>
    <field name="description">
        <header-field title="Description" show-order-by="case-insensitive">
            <text-find size="25" hide-options="true"/>
        </header-field>
        <default-field><display/></default-field>
    </field>
    <field name="submitButton"><header-field title="Find"><submit/></header-field></field>
</form-list>
```

- `header-dialog="true"` and `skip-form="true"` and `show-page-size="true"`.
- Filter columns use `header-field` (`drop-down` or `text-find`). Sort-only
  columns use an empty `<header-field show-order-by="true"/>`.
- The Find submit is header-only. `form-list-column` lists the data
  columns and leaves that button out of the table.
- `select-field` omits large fields such as `text-very-long` columns.

Row detail that a service must compute opens from the row with
`dynamic-dialog`. See
`runtime/component/SimpleScreens/screen/SimpleScreens/Task/EditTimeEntries.xml`.
The transition loads a subscreen in the directory of the same name, with
`default-menu-include="false"`.

That subscreen is a new screen request. Add it to the same ArtifactGroup
as the list screen, `inheritAuthz="Y"`.

Do not open the detail as a section under the list via `?id=`.

A `service-call` inside `<actions>` must set `in-map="context"` or an
explicit map. qvt does not render `<hidden>` as an input; the value lives
in `fields-initial`. Without `in-map`, required parameters arrive empty.
A `service-call` that is a direct child of `<transition>` (not wrapped in
`<actions>`) gets `in-map="true"` automatically.

### Pre-submit checklist (browse lists)

- [ ] Single-entity list uses `entity-find` and `search-form-inputs` inside
      `form-list`, not a Find `form-single` plus `pre-actions`.
- [ ] Large text columns are omitted with `select-field`.
- [ ] Row detail that needs a service is a `dynamic-dialog` subscreen with
      its own screen authz.
- [ ] `service-call` inside `<actions>` sets `in-map`.

---

## 3. CRUD lists: dialog create, in-list or dedicated edit

Browse, find, and queue lists that only display rows are section 2. This
section is a screen that creates or edits those rows.

Keep create and edit off the page under the `form-list`. A `form-single`
after the list, including one revealed by selecting a row (`?id=`,
`?objectName=`), is the wrong layout. Section 2 already forbids opening
row detail that way.

### Create

Put a `container-dialog` in widget order before the `form-list`. The
button is the only create UI on the page. A `box-toolbar` on a
`container-box` that wraps the list also places the button above the list.

When the new record is edited on a dedicated screen, the create
transition's `default-response` is `../EditXxx` (`FindSurvey.xml`). When
the list itself is the editor, stay on `.` (`FindProductStoreEmails.xml`).

References:

- `runtime/component/SimpleScreens/screen/SimpleScreens/Survey/FindSurvey.xml`
  — dialog in `box-toolbar`; create goes to `../EditSurvey`
- `runtime/component/SimpleScreens/screen/SimpleScreens/Request/FindRequest.xml`
  — dialog immediately before the list
- `runtime/component/SimpleScreens/screen/SimpleScreens/ProductStore/FindProductStoreEmails.xml`
  — dialog, then an editable list
- `runtime/component/SimpleScreens/screen/SimpleScreens/Survey/Fields.xml`
  — `NewDbFormFieldDialog` before `DbFormFieldList`

```xml
<container-dialog id="NewStoreEmailDialog" button-text="New Store Email">
    <form-single name="NewStoreEmailForm" transition="createStoreEmail">
        <field name="productStoreId"><default-field><hidden/></default-field></field>
        <field name="submitButton"><default-field title="Create">
            <submit icon="fa fa-plus"/></default-field></field>
    </form-single>
</container-dialog>
<form-list name="StoreEmailsForm" list="storeEmails" transition="updateStoreEmail">
    <!-- editable columns; see Simple edit -->
</form-list>
```

### Simple edit

A few scalar columns stay on the `form-list`. Set `transition` to the
update service. Put input widgets in `default-field` (`text-line`,
`drop-down`, `date-time`) and a per-row `<submit>`. Leave `skip-form`
unset. Each row submits one record, the same model as `form-single`,
with no second form on the page.

References: `StoreEmailsForm` in `FindProductStoreEmails.xml`;
`DbFormFieldList` in `Survey/Fields.xml`.

```xml
<form-list name="StoreEmailsForm" list="storeEmails" header-dialog="true"
        transition="updateStoreEmail">
    <field name="productStoreId"><default-field><hidden/></default-field></field>
    <field name="headerImagePath"><default-field><text-line size="30"/></default-field></field>
    <field name="submitButton" align="right"><default-field title="Update">
        <submit icon="fa fa-save"/></default-field></field>
</form-list>
```

Section 2 browse lists stay read-only (`skip-form="true"`). An editable
list is this section.

### Complex edit

Many fields, child lists, or status actions belong on a sibling
`Edit*.xml`. The row links there. The transition returns `../EditXxx`
and passes the primary key.

When that edit screen owns the menu, the find screen sets
`default-menu-include="false"` (`FindSurvey.xml`, `FindRequest.xml`).
When the list is the menu entry, the list screen keeps
`default-menu-title` (`FindProductStoreEmails.xml`).

References: `FindSurvey.xml` → `../EditSurvey`; `FindRequest.xml` →
`runtime/component/SimpleScreens/screen/SimpleScreens/Request/EditRequest.xml`.

```xml
<transition name="editRequest"><default-response url="../EditRequest"/></transition>
<!-- in the list -->
<field name="requestId"><default-field>
    <link url="editRequest" text="${requestId}" link-type="anchor"/>
</default-field></field>
```

On `Edit*.xml`, lay the main record out on the page: one `form-single`
inside `container-box`, with `field-layout` / `field-row`. Several
blocks use several `container-box` sections on the same page
(`container-row` when a status sidebar sits beside the form). See
`EditRequest.xml`.

Child creates on that screen use `container-dialog` before the child
`form-list` (`NewDbFormFieldDialog` in `Fields.xml`). Child rows with a
few scalar fields edit on that `form-list`. Status change, add comment,
and confirm stay `container-dialog` or `section-include` of
`StatusWidgets.xml`.

```xml
<widgets>
    <container-row>
        <row-col md="7">
            <container-box>
                <box-header title="Header"/>
                <box-body>
                    <form-single name="EditMain" transition="updateMain" map="mainRecord">
                        <field-layout>
                            <field-row><field-ref name="nameField"/><field-ref name="dateField"/></field-row>
                            <fields-not-referenced/>
                        </field-layout>
                    </form-single>
                </box-body>
            </container-box>

            <container-dialog id="AddLineDialog" button-text="Add Line">
                <form-single name="AddLineForm" transition="addLine">
                    <field name="submitButton"><default-field title="Add">
                        <submit icon="fa fa-plus"/></default-field></field>
                </form-single>
            </container-dialog>
            <form-list name="LineList" list="lineList" transition="updateLine">
                <field name="lineSeq"><default-field><text-line size="5"/></default-field></field>
                <field name="submitButton"><default-field title="Update">
                    <submit icon="fa fa-save"/></default-field></field>
            </form-list>
        </row-col>
        <row-col md="5">
            <section-include name="StatusChangeSection"
                    location="component://SimpleScreens/template/basic/StatusWidgets.xml"/>
            <section-include name="StatusHistorySection"
                    location="component://SimpleScreens/template/basic/StatusWidgets.xml"/>
        </row-col>
    </container-row>
</widgets>
```

### Decision table

| Scenario | Use | Avoid |
|----------|-----|-------|
| Create on a list screen | `container-dialog` before the `form-list` (or in `box-toolbar`) | `form-single` under the list |
| Edit, few scalar fields | Editable `form-list`: `transition`, input widgets, per-row submit; `skip-form` unset | A second `form-single` under the list, or a dialog per row |
| Edit, many fields, children, or status | Sibling `Edit*.xml`, row `link` to `../EditXxx` | `form-single` under the list opened by `?id=` |
| Main record on `Edit*.xml` | Inline `form-single` in `container-box` | One dialog per field group, or the whole record behind a dialog |
| Child create on `Edit*.xml` | `container-dialog` before the child `form-list` | `form-single` under the child list |
| Status change, add comment, confirm | `container-dialog` or `section-include` StatusWidgets | — |

### Pre-submit checklist (CRUD)

- [ ] Create is a `container-dialog` before the `form-list`.
- [ ] No create or edit `form-single` follows the `form-list`.
- [ ] Simple edits are columns on the `form-list` with a row submit and
      `skip-form` unset.
- [ ] Complex edits are a separate `Edit*.xml` linked from the row.
- [ ] The main form on `Edit*.xml` is an inline `form-single` in
      `container-box`.
- [ ] Child creates on an edit screen are a `container-dialog` before
      that child list.

---

## 4. Reuse SimpleScreens templates

Do not copy transitions, sections, or whole forms from SimpleScreens into
local components. Include or extend them.

### Template index

| Location | Purpose |
|----------|---------|
| `component://SimpleScreens/template/party/PartyForms.xml` | `searchPartyList`, `getPartyList`; extendable party forms |
| `component://SimpleScreens/template/party/PartyWidgetTemplates.xml` | Party widget fragments |
| `component://SimpleScreens/template/basic/StatusWidgets.xml` | `StatusChangeSection`, `StatusHistorySection` |
| `component://SimpleScreens/template/account/AccountTransitions.xml` | GL account paginated search |
| `component://SimpleScreens/template/account/LedgerCharts.xml` | Ledger chart widgets |
| `component://SimpleScreens/template/facility/FacilityTransitions.xml` | Facility search |
| `component://SimpleScreens/template/product/ProductTransitions.xml` | Product search |
| `component://SimpleScreens/template/request/RequestTransitions.xml` | Request transitions |
| `component://SimpleScreens/template/shipment/ShipmentTransitions.xml` | Shipment transitions |
| `component://SimpleScreens/template/work/WorkTransitions.xml` | WorkEffort search |
| `component://SimpleScreens/screen/SimpleScreens/**/Edit*.xml` | `form-single extends`, `section-include` sources |
| `component://webroot/template/screen/BasicWidgetTemplates.xml` | `#enumDropDown`, `#statusDropDown`, `#enumGroupDropDown` |

### Reuse priority

1. **`transition-include` / `section-include` / `include-screen`** — zero copy.
2. **`form-single extends="component://SimpleScreens/...#FormName"`** — override
   only the fields that differ.
3. **New local screen** — only when SimpleScreens has no matching domain;
   still follow sections 1–3 above.

### Examples

```xml
<!-- transitions -->
<transition-include name="searchPartyList"
        location="component://SimpleScreens/template/party/PartyForms.xml"/>

<!-- status sidebar (set statusId, changedEntityName, pkPrimaryValue in actions) -->
<section-include name="StatusChangeSection"
        location="component://SimpleScreens/template/basic/StatusWidgets.xml"/>

<!-- extend a catalog form -->
<form-single name="EditRequest" transition="updateRequest" map="request"
        extends="component://SimpleScreens/screen/SimpleScreens/Request/EditRequest.xml#EditRequest">
    <field name="facilityId"><default-field><ignored/></default-field></field>
</form-single>
```

### Agent workflow

1. Identify the domain (party, request, product, facility, …).
2. Search `runtime/component/SimpleScreens` for `Edit*.xml` and
   `template/{domain}/`.
3. If a match exists: include, extend, or copy the widget pattern — do not
   reimplement search transitions.
4. Apply FK widget, browse-list, and CRUD list rules from sections 1–3.

### Pre-submit checklist (reuse)

- [ ] Searched SimpleScreens before writing new transitions or forms.
- [ ] `depends-on SimpleScreens` present when referencing SimpleScreens paths.
- [ ] No duplicated Party/Status/Enum transition code in local component.

---

## Verify

1. Reload browser; check `runtime/log/moqui.log` for render errors.
2. Open `/qapps/{app}/` — FK columns show names, not internal ids.
3. List screen: Create is a dialog button above the list. Simple edits
   submit from the row. Complex edits open `Edit*.xml`, whose main form
   is on the page.
4. Status sidebar works when `statusId`, `changedEntityName`, and PK are set
   in `<actions>`.
