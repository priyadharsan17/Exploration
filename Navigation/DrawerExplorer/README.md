# Drawer · SwipeView · TabBar Explorer

Interactive explorer for `Drawer`, `SwipeView`, and `TabBar` — the three core Qt Quick navigation surface patterns.

## Run

```bash
cd Navigation/DrawerExplorer
python main.py
```

## Files

| File | Purpose |
|---|---|
| `main.py` | Entry point — `QGuiApplication` + `QQmlApplicationEngine` |
| `DrawerExplorer.qml` | Four-page app with Drawer, TabBar, SwipeView, and control panel |

---

## Drawer

A `Drawer` is a panel that slides in from any screen edge, overlaying the main content.

### Key properties

| Property | Type | Description |
|---|---|---|
| `edge` | `Qt.Edge` | Which edge the drawer slides from. `Qt.LeftEdge` (default), `Qt.RightEdge`, `Qt.TopEdge`, `Qt.BottomEdge`. |
| `width` / `height` | `real` | Set the size in the axis **perpendicular** to the edge. For a left/right drawer set `width`; for top/bottom set `height`. |
| `modal` | `bool` | When `true` (default) a translucent overlay dims the content behind the drawer and clicking it closes the drawer. When `false` the drawer is non-modal — the background stays interactive. |
| `position` | `real` (0.0 – 1.0) | How far the drawer has slid in. 0.0 = fully closed, 1.0 = fully open. Animates during open/close. Useful for parallax effects. |
| `interactive` | `bool` | Whether the user can drag the drawer open/closed with a swipe gesture. Default `true`. |
| `Overlay.modal` | `Component` | The overlay rectangle shown in modal mode. Customise the dim colour here. |

### Methods

| Method | Description |
|---|---|
| `open()` | Slide the drawer in. |
| `close()` | Slide the drawer out. |

### Signals

| Signal | Fires when… |
|---|---|
| `opened` | Drawer is fully open (`position == 1.0`) |
| `closed` | Drawer is fully closed (`position == 0.0`) |
| `aboutToShow` | Immediately before opening begins |
| `aboutToHide` | Immediately before closing begins |

### Modal vs non-modal

```
modal: true  → background is dimmed + clicking outside closes the drawer
modal: false → drawer overlaps content without blocking interaction behind it
```

Non-modal drawers are suited for persistent side-panels in wide-screen/desktop layouts.

---

## SwipeView

`SwipeView` provides a swipeable, index-based page container. It is **not** aware of transitions — it uses a flat list of children and a `currentIndex`.

### Key properties

| Property | Type | Description |
|---|---|---|
| `currentIndex` | `int` | Which page is currently shown. Setting this programmatically animates the slide. |
| `count` | `int` | Total number of pages. |
| `interactive` | `bool` | Enables/disables touch-swipe gesture. Set to `false` for keyboard/programmatic navigation only. |
| `clip` | `bool` | Should be `true` to prevent pages from painting outside the view during swipe. |
| `currentItem` | `Item` | Reference to the currently active page. |

### Lazy loading

Pages in a `SwipeView` are **created lazily**: a page is only instantiated when it is first swiped to (or within one page of the current index). Once created, pages are **kept alive** unless you explicitly destroy them.

### Page attached properties

Every page inside a `SwipeView` gets these attached properties:

| Property | Description |
|---|---|
| `SwipeView.index` | The page's position (0-based). |
| `SwipeView.isCurrentItem` | `true` when this page is active. |
| `SwipeView.isPreviousItem` | `true` when this page is the one before the current. |
| `SwipeView.isNextItem` | `true` when this page is the one after the current. |
| `SwipeView.view` | Reference to the containing `SwipeView`. |

---

## TabBar + SwipeView — synced navigation

`TabBar` and `SwipeView` are designed to work together. Sync them by binding `currentIndex`:

```qml
TabBar {
    id: tabBar
    currentIndex: swipeView.currentIndex   // TabBar follows SwipeView
    // ...TabButton items...
}

SwipeView {
    id: swipeView
    // currentIndex set by TabButton.onClicked or by programmatic assignment
}
```

`TabBar.currentIndex` must **not** be set by a two-way binding — instead, set `swipeView.currentIndex` imperatively (from `TabButton.onClicked`) so the TabBar reflects the view rather than fighting it.

### TabButton styling

`TabButton` has the same `contentItem` / `background` customisation hooks as `Button`. The active-underline indicator pattern used in this explorer:

```qml
background: Rectangle {
    color: "transparent"
    Rectangle {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: isActive ? parent.width - 16 : 0    // animate width for slide-in effect
        height: 2
        Behavior on width { NumberAnimation { duration: 180 } }
    }
}
```

---

## Navigation Drawer pattern

The classic nav-drawer pattern combines `Drawer` + `SwipeView`:

1. Hamburger button → `drawer.open()`
2. Drawer item clicked → `swipeView.currentIndex = pageIndex` → `drawer.close()`
3. TabBar tabs → `swipeView.currentIndex = tabIndex`
4. Swipe gesture (if `interactive: true`) → `SwipeView` updates `currentIndex` → `TabBar` follows

All three navigation paths converge on `SwipeView.currentIndex` as the single source of truth.

---

## Explorer Controls

| Control | Action |
|---|---|
| Hamburger (☰) button | Opens the Drawer |
| TabBar tabs | Switch pages; active underline animates |
| Drawer nav items | Navigate to a page and close the drawer |
| Open / Close Drawer | Programmatic `drawer.open()` / `drawer.close()` |
| Edge: Left / Bottom | Changes `drawer.edge` at runtime |
| modal ON/OFF | Toggles `drawer.modal` — removes/adds dim overlay |
| SwipeView page buttons | Sets `swipeView.currentIndex` directly |
| interactive ON/OFF | Enables/disables touch-swipe gesture on `SwipeView` |
| Live Info panel | Live readout of `position`, `currentIndex`, `count`, `modal`, `edge` |

---

## Key Takeaways

1. `Drawer.position` is a 0–1 value animated automatically on `open()`/`close()`. Bind it for parallax or live overlays.
2. `modal: false` makes the drawer non-blocking — useful for persistent sidebars.
3. `SwipeView.currentIndex` is the single source of truth. `TabBar`, `Drawer`, and programmatic buttons all write to it; nothing else needs syncing.
4. `TabBar.currentIndex` should only **read** from `swipeView.currentIndex`, not the other way around, to avoid binding loops.
5. `SwipeView.interactive: false` is the right way to force keyboard/programmatic-only navigation (e.g., when the swipe gesture conflicts with other gestures).
6. Pages inside `SwipeView` have `SwipeView.isCurrentItem` to conditionally activate animations or data loads only when visible.
