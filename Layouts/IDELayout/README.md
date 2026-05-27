# IDE Layout Explorer

An interactive PySide6 + QML explorer for **multi-panel resizable window layouts** — the same patterns used in real IDEs and code editors.

---

## Run

```bash
cd Layouts/IDELayout
python main.py
```

Requires the venv to be active (`pip install PySide6`).  
Opens a **1280 × 800** window (minimum 920 × 580, freely resizable).

---

## What's in the Window

```
┌──────────────────────────────────────────────────────────────────┐
│  Toolbar  (File · Edit · View · Run · Terminal · Help)           │
├────┬─────────────────────────────────┬────────────────────────────┤
│    │                                 │                            │
│ A  │  Side Panel                     │  Editor Area               │
│ c  │  (Explorer / Search /           │  (tabbed code viewer)      │
│ t  │   Table / Timeline)             │                            │
│ i  │                                 ├────────────────────────────┤
│ v  │  ◄── drag handle ──►            │  Bottom Panel              │
│ i  │                                 │  (Console/Output/          │
│ t  │                                 │   Problems/Terminal)       │
│ y  │                                 │  ▲ drag handle ▼           │
├────┴─────────────────────────────────┴────────────────────────────┤
│  Status Bar  (branch · errors · language · encoding · cursor)    │
└──────────────────────────────────────────────────────────────────┘
```

---

## Zones

| Zone | Fixed / Resizable | Description |
|---|---|---|
| Top toolbar | Fixed (38 px) | Menu items, search bar, Run / Debug buttons |
| Activity bar | Fixed (48 px) | Icon strip — switches side panel content; click active icon to collapse |
| Side panel | **Resizable** (default 260 px, min 160 px, max 520 px) | Four views (Explorer / Search / Table / Timeline) |
| Main editor | **Fills** remaining width | Tabbed code viewer — three files |
| Bottom panel | **Resizable** (default 200 px, min 80 px) | Four tabs (Console / Output / Problems / Terminal) |
| Status bar | Fixed (24 px) | Language, encoding, cursor, branch, error counts |

Both drag handles highlight in **accent purple** on hover.

---

## Side Panel Views

Switch with the activity bar icons. Click the active icon again to **collapse / expand** the panel.

| Icon | Label | Content |
|---|---|---|
| `≡` | Explorer | Depth-indented file tree; folders in orange, files colour-coded by extension |
| `⌕` | Search | Simulated find-in-files results (file + line + matched text) |
| `▦` | Table | Four-column data grid: Name · Type · Size · Modified |
| `〰` | Timeline | Chronological event log with coloured dot + vertical connector line |

---

## Editor Tabs

Three read-only code files demonstrating the key QML patterns used in this explorer:

| Tab | File | Language |
|---|---|---|
| 1 | `IDELayout.qml` | QML — the full SplitView layout skeleton |
| 2 | `main.py` | Python — PySide6 launcher |
| 3 | `backend.py` | Python — QAbstractTableModel reference snippet |

Active tab shows a **top accent bar** and the file extension label is colour-coded.  
A small **orange dot** on a tab label indicates an unsaved change.

---

## Bottom Panel Tabs

| Tab | Content |
|---|---|
| Console | Scrollable log + interactive `TextInput` — type a command and press Enter to append it |
| Output | Simulated build log |
| Problems | Error / warning / info list with severity icons |
| Terminal | Simulated PowerShell session output |

---

## Key QML Concepts

### `SplitView` — resizable panels

```qml
SplitView {
    orientation: Qt.Horizontal   // or Qt.Vertical

    // Custom drag handle
    handle: Rectangle {
        implicitWidth: 4          // thickness of the handle
        color: SplitHandle.hovered || SplitHandle.pressed
               ? "#cba6f7" : "#313244"
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    // Fixed-size panel with constraints
    Rectangle {
        SplitView.preferredWidth: 260
        SplitView.minimumWidth:   160
        SplitView.maximumWidth:   520
    }

    // Panel that absorbs all remaining space
    Item {
        SplitView.fillWidth: true
    }
}
```

### Collapse a panel

Set `visible: false` on a `SplitView` child — the handle disappears and the adjacent item fills the gap:

```qml
Rectangle {
    id: sidePanel
    visible: root.sidePanelOpen   // false → panel collapses
    SplitView.preferredWidth: 260
}
```

### Nested `SplitView` (editor + bottom panel)

```qml
SplitView {
    SplitView.fillWidth: true     // inside an outer horizontal SplitView
    orientation: Qt.Vertical

    Item { SplitView.fillHeight:   true;  SplitView.minimumHeight: 120 }  // editor
    Item { SplitView.preferredHeight: 200; SplitView.minimumHeight: 80 }  // console
}
```

### `SplitHandle` attached properties

| Property | Type | Meaning |
|---|---|---|
| `SplitHandle.hovered` | `bool` | Cursor is over the handle |
| `SplitHandle.pressed` | `bool` | Handle is being dragged |

### `StackLayout` + tab bar

```qml
// Tab buttons set currentIndex
StackLayout {
    currentIndex: root.activeTab
    // only the child at currentIndex is visible
    Item { /* view 0 */ }
    Item { /* view 1 */ }
}
```

### Scrollable code viewer

```qml
ScrollView {
    clip: true
    background: Rectangle { color: "#1e1e2e" }
    TextArea {
        readOnly: true
        font.family: "Consolas"; font.pixelSize: 14
        wrapMode: TextArea.NoWrap      // enables horizontal scrolling
        background: Rectangle { color: "#1e1e2e" }
        text: "..."
    }
}
```

---

## Files

| File | Purpose |
|---|---|
| `main.py` | Launcher — sets `QQuickStyle("Basic")`, loads QML |
| `IDELayoutExplorer.qml` | Everything — layout, all panels, all data |

No Python backend beyond the launcher; all state is managed in QML.

---

## Concept-to-File Index

| Concept | File | Approx. line |
|---|---|---|
| Horizontal `SplitView` (`mainSplit`) | `IDELayoutExplorer.qml` | ~130 |
| Vertical `SplitView` (`rightSplit`) | `IDELayoutExplorer.qml` | ~280 |
| Custom `handle` with `Behavior` | `IDELayoutExplorer.qml` | ~133 |
| Activity bar + collapse toggle | `IDELayoutExplorer.qml` | ~102 |
| Side panel `StackLayout` (4 views) | `IDELayoutExplorer.qml` | ~220 |
| Explorer file tree `ListView` | `IDELayoutExplorer.qml` | ~235 |
| Timeline with dot + connector | `IDELayoutExplorer.qml` | ~310 |
| Editor tab bar + top accent | `IDELayoutExplorer.qml` | ~355 |
| Scrollable `TextArea` code viewer | `IDELayoutExplorer.qml` | ~385 |
| Bottom panel tabs + `StackLayout` | `IDELayoutExplorer.qml` | ~470 |
| Console `TextInput` + log append | `IDELayoutExplorer.qml` | ~500 |
| Status bar with dynamic lang label | `IDELayoutExplorer.qml` | ~565 |
