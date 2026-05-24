# ColumnLayout Explorer

An interactive PySide6 + QML tool for learning `ColumnLayout` properties.
Unlike the GridLayout explorer, **controls live in a separate window** so the playground fills the entire screen — letting you observe true full-window stretch/fill behaviour as you resize freely.

---

## Files

| File | Purpose |
|---|---|
| `main.py` | Python entry point |
| `ColumnExplorer.qml` | Two-window QML app (playground + properties panel) |

---

## Prerequisites

```
pip install PySide6
```

---

## Running

```bash
cd Layouts/ColumnLayout
python main.py
```

Two windows open automatically, side by side:

```
┌──────────────────────────┐   ┌─────────────────────────────┐
│   ColumnLayout           │   │   ColumnLayout Properties   │
│   Playground             │   │  ──────────────────────────  │
│                          │   │  1 · Layout Structure        │
│   ┌──────────────────┐   │   │  2 · Fill                    │
│   │      Cell 1      │   │   │  3 · Alignment               │
│   └──────────────────┘   │   │  4 · Size Hints              │
│   ┌──────────────────┐   │   │  5 · Margins (target cell)   │
│   │      Cell 2      │   │   │  ──────────────────────────  │
│   └──────────────────┘   │   │  [ Reset All to Defaults ]   │
│         ...              │   │  ──────────────────────────  │
│                          │   │  Live status readout         │
└──────────────────────────┘   └─────────────────────────────┘
  Resize freely to see             Controls stay on top
  full-screen behaviour
```

> Hover any cell in the playground for a tooltip showing its live pixel position and size.

---

## Controllable Properties

### 1 · Layout Structure

| Control | QML property | What it does |
|---|---|---|
| Cell Count | — | Number of coloured boxes placed in the layout |
| Spacing | `ColumnLayout.spacing` | Vertical gap between all cells (px) |
| Direction | `ColumnLayout.layoutDirection` | `TopToBottom` (default) places cell 1 at the top; `BottomToTop` reverses the stack |

**Tip — Direction:** Switch to `BottomToTop` to see cell 1 appear at the bottom. Useful for chat-style lists or reversed stacks.

---

### 2 · Fill

Applies to **all cells**.

| Control | QML attached property | What it does |
|---|---|---|
| fillWidth | `Layout.fillWidth` | Cell stretches horizontally to fill the full column width |
| fillHeight | `Layout.fillHeight` | Cell claims a share of the remaining vertical space |

**Tip — fillHeight:** When multiple cells all have `fillHeight: true` they share available height equally. When only one cell has it, that cell takes all leftover space. Turn off `fillHeight` for all cells to see them shrink to their implicit/preferred height with empty space below.

---

### 3 · Alignment

Only visible when `fillWidth` and/or `fillHeight` is **off** — cells must be smaller than their available slot for alignment to have any effect.

| Control | QML attached property | Values |
|---|---|---|
| Horizontal | `Layout.alignment` (H part) | Left / HCenter / Right |
| Vertical | `Layout.alignment` (V part) | Top / VCenter / Bottom |

**Tip:** Turn off `fillWidth`, set `Pref Width = 120`, then change Horizontal alignment to see cells shift left/center/right within the column.

---

### 4 · Size Hints

Applies to **all cells**. `0` means "unset, use implicit size".

| Control | QML attached property | What it does |
|---|---|---|
| Pref Width | `Layout.preferredWidth` | Ideal width the engine aims for |
| Pref Height | `Layout.preferredHeight` | Ideal height the engine aims for |
| Min Width | `Layout.minimumWidth` | Hard lower bound — cell never shrinks below this |
| Min Height | `Layout.minimumHeight` | Hard lower bound — cell never shrinks below this |
| Max Width | `Layout.maximumWidth` | Hard upper bound — cell never grows above this |
| Max Height | `Layout.maximumHeight` | Hard upper bound — cell never grows above this |

**Tip — Min Height:** Set `Min Height = 80` and shrink the playground window vertically; cells resist compression down to 80 px.

**Tip — Max Height + fillHeight:** Enable `fillHeight` and set `Max Height = 150`. Cells grow until they hit the cap, then stop.

---

### 5 · Margins (target cell only)

The **white-bordered** cell is the target. Its four margins are controlled independently.

| Control | QML attached property | What it does |
|---|---|---|
| Target Cell # | — | Which cell (1-based) receives custom margins |
| Top Margin | `Layout.topMargin` | Extra space above the target cell |
| Bottom Margin | `Layout.bottomMargin` | Extra space below the target cell |
| Left Margin | `Layout.leftMargin` | Extra space left of the target cell |
| Right Margin | `Layout.rightMargin` | Extra space right of the target cell |

**Note:** Cell-level margins are *added on top of* the layout's `spacing`. They are the recommended replacement for `spacing` when you need uneven gaps.

---

## Suggested Experiments

1. **Basic fill** — Default settings. Resize the playground window tall/wide and watch all cells share height equally (`fillHeight` off) vs stretch when enabled.
2. **Equal height sharing** — Enable `fillHeight`. All 4 cells split the available height. Add a 5th cell and observe the re-split.
3. **Single greedy cell** — Disable `fillHeight` for concept, set `Pref Height = 60`, then enable `fillHeight` on one cell only by observing — only target cell grows (set others via Max Height = 60).
4. **Direction reversal** — Switch Direction to `BottomToTop`. The numbered cells appear in reverse order from the bottom up.
5. **Max height cap** — `fillHeight` on, `Max Height = 100`. Resize taller; cells stop growing past 100 px and leave blank space.
6. **Margin vs spacing** — Set Spacing = 0, then use Top/Bottom Margin on the target cell to create a gap only around that one item.
7. **Alignment** — `fillWidth` off, `Pref Width = 150`, Horizontal = HCenter. Cells sit centred in the column.
8. **Min width resistance** — `fillWidth` off, `Min Width = 200`. Shrink the window narrower than 200 px; a horizontal scrollbar appears and cells hold their width.

---

## Key Concepts Summary

```
ColumnLayout
├── spacing           → uniform gap between every cell
└── layoutDirection   → TopToBottom (default) | BottomToTop

Attached to each child via Layout.*
├── fillWidth         → stretch to fill column width
├── fillHeight        → claim share of leftover height
├── alignment         → position when smaller than slot (H × V)
├── preferredWidth/Height  → hint to layout engine
├── minimumWidth/Height    → hard lower constraint
├── maximumWidth/Height    → hard upper constraint
└── topMargin / bottomMargin / leftMargin / rightMargin
                      → per-cell spacing (additive with spacing)
```
