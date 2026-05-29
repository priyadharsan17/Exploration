# StackView Explorer

Interactive explorer for `StackView` — Qt Quick's push-down navigation stack.

## Run

```bash
cd Navigation/StackViewExplorer
python main.py
```

## Files

| File | Purpose |
|---|---|
| `main.py` | Entry point — `QGuiApplication` + `QQmlApplicationEngine` |
| `StackViewExplorer.qml` | Four pages, custom transitions, control panel |

---

## Core Concept

`StackView` maintains an ordered **stack of pages**. Pages are pushed on top of each other; `pop()` removes the top page and reveals the one below.

```
Stack (bottom → top)
  [PageA]  ← root, never removed by pop()
  [PageB]
  [PageC]  ← currentItem (depth: 3)
```

---

## StackView API

### Methods

| Method | Description |
|---|---|
| `push(component, properties)` | Create and push a new page. `properties` is an optional JS object applied to the new item before it becomes active. |
| `pop()` | Remove and destroy the top page; reveal the page below. Returns the popped item. |
| `pop(null)` | Pop all pages down to and including the initial item (back to root). |
| `pop(targetItem)` | Pop until `targetItem` is the current page. |
| `replace(component, properties)` | Replace the current top page with a new one (no back entry created). |
| `clear()` | Remove and destroy all pages. Stack becomes empty — push a new root page immediately after. |

### Properties

| Property | Type | Description |
|---|---|---|
| `depth` | `int` | Number of pages currently on the stack. |
| `currentItem` | `Item` | Reference to the active (top) page. |
| `busy` | `bool` | `true` while a transition animation is running. |
| `initialItem` | `Component \| Item` | Page that is shown when the StackView is first created. |

### Transition properties

Each of the six transitions is a `Transition` QML object assigned to a StackView property:

| Property | When it applies |
|---|---|
| `pushEnter` | The new page entering on a `push()` |
| `pushExit` | The old page exiting on a `push()` |
| `popEnter` | The page below re-entering on a `pop()` |
| `popExit` | The top page exiting on a `pop()` |
| `replaceEnter` | The new page entering on a `replace()` |
| `replaceExit` | The old page exiting on a `replace()` |

**Reassigning** any of these properties at runtime takes effect for the _next_ operation — no restart needed.

---

## Page Lifecycle

### Attached signals

Every item inside a `StackView` can connect to these **attached signals**:

| Signal | Fires when… |
|---|---|
| `StackView.onActivated` | The page becomes the current (top) page |
| `StackView.onDeactivated` | The page is no longer the current page (pushed over or popped) |

### Attached properties

| Property | Description |
|---|---|
| `StackView.index` | Zero-based position in the stack (0 = bottom/root). |
| `StackView.status` | `StackView.Inactive \| StackView.Activating \| StackView.Active \| StackView.Deactivating` |
| `StackView.view` | Reference to the containing `StackView`. |

### `Component` signals (QML object lifetime)

| Signal | Meaning |
|---|---|
| `Component.onCompleted` | QML object has been fully constructed. |
| `Component.onDestruction` | QML object is about to be destroyed (e.g., after `pop()` or `clear()`). |

> **Key difference**: `StackView.onActivated` fires each time a page becomes active (including when it's revealed by `pop()`).  
> `Component.onCompleted` fires **once** — when the object is first created.

---

## Passing Properties to Pages

```qml
// push() second argument: initial properties applied before activation
stack.push(pageDComp, { pageTitle: "From B" })
```

The properties in the second argument are applied to the newly created item **before** `Component.onCompleted` fires, so they are available from the start.

---

## Transition Presets (in this explorer)

| Name | Technique |
|---|---|
| **Slide** | `x` from `stack.width → 0` on enter; reversed on pop |
| **Fade** | `opacity` 0 → 1 on enter / 1 → 0 on exit |
| **Scale** | `scale` 0.85 → 1.0 with `Easing.OutBack` for a spring pop |
| **None** | Empty `Transition {}` — instant switch |

---

## Explorer Controls

| Control | Action |
|---|---|
| Push Page A–D buttons | Push the selected page onto the stack |
| Push Page D (with props) | Demonstrates passing initial properties (`pageTitle`) |
| Pop ← | Pop the current top page |
| Pop to Root | `stack.pop(null)` — jump back to the root in one call |
| Replace → Page C | Replace current page without adding a back entry |
| Clear Stack | `stack.clear()` then push Page A as new root |
| Transition buttons | Switch all six transition properties at runtime |

---

## Key Takeaways

1. `push` / `pop` / `replace` are the three navigation verbs.
2. Transitions are **six independent properties** — enter and exit are separate for push, pop, and replace.
3. Pages are **destroyed** when popped (unless you retain a reference); do not store mutable state only inside a page if you need it to survive navigation.
4. Use `StackView.onActivated` for logic that should repeat each time a page is shown; use `Component.onCompleted` for one-time initialisation.
5. Passing `null` to `pop()` is the idiomatic way to jump back to the root page regardless of stack depth.
