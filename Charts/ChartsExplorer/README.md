# Charts Explorer

Interactive explorer for custom **Canvas 2D charts** in QML — Line, Bar, and Pie/Donut drawn entirely with `Canvas` and the 2D drawing API, fed by live data from a Python `QTimer`. No `QtCharts` dependency.

> **Why no QtCharts?** `ChartView` causes a C++ segfault (exit code -1073741819) in Qt 6.11 under certain platform/driver configurations. Custom `Canvas` charts are a portable, dependency-free alternative that also exposes every drawing primitive directly.

## Run

```bash
cd Charts/ChartsExplorer
python main.py
```

## Files

| File | Purpose |
|---|---|
| `charts_backend.py` | `ChartsBackend(QObject)` — `QTimer` emitting `newLinePoint(x, y)` and `resetLineSeries()` |
| `main.py` | Entry point — exposes `backend` context property |
| `ChartsExplorer.qml` | Three `Canvas` chart items (Line / Bar / Pie) in a `StackLayout` with control panel |

---

## Core Pattern: Python → Canvas Live Data

```
Python QTimer.timeout
    → ChartsBackend._tick()
    → emit newLinePoint(x, y)       ← Signal(float, float)

QML Connections { target: backend }
    → onNewLinePoint(x, y)
    → lineCanvas.livePoints.push({x, y})   ← plain JS array
    → lineCanvas.requestPaint()            ← schedules onPaint
```

Python owns data generation; QML owns rendering. They are decoupled by signals — the canvas just reads the array and redraws.

---

## Canvas 2D Basics

### Paint cycle

```qml
Canvas {
    id: myCanvas
    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)   // or fillRect for background
        // … drawing commands …
    }
    Component.onCompleted: requestPaint()   // first draw
    onWidthChanged:  requestPaint()         // redraw on resize
    onHeightChanged: requestPaint()
}
```

`requestPaint()` schedules `onPaint` for the next frame — never call it from *inside* `onPaint`.

### Coordinate helpers (used in all three charts)

```js
// Map data-space values to canvas pixels
function toX(v) { return pad.left + (v - xMin) / (xMax - xMin) * plotW }
function toY(v) { return pad.top + plotH - (v - yMin) / (yMax - yMin) * plotH }
```

Define these inside `onPaint` so they close over the current padding and range values.

---

## Line Chart

### Sliding-window live data

```js
// In Connections.onNewLinePoint:
lineCanvas.livePoints.push({ x: x, y: y })
if (lineCanvas.livePoints.length > 60)
    lineCanvas.livePoints.splice(0, 1)     // drop oldest point

// Scroll the x-axis to follow:
lineCanvas.xMin = livePoints[0].x
lineCanvas.xMax = livePoints[livePoints.length - 1].x + 2
lineCanvas.requestPaint()
```

### Smooth bezier curve (reference series)

```js
ctx.beginPath()
ctx.moveTo(toX(pts[0].x), toY(pts[0].y))
for (var i = 1; i < pts.length; i++) {
    var px = toX(pts[i-1].x), py = toY(pts[i-1].y)
    var nx = toX(pts[i].x),   ny = toY(pts[i].y)
    var cpx = (px + nx) / 2
    ctx.bezierCurveTo(cpx, py, cpx, ny, nx, ny)  // midpoint control-point trick
}
ctx.stroke()
```

This produces smooth curves identical to `SplineSeries` without any QtCharts types.

---

## Bar Chart

### Adaptive bar width

```js
var active = (showA ? 1 : 0) + (showB ? 1 : 0)
var barW   = active > 0 ? groupW * 0.58 / active : groupW * 0.29
```

The bar width adjusts automatically when one series is hidden.

### Updating data

```qml
// Assign a new JS array and repaint — no model needed
barCanvas.dataA = [42, 67, 28, 85, 53, 71]
barCanvas.requestPaint()
```

---

## Pie / Donut Chart

### Drawing slices

