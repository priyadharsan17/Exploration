# Exploration

A hands-on PySide6 + QML learning workspace. Each sub-project is a standalone interactive explorer for a specific Qt Quick concept — run it, tweak the controls, and observe behaviour live.

---

## Repository Structure

```
Exploration/
├── Layouts/
│   ├── GridLayout/               ← GridLayout explorer           (single window)
│   ├── ColumnLayout/             ← ColumnLayout explorer         (two windows)
│   └── IDELayout/                ← IDE multi-panel layout        (single window)
├── Animations/
│   ├── NumberAnimation/          ← Number animation explorer     (two windows)
│   └── ListViewTransitions/      ← ListView transition explorer  (single window)
├── Tables/
│   └── TableExplorer/            ← Table CRUD explorer           (single window)
└── Trees/
    └── TreeViewExplorer/         ← TreeView CRUD explorer        (single window)
```

---

## Prerequisites

```bash
pip install PySide6
```

Python 3.9+ · PySide6 6.x

---

## Projects

### `Layouts/GridLayout` — GridLayout Explorer

> Controls panel and playground live **side by side in one window**.

**Run:**
```bash
cd Layouts/GridLayout
python main.py
```

**What you can explore:**

| Property | Description |
|---|---|
| `columns` / `rows` | Grid dimensions — controls wrapping |
| `columnSpacing` / `rowSpacing` | Gaps between cells |
| `flow` | Fill order: LeftToRight or TopToBottom |
| `layoutDirection` | Mirror the grid: LTR or RTL |
| `Layout.columnSpan` / `rowSpan` | Merge cells across columns/rows |
| `Layout.fillWidth` / `fillHeight` | Expand cells to fill available space |
| `Layout.alignment` | Position within a cell slot |
| `Layout.preferredWidth/Height` | Size hint to the layout engine |
| `Layout.minimumWidth/Height` | Hard lower size constraint |
| `Layout.maximumWidth/Height` | Hard upper size constraint |

---

### `Layouts/ColumnLayout` — ColumnLayout Explorer

> Controls open in a **separate Properties window** so the playground fills the entire screen — ideal for observing full-window stretch and fill behaviour.

**Run:**
```bash
cd Layouts/ColumnLayout
python main.py
```

Two windows open automatically side by side. The Properties window stays on top.

**What you can explore:**

| Property | Description |
|---|---|
| `spacing` | Uniform gap between all cells |
| `layoutDirection` | TopToBottom (default) or BottomToTop (reversed stack) |
| `Layout.fillWidth` / `fillHeight` | Expand cells horizontally / share vertical space |
| `Layout.alignment` | Horizontal and vertical alignment within the column |
| `Layout.preferredWidth/Height` | Size hint to the layout engine |
| `Layout.minimumWidth/Height` | Hard lower size constraint |
| `Layout.maximumWidth/Height` | Hard upper size constraint |
| `Layout.topMargin` … `rightMargin` | Per-cell margins (on the target cell) |

---

### `Animations/NumberAnimation` — Number Animation Explorer

> Controls open in a **separate Properties window**. The playground fills the full screen showing four live demos plus an easing curve showcase strip.

**Run:**
```bash
cd Animations/NumberAnimation
python main.py
```

**Four demo tiles + easing showcase:**

| Tile | Technique | What you see |
|---|---|---|
| A | `Behavior on property` | Box animates `x`, `opacity`, `rotation` on every change |
| B | Standalone `NumberAnimation` | Ball controlled via Play / Pause / Stop / Restart |
| C | State + `Transition` | Card scale/color/rotation driven by press states |
| D | Python `Signal` → `Behavior` | Progress bar animates smoothly from Python value changes |
| Strip | Easing showcase | 6 dots launched simultaneously, each with a different easing curve |

**Controls panel covers:**

| Section | Controls |
|---|---|
| 1 · Common Settings | Duration (50–5000 ms), Easing Type (22 curves), Loops (0 = ∞) |
| 2 · Demo A | Toggle X, Toggle Opacity, Spin +90° |
| 3 · Demo B | Play / Pause / Stop / Restart buttons |
| 4 · Demo D | Randomize (Python signal) + value slider |
| 5 · Easing Showcase | Showcase duration + Launch/Reset all dots |

