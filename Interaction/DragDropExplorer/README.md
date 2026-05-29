# Drag & Drop Explorer

Kanban-style card board demonstrating QML's drag-and-drop primitives: `MouseArea.drag.target`, the `Drag` attached object, and `DropArea`.

## Run

```bash
cd Interaction/DragDropExplorer
python main.py
```

## Files

| File | Purpose |
|---|---|
| `drag_drop_backend.py` | `DragDropBackend(QObject)` — assigns a random Catppuccin accent to each new card; emits `boardReset` / `cardAdded` |
| `main.py` | Entry point — exposes `backend` context property |
| `DragDropExplorer.qml` | Kanban board with three `ListModel` columns and a floating drag proxy |

---

## Architecture

```
Three ListModels:  todoModel · inProgressModel · doneModel
                    │
                    ▼
         Repeater (3 columns) → Repeater (cards per column)
                    │
        Card's MouseArea ──drag.target──▶ floatingCard (z:999)
                    │                         │
                    │                    Drag.active: visible
                    │                    Drag.keys: ["kanban"]
                    │                    Drag.hotSpot = centre
                    │
         DropArea (per column)
              keys: ["kanban"]
              onDropped → remove(srcIdx) + append(title, color)
```

---

## Core Pattern: Floating Proxy Drag

Rather than moving the real card item (which would require reparenting it out of its Repeater), a single shared proxy (`floatingCard`) lives at root level with `z: 999`. The card's `MouseArea` sets `drag.target: floatingCard`, so the proxy moves with the cursor while the original card dims in place.

```qml
// 1. Proxy at root level (sibling of the ColumnLayout, so it paints over everything)
Rectangle {
    id: floatingCard
    z: 999
    visible: false

    Drag.active:    floatingCard.visible   // activates the DnD system
    Drag.keys:      ["kanban"]             // only matching DropAreas respond
    Drag.hotSpot.x: width  / 2            // cursor position for hit-testing
    Drag.hotSpot.y: height / 2
}

// 2. Card's MouseArea hands off movement to the proxy
MouseArea {
    drag.target:     floatingCard
    drag.threshold:  4
    preventStealing: true      // beats Flickable's grab

    onPressed: function(mouse) {
        // Position proxy so cursor lands at its centre
        var pos = mapToItem(root.contentItem,
                            mouse.x - floatingCard.width  / 2,
                            mouse.y - floatingCard.height / 2)
        floatingCard.x = pos.x
        floatingCard.y = pos.y
        floatingCard.visible = true   // → Drag.active becomes true
    }

    onReleased: {
        floatingCard.Drag.drop()      // fires DropArea.onDropped synchronously
        floatingCard.visible = false  // → Drag.active becomes false
    }
}

// 3. Column's DropArea accepts the drop
DropArea {
    keys: ["kanban"]    // must match Drag.keys on the proxy

    onEntered: colRect.dropHighlight = true
    onExited:  colRect.dropHighlight = false

    onDropped: function(drop) {
        // root.dragSourceCol/Index were captured in onPressed
        root.colModels[srcCol].remove(srcIdx)
        root.colModels[targetColIdx].append({ title: ..., cardColor: ... })
        drop.acceptProposedAction()
    }
}
```

---

## Key Properties

### `Drag` attached object (on the proxy)

| Property | Description |
|---|---|
| `Drag.active` | `true` → QML DnD system starts tracking the item. DropAreas receive `onEntered` / `onExited` as the item moves over them. |
| `Drag.keys` | String list. Only DropAreas whose `keys` list contains at least one matching key will fire events. |
| `Drag.hotSpot` | Point within the item used for DropArea hit-testing (should be at the cursor). |
| `Drag.drop()` | Immediately finds the overlapping DropArea and calls its `onDropped`. Returns the accepted `Qt.DropAction`. |

### `DropArea`

| Property / Signal | Description |
|---|---|
| `keys` | Filter — only items whose `Drag.keys` intersect this list can trigger events. |
| `onEntered` | Item with matching keys entered. Use for highlight feedback. |
| `onExited` | Item left the area (or was dropped elsewhere). |
| `onDropped(drop)` | Drop finalised. Call `drop.acceptProposedAction()` to confirm; or return without accepting to treat as `IgnoreAction`. |

### `MouseArea.drag`

| Property | Description |
|---|---|
| `drag.target` | The item to move. Moves by the same delta as the mouse from the press point, in the target's parent coordinate space. |
| `drag.threshold` | Pixels to move before drag starts. |
| `preventStealing` | `true` prevents parent items (e.g. `Flickable`) from stealing the mouse grab. Essential when cards are inside a scrollable list. |

---

## Coordinate Mapping

The proxy lives in `root.contentItem` coordinates. The card's MouseArea is nested many levels deep. `mapToItem(root.contentItem, x, y)` correctly maps through all intermediate transforms:

```qml
var pos = mapToItem(root.contentItem,
                    mouse.x - floatingCard.width  / 2,
                    mouse.y - floatingCard.height / 2)
floatingCard.x = pos.x
floatingCard.y = pos.y
```

Subtracting `width/2` and `height/2` ensures the cursor lands on the visual centre of the proxy (matching `Drag.hotSpot`).

---

## Explorer Controls

| Control | Demonstrates |
|---|---|
| Drag card to another column | Full proxy DnD cycle: `onPressed` → `onDropped` → `onReleased` |
| Drag card to same column | Same-column guard: `if (srcCol === targetCol) return` (drop not accepted) |
| Click × | `ListModel.remove(index)` — direct model mutation, no drag involved |
| Add Card | `backend.addCard(title, colIndex)` → Python assigns random color → `cardAdded` signal → QML appends |
| Reset Board | `backend.resetBoard()` → `boardReset` signal → QML clears and re-populates all three models |

---

## Key Takeaways

1. Use a **root-level floating proxy** rather than reparenting the real item — avoids Repeater delegate lifetime issues.
2. `Drag.active: someItem.visible` is the simplest way to tie the DnD system to proxy visibility.
3. `preventStealing: true` is mandatory on drag MouseAreas inside `Flickable` or `ListView`.
4. `Drag.drop()` is synchronous — `onDropped` fires and completes before `onReleased` continues.
5. Always reset `dragSourceCol` / `dragSourceIndex` **after** `Drag.drop()` so they're valid during `onDropped`.
