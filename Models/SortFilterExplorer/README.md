# SortFilter Explorer

> Single window: a live-filtered, live-sorted list of items on the left, controls panel on the right.  
> Covers **QSortFilterProxyModel**, multi-criteria `filterAcceptsRow`, role-based `lessThan`, bindable proxy properties, and proxy-to-source row mapping.

---

## Run

```bash
cd Models/SortFilterExplorer
python main.py
```

Starts with 23 seeded tech-ecosystem items across five categories (Frontend · Backend · Database · DevOps · Mobile), sorted by name ascending.

---

## File Overview

| File | Role |
|---|---|
| `backend.py` | `ItemModel` (source) + `FilterProxy` (proxy) — all filter/sort logic and CRUD |
| `main.py` | App entry point — seeds sample data, exposes proxy as `proxyModel` context property |
| `SortFilterExplorer.qml` | Main explorer window — card list + controls panel + stats header + status bar |

---

## Backend — `backend.py`

### `ItemModel` (source) — `QAbstractListModel`

A flat list model with four roles per item:

| Role constant | QML name | Type | Description |
|---|---|---|---|
| `NAME_ROLE` | `itemName` | `str` | Display name |
| `CATEGORY_ROLE` | `category` | `str` | Grouping label (Frontend · Backend · Database · DevOps · Mobile) |
| `SCORE_ROLE` | `score` | `int` | Popularity score 0–100 |
| `ACTIVE_ROLE` | `isActive` | `bool` | Actively maintained flag |

> Role name `isActive` (not `active`) is intentional — `active` is a reserved QML property on `Item` that controls mouse event propagation.

### `FilterProxy` — `QSortFilterProxyModel`

`FilterProxy` sits between `ItemModel` and the QML `ListView`.  The view always binds to the proxy; it never touches the source model directly.

```
ItemModel  →  FilterProxy  →  ListView
(source)       (proxy)         (QML)
```

#### `filterAcceptsRow` override

Called by Qt for every source row whenever the filter changes.  Returns `True` only if **all three** active criteria pass:

| Criterion | State | Check |
|---|---|---|
| Text search | `self._search` | `search.lower() in name.lower()` |
| Category | `self._category` | exact string match; `""` skips this check |
| Active only | `self._active_only` | `item["active"] must be True` |

Triggered by calling `self.invalidateFilter()` — Qt re-runs `filterAcceptsRow` for every source row and updates the proxy row set.

#### `lessThan` override

Called by Qt during sorting to compare two source model indices.  Uses `self._sort_role` to decide which field to compare:

| `_sort_role` | Field | Comparison |
|---|---|---|
| `NAME_ROLE` | `itemName` | `str.lower()` — case-insensitive |
| `SCORE_ROLE` | `score` | integer comparison |
| `CATEGORY_ROLE` | `category` | `str.lower()` — case-insensitive |

Triggered by calling `self.sort(0, order)`.

#### Bindable QML properties

| Property | Type | Notify signal | Description |
|---|---|---|---|
| `filteredCount` | `int` | `countChanged` | Rows currently visible through the proxy |
| `totalCount` | `int` | `countChanged` | Rows in the source model |

`countChanged` is connected to `rowsInserted`, `rowsRemoved`, and `modelReset` on the proxy so QML bindings update automatically after any filter change or CRUD operation.

#### Slots callable from QML

| Slot | Signature | Effect |
|---|---|---|
| `setSearchText` | `(text: str)` | Update text criterion → `invalidateFilter()` |
| `setCategoryFilter` | `(category: str)` | Update category criterion; `""` = show all → `invalidateFilter()` |
| `setActiveOnly` | `(value: bool)` | Toggle active-only criterion → `invalidateFilter()` |
| `setSortField` | `(field: int)` | `0`=Name `1`=Score `2`=Category → `sort(0, order)` |
| `setSortAscending` | `(asc: bool)` | Toggle sort direction → `sort(0, order)` |
| `addItem` | `(name, category, score, active)` | Delegates to `source.append()` |
| `removeProxyRow` | `(proxy_row: int) → bool` | Maps proxy row to source row via `mapToSource`, then deletes from source |

#### Proxy → Source row mapping

Removing an item requires the **source** row, not the proxy row.  The proxy row changes every time the filter or sort changes.

```python
src_idx = self.mapToSource(self.index(proxy_row, 0))
src.remove_at(src_idx.row())
```

`mapToSource` translates a proxy `QModelIndex` → source `QModelIndex`.  The reverse (`mapFromSource`) is used when you know the source row and need the visual proxy row.

---

## QML — `SortFilterExplorer.qml`

### Layout

```
┌────────────────────────────────────────────┬──────────────────────┐
│  Tech Ecosystem          Showing 18 of 23  │  Controls (scroll)   │
├────────────────────────────────────────────┤                      │
│  [BACKEND]                       ● Active  │  Search              │
│  Django                              88    │  ─────────           │
│  ████████████████████████████░░░░░░        │  Category (pills)    │
├────────────────────────────────────────────┤  ─────────           │
│  [DEVOPS]                       ○ Inactive │  Status filter       │
│  Jenkins                            55     │  ─────────           │
│  ████████████████░░░░░░░░░░░░░░░░░░        │  Sort by             │
│  ...                                       │  ─────────           │
│                                            │  Add item            │
│                                            │  ─────────           │
│                                            │  Remove selected     │
├────────────────────────────────────────────┴──────────────────────┤
│  Status bar                                                        │
└────────────────────────────────────────────────────────────────────┘
```

### Card delegate required properties

| Property | Source | Description |
|---|---|---|
| `index` | ListView (built-in) | Proxy row — stored in `root.selectedRow` on click |
| `itemName` | Model (`NAME_ROLE`) | Display name |
| `category` | Model (`CATEGORY_ROLE`) | Category string — drives badge color |
| `score` | Model (`SCORE_ROLE`) | 0–100 — drives score bar width and color |
| `isActive` | Model (`ACTIVE_ROLE`) | Controls `opacity: 0.55` dimming on inactive cards |

### Controls panel

| Section | Operations |
|---|---|
| Search | Live substring filter on name via `onTextChanged` → `setSearchText` |
| Category | Pill buttons (All + 5 categories); active button highlighted with category color |
| Status Filter | Checkable toggle button → `setActiveOnly` |
| Sort by | Three-button selector (Name / Score / Category) + ascending/descending toggle |
| Add Item | Name field · Score field (0–100 validated) · category picker · active toggle → `addItem` |
| Remove Selected | Deletes selected proxy row via `removeProxyRow(selectedRow)` |

### Key QML concepts demonstrated

| Concept | Where |
|---|---|
| `ListView` bound to `QSortFilterProxyModel` | `listView.model: proxyModel` |
| `proxyModel.filteredCount` / `totalCount` auto-updating in header | `@Property(notify=countChanged)` |
| `Repeater` for category pill buttons and category picker | Filter + Add Item sections |
| `Button { checkable: true }` for toggle controls | Active-only, sort direction, add-active |
| `validator: IntValidator` on score input | Add Item score field |
| `ScrollView` wrapping controls `ColumnLayout` | Right panel overflow handling |
| Category color derived from string via JS function `catColor(cat)` | Badge, pills, score bar |