---

- **Hover any cell** in the playground for a tooltip showing its live pixel position and size.
- Each explorer has a **Reset All to Defaults** button to restore the initial state.
- The **live status box** at the bottom of every Properties panel reflects the current property values in real time.

---

### `Animations/ListViewTransitions` — ListView Transition Explorer

> Single window: ListView on the left, controls + legend on the right. Status bar at the bottom shows exactly which transition fired and why after every action.

**Run:**
```bash
cd Animations/ListViewTransitions
python main.py
```

**Five transitions demonstrated:**

| Transition | Visual effect | Triggered by |
|---|---|---|
| `populate` | Slide in from left + fade | Model assigned (or reassigned) to the view |
| `add` | Scale up from 0 + fade in | `ListModel.insert()` / `append()` |
| `remove` | Fly off to the right + fade out | `ListModel.remove()` / `clear()` |
| `displaced` | Spring to new slot (`OutBack`) | Items that *shift* due to another item's add/remove/move |
| `move` | Smooth slide (`InOutQuad`) | `ListModel.move()` (explicit reorder) |

**Controls:**

| Section | Buttons |
|---|---|
| Add Items | + Top, + Bottom, + Random |
| Remove Items | × Selected, × Top, × Bottom |
| Reorder | ↑ Up, ↓ Down, Shuffle (Fisher-Yates) |
| Reset | ↺ Replay Populate (re-triggers `populate`), ⌫ Clear All |

Click any list item to select it; click again to deselect. The ↑ / ↓ / × Selected buttons operate on the selected item.
- Resize the playground window while controls are applied to see how constraints, fill, and alignment respond dynamically.

---

### `Tables/TableExplorer` — Table Explorer

> Single window: live editable table on the left, controls panel on the right.  Covers `QAbstractTableModel`, cell CRUD, spreadsheet-style cell references, data extraction, and building a **reusable QML table component**.

**Run:**
```bash
cd Tables/TableExplorer
python main.py
```

Starts with a seeded 6 × 5 employee table (Name · Department · Level · Salary · Since).

**Four files:**

| File | Role |
|---|---|
| `table_backend.py` | `QAbstractTableModel` subclass — all data and CRUD logic |
| `main.py` | Entry point — seeds data, exposes model as `tblModel` context property |
| `SmartTable.qml` | Reusable component — headers, selection, inline editing |
| `TableExplorer.qml` | Explorer window — two-panel layout + controls |

**Controls panel:**

| Section | Operations |
|---|---|
| Row Operations | Add Row, Remove Last Row, Remove Selected Row |
| Column Operations | Add Col, Remove Last Col, Rename column header |
| Cell Reference | Get / Set / Jump by `A1`-style reference; `→ Ref Input` from selection |
| Data Extraction | Get Row N, Get Col N, Export as CSV (output panel) |
| Table Settings | Editable toggle, Clear All Cells, Reset 6 × 5 |

**Key concepts demonstrated:**

| Concept | Where |
|---|---|
| `QAbstractTableModel` with all 5 required overrides | `table_backend.py` |
| `@Slot` methods callable from QML | Every CRUD method |
| `@Property(notify=signal)` for live QML bindings | `rows`, `cols` properties |
| `beginInsertRows` / `endInsertRows` (and column equivalents) | `addRow`, `addColumn` |
| `dataChanged`, `headerDataChanged`, `beginResetModel` signals | `setData`, `setColumnHeader`, `resetTable` |
| `TableView` delegate with `required property string display` | `SmartTable.qml` |
| `HorizontalHeaderView` + `VerticalHeaderView` with `syncView` | `SmartTable.qml` |
| Reusable QML component (`required property`, signals, public method) | `SmartTable.qml` |
| Avoiding binding loops with `Qt.callLater` | Inline edit focus in `SmartTable.qml` |

---

### `Layouts/IDELayout` — IDE Multi-Panel Layout Explorer

> Single window mimicking a real IDE: toolbar, activity bar, resizable side panel, tabbed editor, resizable bottom panel, and status bar — all panels draggable to resize with the mouse.

**Run:**
```bash
cd Layouts/IDELayout
python main.py
```

