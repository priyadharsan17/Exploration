# Exploration Plan

A living document tracking what has been explored and what comes next.  
Each entry links to the sub-project folder and notes the key concepts covered or to be covered.

---

## Status Key

| Symbol | Meaning |
|---|---|
| ✅ | Completed |
| 🔜 | Up next (recommended order) |
| 💡 | Planned |
| 🗂 | Category grouping |

---

## 🗂 Layouts

| # | Sub-project | Status | Key Concepts |
|---|---|---|---|
| 1 | [`Layouts/ColumnLayout`](Layouts/ColumnLayout/) | ✅ | `ColumnLayout`, `Layout.*` attached properties, two-window setup |
| 2 | [`Layouts/GridLayout`](Layouts/GridLayout/) | ✅ | `GridLayout`, `columns`/`rows`, `columnSpan`/`rowSpan`, flow, layoutDirection |
| 3 | [`Layouts/IDELayout`](Layouts/IDELayout/) | ✅ | `SplitView`, `StackLayout`, resizable panels, activity bar, tab bar, status bar |

---

## 🗂 Animations

| # | Sub-project | Status | Key Concepts |
|---|---|---|---|
| 4 | [`Animations/NumberAnimation`](Animations/NumberAnimation/) | ✅ | `NumberAnimation`, `Behavior on`, easing curves, `SequentialAnimation`, Python `Signal` → `Behavior` |
| 5 | [`Animations/ListViewTransitions`](Animations/ListViewTransitions/) | ✅ | `ListView` `populate`, `add`, `remove`, `displaced`, `move` transitions |

---

## 🗂 Models — Flat

| # | Sub-project | Status | Key Concepts |
|---|---|---|---|
| 6 | [`Tables/TableExplorer`](Tables/TableExplorer/) | ✅ | `QAbstractTableModel`, `rowCount`/`columnCount`/`data`/`setData`/`flags`, `beginInsertRows`, `@Slot`, `@Property(notify=)`, `TableView`, `HorizontalHeaderView`, reusable QML component |

---

## 🗂 Models — Hierarchical

| # | Sub-project | Status | Key Concepts |
|---|---|---|---|
| 7 | [`Trees/TreeViewExplorer`](Trees/TreeViewExplorer/) | ✅ | `QAbstractItemModel`, `index()`/`parent()` contract, `createIndex` with node pointer, `roleNames()`, `TreeView`, `required property` injection, `depth` indentation, `expandRecursively` |

---

## 🗂 Models — Proxy & Filtering

| # | Sub-project | Status | Key Concepts |
|---|---|---|---|
| 8 | [`Models/SortFilterExplorer`](Models/SortFilterExplorer/) | ✅ | `QSortFilterProxyModel`, `filterAcceptsRow` override, multi-criteria filter (text + category + active flag), `lessThan` role-based sort, `filteredCount`/`totalCount` bindable properties, `mapToSource` for proxy→source row removal |

---

## 🗂 Navigation

| # | Sub-project | Status | Key Concepts |
|---|---|---|---|
| 9  | `Navigation/StackViewExplorer`  | 💡 | `StackView`, `push`/`pop`/`replace`, `StackView.Transition`, page lifecycle (`Component.onCompleted`, `StackView.onActivated`) |
| 10 | `Navigation/DrawerExplorer`     | 💡 | `Drawer`, `SwipeView`, `TabBar`, navigation drawer pattern |

---

## 🗂 Charts

| # | Sub-project | Status | Key Concepts |
|---|---|---|---|
| 11 | `Charts/ChartsExplorer` | 💡 | `QtCharts`, `ChartView`, `LineSeries`, `BarSeries`, `PieSeries`, live data via Python timer, `QXYSeries.append` from Python |

---

## 🗂 Interaction

| # | Sub-project | Status | Key Concepts |
|---|---|---|---|
| 12 | `Interaction/DragDropExplorer` | 💡 | `DragHandler`, `DropArea`, `Drag` attached properties, model reordering on drop (Kanban-style) |
| 13 | `Interaction/CanvasExplorer`   | 💡 | `Canvas`, `Context2D`, drawing paths/shapes/text, `requestPaint`, animation loop |

---

## 🗂 Persistence & Settings

| # | Sub-project | Status | Key Concepts |
|---|---|---|---|
| 14 | `Settings/SettingsExplorer` | 💡 | `QSettings` from Python, `Qt.labs.settings` `Settings` QML type, persist window geometry and user preferences across restarts |

---

## 🗂 Concurrency & Real-time Data

| # | Sub-project | Status | Key Concepts |
|---|---|---|---|
| 15 | `Concurrency/LiveDataExplorer` | 💡 | `QThread` worker, thread-safe signal emission, live-updating `QAbstractListModel`, Python `threading.Thread` vs `QThread` |

---

## Recommended Order

```
✅ 1 → 2 → 3   Layouts
✅ 4 → 5        Animations
✅ 6            Flat model (Table)
✅ 7            Tree model
✅ 8            Proxy model (SortFilter)
💡 9 → 10       Navigation (StackView, Drawer)
💡 11           Charts
💡 12 → 13      Interaction (DragDrop, Canvas)
💡 14           Persistence
💡 15           Concurrency / Real-time
```
