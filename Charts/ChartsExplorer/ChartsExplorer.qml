import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ─────────────────────────────────────────────────────────────────────────────
//  ChartsExplorer  –  Custom Canvas-based charts (no QtCharts dependency)
//  Demonstrates: Canvas 2D drawing API, live data, bar/pie/line charts
// ─────────────────────────────────────────────────────────────────────────────
ApplicationWindow {
    id: root
    visible: true
    width: 1100
    height: 700
    title: "Charts Explorer"
    color: "#1e1e2e"

    // ── Palette ───────────────────────────────────────────────────────────────
    readonly property color surface:   "#313244"
    readonly property color dimBg:     "#45475a"
    readonly property color textMain:  "#cdd6f4"
    readonly property color accent:    "#cba6f7"
    readonly property color subtext:   "#6c7086"
    readonly property color clrGreen:  "#a6e3a1"
    readonly property color clrRed:    "#f38ba8"
    readonly property color clrBlue:   "#89b4fa"
    readonly property color clrOrange: "#fab387"
    readonly property color clrYellow: "#f9e2af"

    // ── Reusable components ───────────────────────────────────────────────────
    component ActionBtn: Button {
        property color btnColor: root.accent
        implicitHeight: 34
        contentItem: Text {
            text: parent.text
            color: "#1e1e2e"
            font { family: "Segoe UI"; pixelSize: 13; bold: true }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.down    ? Qt.darker(parent.btnColor, 1.25)
                 : parent.hovered ? Qt.lighter(parent.btnColor, 1.12)
                 : parent.btnColor
            radius: 6
        }
    }

    component Divider: Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: root.dimBg
    }

    component SectionLabel: Text {
        color: root.subtext
        font { family: "Segoe UI"; pixelSize: 11; bold: true }
    }

    component ToggleBtn: Button {
        property color onColor: root.clrGreen
        implicitWidth: 56
        implicitHeight: 28
        checkable: true
        contentItem: Text {
            text: parent.checked ? "ON" : "OFF"
            color: parent.checked ? "#1e1e2e" : root.textMain
            font { family: "Segoe UI"; pixelSize: 12; bold: true }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color: parent.checked ? parent.onColor : root.dimBg
            radius: 6
        }
    }

    // ── State ─────────────────────────────────────────────────────────────────
    property int    chartIndex:  0
    property bool   liveRunning: false
    property string statusMsg:   "Select a chart type above, then use the control panel."
    property int    liveCount:   0
    property real   liveXMin:    0.0
    property real   liveXMax:    30.0

    function status(msg) { root.statusMsg = msg }

    // ═════════════════════════════════════════════════════════════════════════
    //  Live-data connection  (Python QTimer → Canvas)
    //  Pattern: push to plain JS array, call requestPaint()
    // ═════════════════════════════════════════════════════════════════════════
    Connections {
        target: backend

        function onNewLinePoint(x, y) {
            lineCanvas.livePoints.push({ x: x, y: y })
            if (lineCanvas.livePoints.length > 60)
                lineCanvas.livePoints.splice(0, 1)
            if (lineCanvas.livePoints.length > 1) {
                root.liveXMin = lineCanvas.livePoints[0].x
                root.liveXMax = lineCanvas.livePoints[lineCanvas.livePoints.length - 1].x + 2
            }
            lineCanvas.xMin = root.liveXMin
            lineCanvas.xMax = root.liveXMax
            root.liveCount  = lineCanvas.livePoints.length
            lineCanvas.requestPaint()
            root.status("Live → (" + x.toFixed(1) + ",\u2009" + y.toFixed(1)
                        + ")   points: " + lineCanvas.livePoints.length)
        }

        function onResetLineSeries() {
            lineCanvas.livePoints = []
            lineCanvas.xMin  = 0;   lineCanvas.xMax = 30
            root.liveXMin    = 0;   root.liveXMax   = 30
            root.liveCount   = 0
            lineCanvas.requestPaint()
            root.status("Series cleared")
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    //  Root layout
    // ═════════════════════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Title bar + chart-type selector ──────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            color: root.surface

            RowLayout {
                anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                spacing: 10

                Text {
                    text: "Charts Explorer"
                    color: root.textMain
                    font { family: "Segoe UI"; pixelSize: 18; bold: true }
                }
                Item { Layout.fillWidth: true }

                Repeater {
                    model: ["Line", "Bar", "Pie"]
                    delegate: Button {
                        required property string modelData
                        required property int    index
                        implicitWidth: 80; implicitHeight: 32
                        contentItem: Text {
                            text: parent.modelData
                            color: root.chartIndex === parent.index ? "#1e1e2e" : root.textMain
                            font {
                                family: "Segoe UI"; pixelSize: 13
                                bold: root.chartIndex === parent.index
                            }
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: root.chartIndex === parent.index ? root.accent
                                 : parent.hovered ? root.dimBg : "transparent"
                            radius: 6
                        }
                        onClicked: {
                            root.chartIndex = index
                            root.status(modelData + " chart")
                        }
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: root.dimBg }

        // ── Main area ─────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ── Charts area ───────────────────────────────────────────────────
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.chartIndex

                // ── 0 · Line Chart  (Canvas 2D) ───────────────────────────────
                Canvas {
                    id: lineCanvas

                    property var  refPoints:  []
                    property var  livePoints: []
                    property bool showRef:    true
                    property bool showLive:   true
                    property real xMin:       0
                    property real xMax:       30
                    readonly property real yMin: 0
                    readonly property real yMax: 100

                    Component.onCompleted: {
                        for (var t = 0.0; t <= 30.0; t += 0.5)
                            refPoints.push({ x: t, y: Math.sin(t * 0.4) * 35 + 50 })
                        requestPaint()
                    }

                    onWidthChanged:  requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        var W = width, H = height
                        var pad = { top: 28, bottom: 38, left: 50, right: 20 }
                        var plotW = W - pad.left - pad.right
                        var plotH = H - pad.top  - pad.bottom

                        // Background
                        ctx.fillStyle = "#1e1e2e"; ctx.fillRect(0, 0, W, H)
                        ctx.fillStyle = "#11111b"; ctx.fillRect(pad.left, pad.top, plotW, plotH)

                        // Coord helpers (must be declared before use)
                        var xMinL = xMin, xMaxL = xMax, yMinL = yMin, yMaxL = yMax
                        function toX(v) { return pad.left + (v - xMinL) / (xMaxL - xMinL) * plotW }
                        function toY(v) { return pad.top + plotH - (v - yMinL) / (yMaxL - yMinL) * plotH }

                        // Horizontal grid lines + Y labels
                        ctx.strokeStyle = "#313244"; ctx.lineWidth = 1
                        for (var yi = 0; yi <= 5; yi++) {
                            var yv = yMinL + yi * (yMaxL - yMinL) / 5
                            var gy = toY(yv)
                            ctx.beginPath(); ctx.moveTo(pad.left, gy)
                            ctx.lineTo(pad.left + plotW, gy); ctx.stroke()
                            ctx.fillStyle = "#6c7086"; ctx.font = "11px Consolas"
                            ctx.textAlign = "right"
                            ctx.fillText(yv.toFixed(0), pad.left - 6, gy + 4)
                        }
                        // Vertical grid lines + X labels
                        for (var xi = 0; xi <= 6; xi++) {
                            var xv = xMinL + xi * (xMaxL - xMinL) / 6
                            var gx = toX(xv)
                            ctx.beginPath(); ctx.moveTo(gx, pad.top)
                            ctx.lineTo(gx, pad.top + plotH); ctx.stroke()
                            ctx.fillStyle = "#6c7086"; ctx.font = "11px Consolas"
                            ctx.textAlign = "center"
                            ctx.fillText(xv.toFixed(1), gx, pad.top + plotH + 18)
                        }

                        // Reference series (smooth bezier)
                        if (showRef && refPoints.length > 1) {
                            ctx.strokeStyle = "#cba6f7"; ctx.lineWidth = 2
                            ctx.beginPath()
                            ctx.moveTo(toX(refPoints[0].x), toY(refPoints[0].y))
                            for (var ri = 1; ri < refPoints.length; ri++) {
                                var px = toX(refPoints[ri - 1].x), py = toY(refPoints[ri - 1].y)
                                var nx = toX(refPoints[ri].x),     ny = toY(refPoints[ri].y)
                                var cpx = (px + nx) / 2
                                ctx.bezierCurveTo(cpx, py, cpx, ny, nx, ny)
                            }
                            ctx.stroke()
                        }

                        // Live series (straight line segments)
                        if (showLive && livePoints.length > 1) {
                            ctx.strokeStyle = "#a6e3a1"; ctx.lineWidth = 2
                            ctx.beginPath()
                            ctx.moveTo(toX(livePoints[0].x), toY(livePoints[0].y))
                            for (var li = 1; li < livePoints.length; li++)
                                ctx.lineTo(toX(livePoints[li].x), toY(livePoints[li].y))
                            ctx.stroke()
                        }

                        // Legend
                        var lgY = pad.top + 16
                        var lgX = pad.left + 12
                        if (showRef) {
                            ctx.strokeStyle = "#cba6f7"; ctx.lineWidth = 2
                            ctx.beginPath(); ctx.moveTo(lgX, lgY); ctx.lineTo(lgX + 20, lgY); ctx.stroke()
                            ctx.fillStyle = "#6c7086"; ctx.font = "11px 'Segoe UI'"
                            ctx.textAlign = "left"
                            ctx.fillText("Reference (sine)", lgX + 24, lgY + 4)
                            lgX += 158
                        }
                        if (showLive) {
                            ctx.strokeStyle = "#a6e3a1"; ctx.lineWidth = 2
                            ctx.beginPath(); ctx.moveTo(lgX, lgY); ctx.lineTo(lgX + 20, lgY); ctx.stroke()
                            ctx.fillStyle = "#6c7086"; ctx.font = "11px 'Segoe UI'"
                            ctx.textAlign = "left"
                            ctx.fillText("Live (noise)", lgX + 24, lgY + 4)
                        }
                    }
                }

                // ── 1 · Bar Chart  (Canvas 2D) ────────────────────────────────
                Canvas {
                    id: barCanvas

                    property var  dataA:  [42, 67, 28, 85, 53, 71]
                    property var  dataB:  [31, 55, 72, 40, 88, 35]
                    property bool showA:  true
                    property bool showB:  true

                    Component.onCompleted: requestPaint()
                    onWidthChanged:  requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        var W = width, H = height
                        var pad = { top: 28, bottom: 38, left: 50, right: 20 }
                        var plotW = W - pad.left - pad.right
                        var plotH = H - pad.top  - pad.bottom
                        var yMax  = 110
                        var cats  = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
                        var n     = cats.length

                        ctx.fillStyle = "#1e1e2e"; ctx.fillRect(0, 0, W, H)
                        ctx.fillStyle = "#11111b"; ctx.fillRect(pad.left, pad.top, plotW, plotH)

                        // Horizontal grid + Y labels
                        ctx.strokeStyle = "#313244"; ctx.lineWidth = 1
                        for (var yi = 0; yi <= 5; yi++) {
                            var yv = yi * yMax / 5
                            var gy = pad.top + plotH - (yv / yMax) * plotH
                            ctx.beginPath(); ctx.moveTo(pad.left, gy)
                            ctx.lineTo(pad.left + plotW, gy); ctx.stroke()
                            ctx.fillStyle = "#6c7086"; ctx.font = "11px Consolas"
                            ctx.textAlign = "right"
                            ctx.fillText(yv.toFixed(0), pad.left - 6, gy + 4)
                        }

                        // Bars + category labels
                        var groupW = plotW / n
                        var active = (showA ? 1 : 0) + (showB ? 1 : 0)
                        var barW   = active > 0 ? groupW * 0.58 / active : groupW * 0.29
                        var gap    = groupW * 0.04

                        for (var i = 0; i < n; i++) {
                            var bx = pad.left + i * groupW + groupW * 0.21
                            if (showA) {
                                var hA = (dataA[i] / yMax) * plotH
                                ctx.fillStyle = "#89b4fa"
                                ctx.fillRect(bx, pad.top + plotH - hA, barW, hA)
                                bx += barW + gap
                            }
                            if (showB) {
                                var hB = (dataB[i] / yMax) * plotH
                                ctx.fillStyle = "#cba6f7"
                                ctx.fillRect(bx, pad.top + plotH - hB, barW, hB)
                            }
                            ctx.fillStyle = "#6c7086"; ctx.font = "11px 'Segoe UI'"
                            ctx.textAlign = "center"
                            ctx.fillText(cats[i], pad.left + i * groupW + groupW / 2, pad.top + plotH + 18)
                        }

                        // Legend
                        var lgY = pad.top + 16
                        var lgX = pad.left + 12
                        if (showA) {
                            ctx.fillStyle = "#89b4fa"; ctx.fillRect(lgX, lgY - 10, 14, 12)
                            ctx.fillStyle = "#6c7086"; ctx.font = "11px 'Segoe UI'"; ctx.textAlign = "left"
                            ctx.fillText("Series A", lgX + 18, lgY)
                            lgX += 90
                        }
                        if (showB) {
                            ctx.fillStyle = "#cba6f7"; ctx.fillRect(lgX, lgY - 10, 14, 12)
                            ctx.fillStyle = "#6c7086"; ctx.font = "11px 'Segoe UI'"; ctx.textAlign = "left"
                            ctx.fillText("Series B", lgX + 18, lgY)
                        }
                    }
                }

                // ── 2 · Pie / Donut Chart  (Canvas 2D + MouseArea) ────────────
                Item {
                    id: pieItem

                    property var slices: [
                        { label: "Frontend", value: 30, color: "#89b4fa" },
                        { label: "Backend",  value: 25, color: "#a6e3a1" },
                        { label: "DevOps",   value: 20, color: "#cba6f7" },
                        { label: "Mobile",   value: 15, color: "#fab387" },
                        { label: "Data",     value: 10, color: "#f9e2af" }
                    ]
                    property var  explodedSet: ({})
                    property real holeSize:    0.0

                    Canvas {
                        id: pieCanvas
                        anchors.fill: parent

                        Component.onCompleted: requestPaint()
                        onWidthChanged:  requestPaint()
                        onHeightChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d")
                            var W = width, H = height
                            ctx.fillStyle = "#1e1e2e"; ctx.fillRect(0, 0, W, H)

                            var slices = pieItem.slices
                            var total  = 0
                            for (var i = 0; i < slices.length; i++) total += slices[i].value

                            var CX = W * 0.38
                            var CY = H / 2
                            var R  = Math.min(W * 0.32, H * 0.40)
                            var HR = R * pieItem.holeSize

                            var angle = -Math.PI / 2
                            for (var si = 0; si < slices.length; si++) {
                                var s     = slices[si]
                                var sweep = (s.value / total) * Math.PI * 2
                                var mid   = angle + sweep / 2
                                var expl  = pieItem.explodedSet.hasOwnProperty(si.toString())
                                var ox    = expl ? Math.cos(mid) * 18 : 0
                                var oy    = expl ? Math.sin(mid) * 18 : 0

                                ctx.beginPath()
                                if (HR > 0) {
                                    ctx.arc(CX + ox, CY + oy, R,  angle, angle + sweep)
                                    ctx.arc(CX + ox, CY + oy, HR, angle + sweep, angle, true)
                                } else {
                                    ctx.moveTo(CX + ox, CY + oy)
                                    ctx.arc(CX + ox, CY + oy, R, angle, angle + sweep)
                                }
                                ctx.closePath()
                                ctx.fillStyle   = s.color; ctx.fill()
                                ctx.strokeStyle = "#1e1e2e"; ctx.lineWidth = 2; ctx.stroke()

                                angle += sweep
                            }

                            // Legend (right side)
                            var lgX      = W * 0.72
                            var lgStartY = H / 2 - slices.length * 18
                            for (var li = 0; li < slices.length; li++) {
                                var ls = slices[li]
                                var ly = lgStartY + li * 34
                                ctx.fillStyle = ls.color; ctx.fillRect(lgX, ly, 14, 14)
                                ctx.fillStyle = "#cdd6f4"; ctx.font = "13px 'Segoe UI'"; ctx.textAlign = "left"
                                ctx.fillText(ls.label, lgX + 20, ly + 12)
                                ctx.fillStyle = "#6c7086"; ctx.font = "11px Consolas"
                                ctx.fillText((ls.value / total * 100).toFixed(1) + "%", lgX + 20, ly + 26)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: function(mouse) {
                            var CX   = width * 0.38
                            var CY   = height / 2
                            var R    = Math.min(width * 0.32, height * 0.40)
                            var HR   = R * pieItem.holeSize
                            var dx   = mouse.x - CX
                            var dy   = mouse.y - CY
                            var dist = Math.sqrt(dx * dx + dy * dy)

                            if (dist > HR && dist <= R) {
                                var slices = pieItem.slices
                                var total  = 0
                                for (var i = 0; i < slices.length; i++) total += slices[i].value

                                var ang = Math.atan2(dy, dx) + Math.PI / 2
                                if (ang < 0) ang += Math.PI * 2

                                var a = 0
                                for (var si = 0; si < slices.length; si++) {
                                    var sweep = (slices[si].value / total) * Math.PI * 2
                                    if (ang >= a && ang < a + sweep) {
                                        var key = si.toString()
                                        var ns  = Object.assign({}, pieItem.explodedSet)
                                        if (ns.hasOwnProperty(key)) delete ns[key]; else ns[key] = true
                                        pieItem.explodedSet = ns
                                        pieCanvas.requestPaint()
                                        var pct = (slices[si].value / total * 100).toFixed(1)
                                        root.status("Clicked: " + slices[si].label + "  " + pct + "%"
                                                    + (ns.hasOwnProperty(key) ? "  [exploded]" : ""))
                                        break
                                    }
                                    a += sweep
                                }
                            }
                        }
                    }
                }
            }

            // Right divider
            Rectangle { width: 1; Layout.fillHeight: true; color: root.dimBg }

            // ── Control panel ─────────────────────────────────────────────────
            Rectangle {
                implicitWidth: 252
                Layout.fillHeight: true
                color: root.surface

                ScrollView {
                    id: ctrlScroll
                    anchors { fill: parent; margins: 12 }
                    clip: true
                    contentWidth: availableWidth

                    ColumnLayout {
                        width: ctrlScroll.availableWidth
                        spacing: 10

                        // ─── Line controls ────────────────────────────────────
                        ColumnLayout {
                            visible: root.chartIndex === 0
                            Layout.fillWidth: true
                            spacing: 10

                            SectionLabel { text: "LIVE DATA" }
                            Divider {}

                            ActionBtn {
                                Layout.fillWidth: true
                                text: root.liveRunning ? "⏹  Stop" : "▶  Start"
                                btnColor: root.liveRunning ? root.clrRed : root.clrGreen
                                onClicked: {
                                    if (root.liveRunning) {
                                        backend.stopLive()
                                        root.liveRunning = false
                                        root.status("Live updates stopped")
                                    } else {
                                        backend.startLive()
                                        root.liveRunning = true
                                        root.status("Live updates started")
                                    }
                                }
                            }
                            ActionBtn {
                                Layout.fillWidth: true
                                text: "Reset Series"
                                btnColor: root.clrYellow
                                onClicked: backend.resetLine()
                            }

                            SectionLabel { text: "INTERVAL" }
                            Text {
                                Layout.fillWidth: true
                                text: intervalSlider.value.toFixed(0) + " ms"
                                color: root.textMain
                                font { family: "Consolas"; pixelSize: 12 }
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Slider {
                                id: intervalSlider
                                Layout.fillWidth: true
                                from: 100; to: 2000; value: 500; stepSize: 50
                                onValueChanged: backend.setInterval(value)
                                background: Rectangle {
                                    x: intervalSlider.leftPadding
                                    y: intervalSlider.topPadding + intervalSlider.availableHeight / 2 - height / 2
                                    width: intervalSlider.availableWidth; height: 4; radius: 2
                                    color: root.dimBg
                                    Rectangle {
                                        width: intervalSlider.visualPosition * parent.width
                                        height: parent.height; radius: 2; color: root.accent
                                    }
                                }
                                handle: Rectangle {
                                    x: intervalSlider.leftPadding + intervalSlider.visualPosition * (intervalSlider.availableWidth - width)
                                    y: intervalSlider.topPadding + intervalSlider.availableHeight / 2 - height / 2
                                    width: 16; height: 16; radius: 8; color: root.accent
                                }
                            }

                            SectionLabel { text: "SERIES VISIBILITY" }
                            Divider {}
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Live series"; color: root.textMain
                                    font { family: "Segoe UI"; pixelSize: 13 }
                                    Layout.fillWidth: true
                                }
                                ToggleBtn {
                                    checked: true; onColor: root.clrGreen
                                    onToggled: { lineCanvas.showLive = checked; lineCanvas.requestPaint() }
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Reference"; color: root.textMain
                                    font { family: "Segoe UI"; pixelSize: 13 }
                                    Layout.fillWidth: true
                                }
                                ToggleBtn {
                                    checked: true; onColor: root.accent
                                    onToggled: { lineCanvas.showRef = checked; lineCanvas.requestPaint() }
                                }
                            }

                            SectionLabel { text: "LIVE INFO" }
                            Divider {}
                            Text {
                                Layout.fillWidth: true
                                text: "points: " + root.liveCount
                                color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "xMin: " + root.liveXMin.toFixed(1)
                                color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "xMax: " + root.liveXMax.toFixed(1)
                                color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                            }
                        }

                        // ─── Bar controls ─────────────────────────────────────
                        ColumnLayout {
                            visible: root.chartIndex === 1
                            Layout.fillWidth: true
                            spacing: 10

                            SectionLabel { text: "BAR SETS" }
                            Divider {}

                            ActionBtn {
                                Layout.fillWidth: true
                                text: "Randomize Series A"
                                btnColor: root.clrBlue
                                onClicked: {
                                    var a = []
                                    for (var i = 0; i < 6; i++) a.push(Math.random() * 90 + 5)
                                    barCanvas.dataA = a
                                    barCanvas.requestPaint()
                                    root.status("Series A randomized  (Canvas.requestPaint)")
                                }
                            }
                            ActionBtn {
                                Layout.fillWidth: true
                                text: "Randomize Series B"
                                btnColor: root.accent
                                onClicked: {
                                    var b = []
                                    for (var i = 0; i < 6; i++) b.push(Math.random() * 90 + 5)
                                    barCanvas.dataB = b
                                    barCanvas.requestPaint()
                                    root.status("Series B randomized  (Canvas.requestPaint)")
                                }
                            }
                            ActionBtn {
                                Layout.fillWidth: true
                                text: "Reset to Original"
                                btnColor: root.clrYellow
                                onClicked: {
                                    barCanvas.dataA = [42, 67, 28, 85, 53, 71]
                                    barCanvas.dataB = [31, 55, 72, 40, 88, 35]
                                    barCanvas.requestPaint()
                                    root.status("Bar values reset")
                                }
                            }

                            SectionLabel { text: "VISIBILITY" }
                            Divider {}
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Series A"; color: root.textMain
                                    font { family: "Segoe UI"; pixelSize: 13 }
                                    Layout.fillWidth: true
                                }
                                ToggleBtn {
                                    checked: true; onColor: root.clrBlue
                                    onToggled: { barCanvas.showA = checked; barCanvas.requestPaint() }
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Series B"; color: root.textMain
                                    font { family: "Segoe UI"; pixelSize: 13 }
                                    Layout.fillWidth: true
                                }
                                ToggleBtn {
                                    checked: true; onColor: root.accent
                                    onToggled: { barCanvas.showB = checked; barCanvas.requestPaint() }
                                }
                            }

                            SectionLabel { text: "BAR INFO" }
                            Divider {}
                            Text {
                                Layout.fillWidth: true
                                text: "sets: 2   bars per set: 6"
                                color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "categories: Jan \u2013 Jun"
                                color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                            }
                        }

                        // ─── Pie controls ─────────────────────────────────────
                        ColumnLayout {
                            visible: root.chartIndex === 2
                            Layout.fillWidth: true
                            spacing: 10

                            SectionLabel { text: "SLICES" }
                            Divider {}

                            ActionBtn {
                                Layout.fillWidth: true
                                text: "Explode All"
                                btnColor: root.clrOrange
                                onClicked: {
                                    var ns = {}
                                    for (var i = 0; i < pieItem.slices.length; i++) ns[i.toString()] = true
                                    pieItem.explodedSet = ns
                                    pieCanvas.requestPaint()
                                    root.status("All slices exploded")
                                }
                            }
                            ActionBtn {
                                Layout.fillWidth: true
                                text: "Collapse All"
                                btnColor: root.clrGreen
                                onClicked: {
                                    pieItem.explodedSet = {}
                                    pieCanvas.requestPaint()
                                    root.status("All slices collapsed")
                                }
                            }

                            SectionLabel { text: "HOLE SIZE  (donut)" }
                            Text {
                                Layout.fillWidth: true
                                text: (holeSlider.value * 100).toFixed(0) + "%"
                                color: root.textMain
                                font { family: "Consolas"; pixelSize: 12 }
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Slider {
                                id: holeSlider
                                Layout.fillWidth: true
                                from: 0.0; to: 0.7; value: 0.0; stepSize: 0.05
                                onValueChanged: {
                                    pieItem.holeSize = value
                                    pieCanvas.requestPaint()
                                }
                                background: Rectangle {
                                    x: holeSlider.leftPadding
                                    y: holeSlider.topPadding + holeSlider.availableHeight / 2 - height / 2
                                    width: holeSlider.availableWidth; height: 4; radius: 2
                                    color: root.dimBg
                                    Rectangle {
                                        width: holeSlider.visualPosition * parent.width
                                        height: parent.height; radius: 2; color: root.clrOrange
                                    }
                                }
                                handle: Rectangle {
                                    x: holeSlider.leftPadding + holeSlider.visualPosition * (holeSlider.availableWidth - width)
                                    y: holeSlider.topPadding + holeSlider.availableHeight / 2 - height / 2
                                    width: 16; height: 16; radius: 8; color: root.clrOrange
                                }
                            }

                            SectionLabel { text: "PIE INFO" }
                            Divider {}
                            Text {
                                Layout.fillWidth: true
                                text: "slices: " + pieItem.slices.length
                                color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "holeSize: " + pieItem.holeSize.toFixed(2)
                                color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "click a slice to explode it"
                                color: root.subtext; font { family: "Segoe UI"; pixelSize: 11 }
                                wrapMode: Text.WordWrap
                            }
                        }

                        Item { implicitHeight: 20 }
                    }
                }
            }
        }

        // ── Status bar ────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 28
            color: root.dimBg
            Text {
                anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                text: root.statusMsg
                color: root.subtext
                font { family: "Consolas"; pixelSize: 12 }
            }
        }
    }
}