Opens a 1280 × 800 window (resizable, minimum 920 × 580).

**Layout zones:**

| Zone | What it is |
|---|---|
| Top toolbar | Menu bar simulation (File / Edit / View / Run / Terminal / Help) + search bar + Run / Debug buttons |
| Activity bar | Narrow icon strip (left edge) — click to switch the side panel; click the active icon again to collapse/expand it |
| Side panel | Resizable — shows one of four views depending on the active activity |
| Main editor | Tabbed code viewer (three files); active tab highlighted with a top accent bar and an unsaved-change dot |
| Bottom panel | Resizable — tabbed: Console (interactive input), Output, Problems, Terminal |
| Status bar | Branch name, error/warning counts, language, encoding, cursor position |

**Side panel views (activity bar):**

| Icon | View | Content |
|---|---|---|
| ≡ | Explorer | File tree with depth-indented folders and colour-coded file names |
| ⌕ | Search | Simulated search results with file name, line number, and matched text |
| ▦ | Table | Four-column data grid (Name · Type · Size · Modified) |
| 〰 | Timeline | Chronological event log with coloured dots and a vertical connector line |

**Key QML concepts demonstrated:**

| Concept | Where |
|---|---|
| `SplitView` (horizontal) | `mainSplit` — side panel vs editor+console |
| `SplitView` (vertical) | `rightSplit` — editor area vs bottom panel |
| `SplitView.preferredWidth/Height` | Default sizes for side panel and bottom panel |
| `SplitView.minimumWidth/Height` | Prevents panels from collapsing below a usable size |
| `SplitView.maximumWidth` | Caps side panel at 520 px |
| `SplitView.fillWidth` / `fillHeight` | Marks the item that absorbs remaining space |
| Custom `handle` delegate | `SplitHandle.hovered` / `SplitHandle.pressed` drive a colour `Behavior` |
| Panel collapse via `visible: false` | Activity bar icon toggle hides the side panel; `SplitView` fills the gap |
| `StackLayout` + tab bar | Switches content for both the side panel and the bottom panel |
| `TextArea` inside `ScrollView` | Horizontally scrollable read-only code viewer |
| `ListModel` + interactive `TextInput` | Console panel appends typed commands to the log |

---

### `Trees/TreeViewExplorer` — TreeView Explorer

> Single window: interactive expandable tree on the left, controls panel on the right.  Covers `QAbstractItemModel`, the `index()` / `parent()` contract, custom role names, and full CRUD on a live tree.

**Run:**
```bash
cd Trees/TreeViewExplorer
python main.py
```

Starts with a seeded 5-category technology stack tree (Frontend · Backend · Database · DevOps · Mobile), each with four leaf items.

**Three files:**

| File | Role |
|---|---|
| `tree_backend.py` | `QAbstractItemModel` subclass — `TreeNode` + `TreeModel` with full CRUD |
| `main.py` | Entry point — seeds data, exposes model as `treeModel` context property |
| `TreeViewExplorer.qml` | Explorer window — tree view + controls panel + status bar |

**Controls panel:**

| Section | Operations |
|---|---|
| Selected Node | Shows current node name and stable id |
| Add Node | Add child under selected node; add new top-level node |
| Rename | Rename the selected node in-place |
| Remove | Delete the selected node and all its descendants |
| Node Info | Get full path · child count · leaf check |
| View | Expand All (`expandRecursively()`) · Collapse All (`collapseRecursively()`) |

**Key concepts demonstrated:**

| Concept | Where |
|---|---|
| `QAbstractItemModel` with all 5 required overrides | `tree_backend.py` |
| `index()` / `parent()` contract using `createIndex` with node pointer | `tree_backend.py` |
| `roleNames()` mapping custom roles to QML-accessible names | `tree_backend.py` |
| `beginInsertRows` / `endInsertRows` and remove equivalents | `addNode`, `removeNode` |
| `required property` injection from model roles and `TreeView` | Delegate block |
| `depth` for dynamic left-margin indentation | `anchors.leftMargin: depth * 22 + 10` |
| `toggleExpanded(row)`, `expandRecursively()`, `collapseRecursively()` | Controls panel |
