# GridLayout Explorer

An interactive PySide6 + QML application for learning and experimenting with `GridLayout` properties in real time.

---

## Files

| File | Purpose |
|---|---|
| `main.py` | Python entry point — starts the QGuiApplication and loads the QML engine |
| `GridExplorer.qml` | Full interactive UI — grid playground + live property controls |

---

## Prerequisites

```
pip install PySide6
```

Python 3.9+ recommended.

---

## Running

```bash
cd Layouts/GridLayout
python main.py
```

---

## UI Layout

```
┌─────────────────────────────────────┬──────────────────────┐
│          Grid Playground            │     Properties        │
│                                     │  1 · Grid Structure   │
│   ┌──┐ ┌──┐ ┌──┐                   │  2 · Spacing          │
│   │ 1│ │ 2│ │ 3│                   │  3 · Flow & Direction │
│   └──┘ └──┘ └──┘                   │  4 · Cell Span        │
│   ┌──┐ ┌──┐ ┌──┐                   │  5 · Fill             │
│   │ 4│ │ 5│ │ 6│                   │  6 · Alignment        │
│   └──┘ └──┘ └──┘                   │  7 · Size Hints       │
│                                     │  [ Reset ]            │
│                                     │  Live Status          │
└─────────────────────────────────────┴──────────────────────┘
```

The **left panel** shows the live grid. The **right panel** holds all controls. Changes are reflected instantly.

---

## Controllable Properties

### 1 · Grid Structure

| Control | QML property | What it does |
|---|---|---|
| Columns | `GridLayout.columns` | Maximum number of columns before wrapping (when flow = LeftToRight) |
| Rows | `GridLayout.rows` | Maximum number of rows before wrapping (when flow = TopToBottom) |
| Cell Count | — | Number of coloured cells placed into the grid |

**Tip:** `columns` is only respected when `flow = LeftToRight`. Switch to `TopToBottom` to make `rows` the controlling dimension.

---

### 2 · Spacing

| Control | QML property | What it does |
|---|---|---|
| Col Spacing | `GridLayout.columnSpacing` | Horizontal gap between columns (px) |
| Row Spacing | `GridLayout.rowSpacing` | Vertical gap between rows (px) |

**Tip:** Set both to 0 to see cells touch. Increase them to create breathing room.

---

### 3 · Flow & Direction

| Control | QML property | Values |
|---|---|---|
| Flow | `GridLayout.flow` | `LeftToRight` — fills left→right, wraps down. `TopToBottom` — fills top→down, wraps right. |
| Direction | `GridLayout.layoutDirection` | `LeftToRight` (default) or `RightToLeft` — mirrors the entire grid horizontally |

**Tip:** Combine `flow = TopToBottom` with `RightToLeft` direction to see Arabic/Hebrew-style grid ordering.

---

### 4 · Cell Span

One cell is highlighted with a **white border** (the "target" cell). Its span can be changed independently.

| Control | QML attached property | What it does |
|---|---|---|
| Target Cell # | — | Which cell (1-based) receives the custom span |
| Column Span | `Layout.columnSpan` | How many columns the target cell stretches across |
| Row Span | `Layout.rowSpan` | How many rows the target cell stretches down |

**Tip:** Set Target = 1, Column Span = 2 and watch cell 1 consume two columns — subsequent cells shift right.

---

### 5 · Fill

Applies to **all cells**.

| Control | QML attached property | What it does |
|---|---|---|
| fillWidth | `Layout.fillWidth` | Cell expands horizontally to consume extra column space |
| fillHeight | `Layout.fillHeight` | Cell expands vertically to consume extra row space |

**Tip:** Uncheck both to see cells shrink to their implicit/preferred size. Hover over a cell to see its pixel dimensions.

---

### 6 · Alignment

Applies to **all cells**. Only visible when `fillWidth`/`fillHeight` is **off** (cells must be smaller than their cell slot).

| Control | QML attached property | Values |
|---|---|---|
| Horizontal | `Layout.alignment` (H part) | Left / HCenter / Right |
| Vertical | `Layout.alignment` (V part) | Top / VCenter / Bottom |

**Tip:** Turn off both fill options, set preferred size (section 7), then change alignment to see cells reposition inside their slots.

---

### 7 · Size Hints

Applies to **all cells**. A value of **0** means "unset / use implicit size".

| Control | QML attached property | What it does |
|---|---|---|
| Pref Width | `Layout.preferredWidth` | Ideal width the layout engine aims for |
| Pref Height | `Layout.preferredHeight` | Ideal height the layout engine aims for |
| Min Width | `Layout.minimumWidth` | Hard lower bound — cell never shrinks below this |
| Min Height | `Layout.minimumHeight` | Hard lower bound — cell never shrinks below this |
| Max Width | `Layout.maximumWidth` | Hard upper bound — cell never grows above this |
| Max Height | `Layout.maximumHeight` | Hard upper bound — cell never grows above this |

**Tip:** Set Min Width = 80 and shrink the window — cells will stop shrinking at 80 px. Set Max Width = 100 with `fillWidth` on to cap growth.

---

## Suggested Experiments

1. **Basic wrapping** — Set Columns = 2 and Cell Count = 6. Observe 3 rows form automatically.
2. **Flow direction** — Switch Flow to `TopToBottom` with Rows = 2 and Cell Count = 6. Cells now fill column-by-column.
3. **Spanning** — Target Cell = 1, Column Span = 3. Cell 1 becomes a header spanning the full width.
4. **No fill + alignment** — Uncheck fillWidth & fillHeight, set Pref Width = 60, Pref Height = 40, Alignment H = HCenter, V = VCenter.
5. **Size clamping** — fillWidth = on, Max Width = 120. Resize the window wider; cells stop growing at 120 px.
6. **RTL layout** — Direction = RightToLeft to mirror a form for right-to-left languages.
7. **Dense packing** — Col Spacing = 0, Row Spacing = 0 for a tight tile grid.

---

## Key Concepts Summary

```
GridLayout
├── columns / rows          → grid dimensions (one drives wrapping per flow)
├── columnSpacing / rowSpacing → gaps between cells
├── flow                    → fill order (LeftToRight | TopToBottom)
└── layoutDirection         → mirror direction (LTR | RTL)

Attached to each child item via Layout.*
├── columnSpan / rowSpan    → merge cells
├── fillWidth / fillHeight  → expand to fill available space
├── alignment               → position within cell slot
├── preferredWidth/Height   → hint to layout engine
├── minimumWidth/Height     → hard lower constraint
└── maximumWidth/Height     → hard upper constraint
```
