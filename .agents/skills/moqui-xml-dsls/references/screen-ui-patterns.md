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

## 2. Layout: inline form-single on edit pages

Detail and edit screens should **lay out forms on one page** using
`container-row`, `container-box`, and `field-layout` / `field-row`.
Reserve `container-dialog` for infrequent or confirm actions.

Reference: `runtime/component/SimpleScreens/screen/SimpleScreens/Request/EditRequest.xml`.

### Layout decision table

| Scenario | Use | Avoid |
|----------|-----|-------|
| Edit main record | One `form-single` inside `container-box` | One dialog per field group |
| Add line item on edit page (≤5 fields) | Inline `form-single` in a `section` above `form-list` | `container-dialog id="AddXxxDialog"` |
| Find page “Create new” | `container-dialog` is fine | — |
| Status change, add comment, confirm | `container-dialog` or `section-include` StatusWidgets | — |
| Multiple edit blocks | Several `container-box` sections on same page | Each block behind its own dialog |

### Good layout skeleton

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

            <section name="AddLineSection" condition="editable">
                <widgets>
                    <form-single name="AddLineForm" transition="addLine">
                        <!-- inline; no container-dialog wrapper -->
                        <field name="submitButton"><default-field title="Add">
                            <submit icon="fa fa-plus"/></default-field></field>
                    </form-single>
                </widgets>
            </section>

            <form-list name="LineList" list="lineList" skip-form="true">
                <!-- FK columns use display-entity, not raw display -->
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

### Pre-submit checklist (layout)

- [ ] Main edit form is inline, not behind a dialog.
- [ ] Add-line forms with few fields are inline above the list.
- [ ] `container-dialog` count is minimal; each has a clear infrequent use.
- [ ] Related blocks use `container-box` or `field-row`, not nested dialogs.

---

## 3. Reuse SimpleScreens templates

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
   still follow sections 1 and 2 above.

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
4. Apply FK widget table and layout rules from sections 1–2.

### Pre-submit checklist (reuse)

- [ ] Searched SimpleScreens before writing new transitions or forms.
- [ ] `depends-on SimpleScreens` present when referencing SimpleScreens paths.
- [ ] No duplicated Party/Status/Enum transition code in local component.

---

## Verify

1. Reload browser; check `runtime/log/moqui.log` for render errors.
2. Open `/qapps/{app}/` — FK columns show names, not internal ids.
3. Edit page: main forms and add-line forms visible without extra clicks.
4. Status sidebar works when `statusId`, `changedEntityName`, and PK are set
   in `<actions>`.
