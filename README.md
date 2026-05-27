# Exploration

A hands-on PySide6 + QML learning workspace. Each sub-project is a standalone interactive explorer for a specific Qt Quick concept — run it, tweak the controls, and observe behaviour live.

---

## Repository Structure

```
Exploration/
├── Layouts/
│   ├── GridLayout/               ← GridLayout explorer           (single window)
│   └── ColumnLayout/             ← ColumnLayout explorer         (two windows)
├── Animations/
│   ├── NumberAnimation/          ← Number animation explorer     (two windows)
│   └── ListViewTransitions/      ← ListView transition explorer  (single window)
└── Tables/
    └── TableExplorer/            ← Table CRUD explorer           (single window)
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
