# ListView Transition Explorer

An interactive explorer for the five `ListView` transition types in Qt Quick.
Run it, press buttons, and watch the transitions fire in real time. The status
bar at the bottom always tells you which transition fired and why.

**Run:**
```bash
cd Animations/ListViewTransitions
python main.py
```

---

## The five transitions

A `ListView` lets you attach a `Transition` to each of five lifecycle events.
Each one animates different items at a different moment.

```
┌─────────────────────────────────────────────────────────────────────┐
│  Event         Property on ListView    Which items animate           │
├─────────────────────────────────────────────────────────────────────┤
│  populate      populate:               All items when the model is   │
│                                        first assigned to the view    │
│  insert        add:                    The newly inserted item       │
│  delete        remove:                 The item being deleted        │
│  shift (add)   displaced:              Items that shift because of   │
│  shift (del)   displaced:              another item's add/remove/move│
│  shift (move)  displaced:              ↑ same transition, three causes│
│  reorder       move:                   Items moved via move()        │
└─────────────────────────────────────────────────────────────────────┘
```

> **displaced vs move** — `move` fires on the item you explicitly reordered.
> `displaced` fires on every *other* item that had to shuffle to make room.

---

## How each transition is defined

```qml
ListView {
    model: itemModel

    // 1. POPULATE — model assigned (or reassigned) to the view
    populate: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 500 }
            NumberAnimation { property: "x";       from: -80; to: 0; duration: 500 }
        }
    }

    // 2. ADD — item inserted via insert() / append()
    add: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 400 }
            NumberAnimation { property: "scale";   from: 0; to: 1; duration: 400;
                              easing.type: Easing.OutBack }
        }
    }

    // 3. REMOVE — item deleted via remove() / clear()
    remove: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 300 }
            NumberAnimation { property: "x"; to: lv.width + 60; duration: 300;
                              easing.type: Easing.InCubic }
        }
    }

    // 4. DISPLACED — items that shift because of someone else's add/remove/move
    displaced: Transition {
        NumberAnimation { properties: "x,y"; duration: 420; easing.type: Easing.OutBack }
    }

    // 5. MOVE — items explicitly reordered via ListModel.move()
    move: Transition {
        NumberAnimation { properties: "x,y"; duration: 320; easing.type: Easing.InOutQuad }
    }
}
```

### Why `scale` works in the `add` transition

The delegate is a `Rectangle`, which inherits `Item.scale`. Setting
`transformOrigin: Item.Center` makes the scale animation expand outward
from the centre of the card rather than from the top-left corner.

### Why the `populate` transition needs a model detach/reattach

`populate` only fires when the model is **first assigned** to the view.
Because `itemModel` is declared as an empty `ListModel` and items are appended
in `Component.onCompleted`, the view already has its model by the time items
arrive — so those trigger `add`, not `populate`.

To force `populate` to re-fire (via the **↺ Replay Populate** button), the
code temporarily disconnects the model, rebuilds it, then reconnects:

```qml
lv.model = null          // detach — view goes blank instantly
itemModel.clear()
// ... append 7 fresh items to the now-disconnected model ...
lv.model = itemModel     // reattach — populate transition fires for all 7 items
```

---

## The delegate

```qml
delegate: Rectangle {
    required property int    index   // current visual position (0-based)
    required property string nm      // "Item 0", "Item 1", …
    required property string cl      // hex colour string from the model

    width:           lv.width
    height:          56
    radius:          8
    color:           root.selectedIdx === index ? Qt.lighter(cl, 1.4) : cl
    scale:           1.0             // add transition animates this from 0
    transformOrigin: Item.Center     // scale expands from the centre
    ...
}
```

`required property` is the Qt 6 way to pull model roles into the delegate.
The role names (`nm`, `cl`) must match exactly what is stored in the
`ListModel`.

---

## Controls reference

| Section | Button | `ListModel` call | Transitions that fire |
|---|---|---|---|
| Add | + Top | `insert(0, …)` | `add` + `displaced` |
| Add | + Bottom | `append(…)` | `add` only |
| Add | + Random | `insert(i, …)` | `add` + `displaced` |
| Remove | × Selected / Top / Bottom | `remove(i)` | `remove` + `displaced` |
| Reorder | ↑ Up / ↓ Down | `move(i, i±1, 1)` | `move` + `displaced` |
| Reorder | Shuffle | `move(…)` × N (Fisher-Yates) | `move` + `displaced` rapid-fire |
| Reset | ↺ Replay Populate | null → `append` × 7 → reassign | `populate` |
| Reset | ⌫ Clear All | `clear()` | `remove` × N (no `displaced`) |

> **Why no `displaced` on Clear All?**  
> `displaced` fires on items that *remain* in the list but shifted position.
> When you clear the entire list there are no remaining items, so nothing is
> displaced.

---

## File overview

| File | Purpose |
|---|---|
| `main.py` | Launches the app; sets `QQuickStyle` to `"Basic"` so `Button` background/contentItem customisation works on Windows |
| `ListViewTransitionsExplorer.qml` | Single-file QML: model, all five transitions, delegate, controls panel, status bar |
