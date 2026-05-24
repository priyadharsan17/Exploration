# Exploration

A hands-on PySide6 + QML learning workspace. Each sub-project is a standalone interactive explorer for a specific Qt Quick concept — run it, tweak the controls, and observe behaviour live.

---

## Repository Structure

```
Exploration/
└── Layouts/
    ├── GridLayout/       ← GridLayout explorer  (single window)
    └── ColumnLayout/     ← ColumnLayout explorer (two windows)
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

## Common Tips

- **Hover any cell** in the playground for a tooltip showing its live pixel position and size.
- Each explorer has a **Reset All to Defaults** button to restore the initial state.
- The **live status box** at the bottom of every Properties panel reflects the current property values in real time.
- Resize the playground window while controls are applied to see how constraints, fill, and alignment respond dynamically.
