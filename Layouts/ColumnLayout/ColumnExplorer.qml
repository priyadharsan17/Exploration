import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ══════════════════════════════════════════════════════════════════
//  WINDOW 1 — Playground  (full-screen canvas, no side panel)
// ══════════════════════════════════════════════════════════════════
ApplicationWindow {
    id: playWin
    visible: true
    width: 700
    height: 700
    minimumWidth: 300
    minimumHeight: 200
    title: "ColumnLayout Playground  —  resize me freely!"
    color: "#1e1e2e"

    // ── Palette ──────────────────────────────────────────────────
    readonly property color surface:     "#313244"
    readonly property color accentDim:   "#45475a"
    readonly property color textPrimary: "#cdd6f4"
    readonly property color accent:      "#cba6f7"
    readonly property var cellColors: [
        "#f38ba8","#fab387","#f9e2af",
        "#a6e3a1","#89dceb","#89b4fa","#cba6f7","#f38ba8"
    ]

    // ── Hint banner ───────────────────────────────────────────────
    Rectangle {
        id: hint
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        anchors.topMargin: 10
        width: hintText.implicitWidth + 24
        height: 28
        radius: 14
        color: playWin.accentDim
        Text {
            id: hintText
            anchors.centerIn: parent
            text: "Resize this window ↔ ↕  |  Controls are in the Properties window"
            font.family: "Segoe UI"; font.pixelSize: 11
            color: playWin.textPrimary
        }
    }

    // ── The ColumnLayout under study ─────────────────────────────
    ColumnLayout {
        id: col
        anchors {
            top: hint.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 20
            topMargin: 10
        }

        spacing:         spacingSpin.value
        layoutDirection: dirCombo.currentIndex === 0 ? Qt.LeftToRight : Qt.RightToLeft

        Repeater {
            model: cellCountSpin.value
            delegate: Rectangle {
                // ── per-item attached properties ─────────────────
                Layout.fillWidth:   fillWidthCheck.checked
                Layout.fillHeight:  fillHeightCheck.checked

                Layout.preferredWidth:  prefWSpin.value  > 0 ? prefWSpin.value  : -1
                Layout.preferredHeight: prefHSpin.value  > 0 ? prefHSpin.value  : -1
                Layout.minimumWidth:    minWSpin.value   > 0 ? minWSpin.value   : -1
                Layout.minimumHeight:   minHSpin.value   > 0 ? minHSpin.value   : -1
                Layout.maximumWidth:    maxWSpin.value   > 0 ? maxWSpin.value   : 99999
                Layout.maximumHeight:   maxHSpin.value   > 0 ? maxHSpin.value   : 99999

                // margins — only on the highlighted target cell
                Layout.topMargin:    (index === targetSpin.value - 1) ? topMargSpin.value    : 0
                Layout.bottomMargin: (index === targetSpin.value - 1) ? bottomMargSpin.value : 0
                Layout.leftMargin:   (index === targetSpin.value - 1) ? leftMargSpin.value   : 0
                Layout.rightMargin:  (index === targetSpin.value - 1) ? rightMargSpin.value  : 0

                Layout.alignment:
                    (alignHCombo.currentIndex === 0 ? Qt.AlignLeft
                   : alignHCombo.currentIndex === 1 ? Qt.AlignHCenter
                   : Qt.AlignRight)
                  | (alignVCombo.currentIndex === 0 ? Qt.AlignTop
                   : alignVCombo.currentIndex === 1 ? Qt.AlignVCenter
                   : Qt.AlignBottom)

                color:  playWin.cellColors[index % playWin.cellColors.length]
                radius: 6
                // White border on the target cell
                border.color: (index === targetSpin.value - 1) ? "white" : "transparent"
                border.width: 2

                // Fallback implicit height when nothing else sets it
                implicitHeight: 40

                Text {
                    anchors.centerIn: parent
                    text: index + 1
                    font.pixelSize: 14; font.bold: true
                    color: "#1e1e2e"
                }

                HoverHandler { id: hov }
                ToolTip.visible: hov.hovered
                ToolTip.text:
                    "Cell " + (index+1) +
                    "\nw=" + Math.round(width)  + "  h=" + Math.round(height) +
                    "\nx=" + Math.round(x)      + "  y=" + Math.round(y)
            }
        }
    }

    // ── Open controls window on start ────────────────────────────
    Component.onCompleted: ctrlWin.show()

    // ══════════════════════════════════════════════════════════════════
    //  WINDOW 2 — Properties / Controls  (nested child = separate OS window)
    // ══════════════════════════════════════════════════════════════════
    Window {
    id: ctrlWin
    title: "ColumnLayout Properties"
    width: 340
    height: 740
    minimumWidth: 300
    minimumHeight: 400
    color: "#1e1e2e"
    flags: Qt.Window | Qt.WindowStaysOnTopHint

    // Position next to the playground on launch
    Component.onCompleted: {
        x = playWin.x + playWin.width + 10
        y = playWin.y
    }

    // ── Palette shortcuts ─────────────────────────────────────────
    readonly property color surface:     "#313244"
    readonly property color accentDim:   "#45475a"
    readonly property color textPrimary: "#cdd6f4"
    readonly property color accent:      "#cba6f7"
    readonly property font  monoFont:    Qt.font({ family: "Consolas", pixelSize: 12 })
    readonly property font  labelFont:   Qt.font({ family: "Segoe UI",  pixelSize: 12 })

    // ── Title bar ─────────────────────────────────────────────────
    Rectangle {
        id: ctrlTitle
        width: parent.width; height: 36
        color: ctrlWin.accentDim
        Text {
            anchors.centerIn: parent
            text: "ColumnLayout Properties"
            font.family: "Segoe UI"; font.bold: true; font.pixelSize: 13
            color: ctrlWin.textPrimary
        }
    }

    // ── Scrollable form ──────────────────────────────────────────
    ScrollView {
        id: sv
        anchors {
            top: ctrlTitle.bottom; left: parent.left
            right: parent.right;   bottom: liveBox.top
            margins: 10; bottomMargin: 6
        }
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: sv.availableWidth
            spacing: 6

            // ── inline section-header component ───────────────────
            component SectionHeader: Rectangle {
                property alias text: sLbl.text
                Layout.fillWidth: true
                height: 24; radius: 4
                color: ctrlWin.accentDim
                Text {
                    id: sLbl
                    anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                    font.family: "Consolas"; font.pixelSize: 12; font.bold: true
                    color: ctrlWin.accent
                }
            }

            // ════════════════════════════════════════════════
            //  1. Layout Structure
            // ════════════════════════════════════════════════
            SectionHeader { text: "1 · Layout Structure" }

            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Cell Count"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: cellCountSpin; Layout.fillWidth: true; from: 1; to: 8; value: 4; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Spacing (px)"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: spacingSpin; Layout.fillWidth: true; from: 0; to: 80; value: 8; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Direction"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                ComboBox { id: dirCombo; Layout.fillWidth: true; model: ["TopToBottom", "BottomToTop"]; font: ctrlWin.monoFont }
            }

            // ════════════════════════════════════════════════
            //  2. Fill (all cells)
            // ════════════════════════════════════════════════
            SectionHeader { text: "2 · Fill  (all cells)" }

            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "fillWidth"; Layout.preferredWidth: 80; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                CheckBox { id: fillWidthCheck; checked: true }
                Text { text: "fillHeight"; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                CheckBox { id: fillHeightCheck; checked: false }
            }

            // ════════════════════════════════════════════════
            //  3. Alignment (all cells)
            // ════════════════════════════════════════════════
            SectionHeader { text: "3 · Alignment  (all cells)" }

            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Horizontal"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                ComboBox { id: alignHCombo; Layout.fillWidth: true; model: ["Left","HCenter","Right"]; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Vertical"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                ComboBox { id: alignVCombo; Layout.fillWidth: true; model: ["Top","VCenter","Bottom"]; font: ctrlWin.monoFont }
            }

            // ════════════════════════════════════════════════
            //  4. Size Hints (all cells, 0 = unset)
            // ════════════════════════════════════════════════
            SectionHeader { text: "4 · Size Hints  (all cells, 0=unset)" }

            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Pref Width"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: prefWSpin; Layout.fillWidth: true; from: 0; to: 600; value: 0; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Pref Height"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: prefHSpin; Layout.fillWidth: true; from: 0; to: 400; value: 0; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Min Width"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: minWSpin; Layout.fillWidth: true; from: 0; to: 600; value: 0; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Min Height"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: minHSpin; Layout.fillWidth: true; from: 0; to: 400; value: 0; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Max Width"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: maxWSpin; Layout.fillWidth: true; from: 0; to: 800; value: 0; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Max Height"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: maxHSpin; Layout.fillWidth: true; from: 0; to: 800; value: 0; font: ctrlWin.monoFont }
            }

            // ════════════════════════════════════════════════
            //  5. Per-Cell Margins  (target cell only)
            // ════════════════════════════════════════════════
            SectionHeader { text: "5 · Margins  (white-border cell only)" }

            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Target Cell #"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: targetSpin; Layout.fillWidth: true; from: 1; to: cellCountSpin.value; value: 1; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Top Margin"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: topMargSpin; Layout.fillWidth: true; from: 0; to: 60; value: 0; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Bottom Margin"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: bottomMargSpin; Layout.fillWidth: true; from: 0; to: 60; value: 0; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Left Margin"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: leftMargSpin; Layout.fillWidth: true; from: 0; to: 60; value: 0; font: ctrlWin.monoFont }
            }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Text { text: "Right Margin"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textPrimary }
                SpinBox { id: rightMargSpin; Layout.fillWidth: true; from: 0; to: 60; value: 0; font: ctrlWin.monoFont }
            }

            // ── Reset ─────────────────────────────────────────────
            Button {
                Layout.fillWidth: true
                Layout.topMargin: 6
                text: "Reset All to Defaults"
                onClicked: {
                    cellCountSpin.value  = 4
                    spacingSpin.value    = 8
                    dirCombo.currentIndex   = 0
                    fillWidthCheck.checked  = true
                    fillHeightCheck.checked = false
                    alignHCombo.currentIndex = 0
                    alignVCombo.currentIndex = 0
                    prefWSpin.value = 0;  prefHSpin.value = 0
                    minWSpin.value  = 0;  minHSpin.value  = 0
                    maxWSpin.value  = 0;  maxHSpin.value  = 0
                    targetSpin.value    = 1
                    topMargSpin.value   = 0;  bottomMargSpin.value = 0
                    leftMargSpin.value  = 0;  rightMargSpin.value  = 0
                }
            }

            Item { Layout.preferredHeight: 4 }
        }
    }

    // ── Live status readout ──────────────────────────────────────
    Rectangle {
        id: liveBox
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 10 }
        height: liveText.implicitHeight + 16
        color: ctrlWin.accentDim
        radius: 4

        Text {
            id: liveText
            anchors { fill: parent; margins: 8 }
            font.family: "Consolas"; font.pixelSize: 11
            color: ctrlWin.textPrimary
            wrapMode: Text.WordWrap
            text: {
                "spacing: "         + col.spacing + "\n" +
                "direction: "       + (col.layoutDirection === Qt.LeftToRight ? "TopToBottom" : "BottomToTop") + "\n" +
                "cells: "           + cellCountSpin.value + "\n" +
                "fillWidth: "       + fillWidthCheck.checked + "  fillHeight: " + fillHeightCheck.checked + "\n" +
                "align H: "         + ["Left","HCenter","Right"][alignHCombo.currentIndex] +
                "  V: "             + ["Top","VCenter","Bottom"][alignVCombo.currentIndex] + "\n" +
                "playground: "      + Math.round(playWin.width) + " × " + Math.round(playWin.height)
            }
        }
    }
    } // end ctrlWin
} // end playWin