```js
var angle = -Math.PI / 2    // start from top (12 o'clock)
for (var si = 0; si < slices.length; si++) {
    var sweep = (slices[si].value / total) * Math.PI * 2
    ctx.beginPath()
    ctx.moveTo(CX, CY)
    ctx.arc(CX, CY, R, angle, angle + sweep)
    ctx.closePath()
    ctx.fillStyle = slices[si].color
    ctx.fill()
    angle += sweep
}
```

### Donut cutout (counter-clockwise arc)

```js
if (HR > 0) {
    ctx.arc(CX + ox, CY + oy, R,  angle, angle + sweep)          // outer arc
    ctx.arc(CX + ox, CY + oy, HR, angle + sweep, angle, true)    // inner arc, reversed
} else {
    ctx.moveTo(CX + ox, CY + oy)
    ctx.arc(CX + ox, CY + oy, R, angle, angle + sweep)
}
ctx.closePath()
```

The `true` (anticlockwise) flag on the inner arc produces the donut hole.

### Slice hit-testing (MouseArea click)

```js
// Convert click to angle, then walk the sweep accumulation:
var ang = Math.atan2(mouse.y - CY, mouse.x - CX) + Math.PI / 2
if (ang < 0) ang += Math.PI * 2

var a = 0
for (var si = 0; si < slices.length; si++) {
    var sweep = (slices[si].value / total) * Math.PI * 2
    if (ang >= a && ang < a + sweep) { /* hit slice si */ break }
    a += sweep
}
```

### Explosion (copy-on-write JS object as a set)

```js
// Toggle one slice:
var ns = Object.assign({}, pieItem.explodedSet)   // shallow copy
if (ns.hasOwnProperty(key)) delete ns[key]; else ns[key] = true
pieItem.explodedSet = ns    // assignment triggers QML binding update
pieCanvas.requestPaint()

// Explode all:
var ns = {}
for (var i = 0; i < slices.length; i++) ns[i.toString()] = true
pieItem.explodedSet = ns
```

Using a plain JS object as a set avoids mutable-array reactivity pitfalls. Every mutation creates a new object, which triggers QML property bindings.

---

## Explorer Controls

| Chart | Control | Canvas technique |
|---|---|---|
| Line | Start / Stop | `backend.startLive()` / `stopLive()` → Connections → `requestPaint()` |
| Line | Reset Series | `livePoints = []` + `requestPaint()` |
| Line | Interval slider | `backend.setInterval(ms)` |
| Line | Series visibility | `showRef` / `showLive` bool props → guard in `onPaint` |
| Line | Live Info | Reactive `root.liveCount`, `root.liveXMin/XMax` props |
| Bar | Randomize A / B | New array assigned to `dataA` / `dataB` + `requestPaint()` |
| Bar | Reset | Literal array assigned + `requestPaint()` |
| Bar | Visibility | `showA` / `showB` props → adaptive `barW` calc in `onPaint` |
| Pie | Explode All | `explodedSet` filled + `requestPaint()` |
| Pie | Collapse All | `explodedSet = {}` + `requestPaint()` |
| Pie | Hole size slider | `pieItem.holeSize = value` + `requestPaint()` |
| Pie | Click a slice | `MouseArea` hit-test → toggle key in `explodedSet` |

---

## Key Takeaways

1. `requestPaint()` schedules one repaint — call it whenever your data changes, never from inside `onPaint`.
2. QML `var` arrays are opaque to the binding system; mutate via push/splice then call `requestPaint()` explicitly. For reactive properties, use a separate counter or reassign the array.
3. The bezier midpoint trick (`cpx = (px + nx) / 2`, two identical control points) gives smooth curves without a spline library.
4. `Object.assign({}, obj)` is the correct way to copy-on-write a plain JS object used as a set, so QML property assignment triggers bindings.
5. Pie hit-testing requires `Math.atan2` + `Math.PI / 2` offset (to match the 12-o'clock start) and a simple sweep accumulator — no extra libraries needed.

