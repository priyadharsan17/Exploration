import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1100
    height: 780
    title: "PySide6 GridLayout Explorer"
    color: "#1e1e2e"

    // ── Fonts ──────────────────────────────────────────────────────────────
    readonly property font monoFont:  Qt.font({ family: "Consolas", pixelSize: 12 })
    readonly property font labelFont: Qt.font({ family: "Segoe UI", pixelSize: 12 })

    // ── Colour palette ─────────────────────────────────────────────────────
    readonly property color accent:      "#cba6f7"
    readonly property color accentDim:   "#45475a"
    readonly property color surface:     "#313244"
    readonly property color surfaceHigh: "#45475a"
    readonly property color textPrimary: "#cdd6f4"
    readonly property color textMuted:   "#6c7086"

    // ── Shared cell colours (cycled) ────────────────────────────────────────
    readonly property var cellColors: [
        "#f38ba8", "#fab387", "#f9e2af",
        "#a6e3a1", "#89dceb", "#89b4fa", "#cba6f7"
    ]

    // ================================================================
    //  Main horizontal split: playground (left) + controls (right)
    // ================================================================
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // ── LEFT: grid playground ──────────────────────────────────────
        Rectangle {
            id: playArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: root.surface
            radius: 8
            clip: true

            // Title bar
            Rectangle {
                id: playTitle
                width: parent.width
                height: 36
                color: root.accentDim
                radius: 8
                // flatten bottom corners
                Rectangle { width: parent.width; height: 10; anchors.bottom: parent.bottom; color: root.accentDim }

                Text {
                    anchors.centerIn: parent
                    text: "Grid Playground"
                    font.family: root.labelFont.family
                    font.bold: true
                    font.pixelSize: 13
                    color: root.textPrimary
                }
            }

            // The actual GridLayout under study
            GridLayout {
                id: grid
                anchors {
                    top: playTitle.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 16
                }

                // ── Live-bound properties ──────────────────────────────
                columns:      colsSpin.value
                rows:         rowsSpin.value
                columnSpacing: colSpacingSpin.value
                rowSpacing:    rowSpacingSpin.value

                layoutDirection: dirCombo.currentIndex === 0
                                 ? Qt.LeftToRight
                                 : Qt.RightToLeft

                flow: flowCombo.currentIndex === 0
                      ? GridLayout.LeftToRight
                      : GridLayout.TopToBottom

                // ── 12 demo cells ──────────────────────────────────────
                Repeater {
                    model: cellCountSpin.value
                    delegate: Rectangle {
                        // span controls
                        Layout.columnSpan: (index === spanTargetSpin.value - 1)
                                           ? colSpanSpin.value : 1
                        Layout.rowSpan:    (index === spanTargetSpin.value - 1)
                                           ? rowSpanSpin.value : 1

                        // alignment
                        Layout.alignment: alignHCombo.currentIndex === 0 ? Qt.AlignLeft
                                        : alignHCombo.currentIndex === 1 ? Qt.AlignHCenter
                                        : Qt.AlignRight
                                        | (alignVCombo.currentIndex === 0 ? Qt.AlignTop
                                         : alignVCombo.currentIndex === 1 ? Qt.AlignVCenter
                                         : Qt.AlignBottom)

                        // fill
                        Layout.fillWidth:  fillWidthCheck.checked
                        Layout.fillHeight: fillHeightCheck.checked

                        // preferred / minimum / maximum sizes
                        Layout.preferredWidth:  prefWidthSpin.value  > 0 ? prefWidthSpin.value  : -1
                        Layout.preferredHeight: prefHeightSpin.value > 0 ? prefHeightSpin.value : -1
                        Layout.minimumWidth:    minWidthSpin.value   > 0 ? minWidthSpin.value   : -1
                        Layout.minimumHeight:   minHeightSpin.value  > 0 ? minHeightSpin.value  : -1
                        Layout.maximumWidth:    maxWidthSpin.value   > 0 ? maxWidthSpin.value   : 99999
                        Layout.maximumHeight:   maxHeightSpin.value  > 0 ? maxHeightSpin.value  : 99999

                        color: root.cellColors[index % root.cellColors.length]
                        radius: 6

                        // highlight the span target cell
                        border.color: (index === spanTargetSpin.value - 1) ? "white" : "transparent"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            font.pixelSize: 14
                            font.bold: true
                            color: "#1e1e2e"
                        }

                        // Show cell geometry on hover
                        HoverHandler { id: hov }
                        ToolTip.visible: hov.hovered
                        ToolTip.text: "Cell " + (index+1) +
                                      "\nw=" + Math.round(width) +
                                      "  h=" + Math.round(height) +
                                      "\nx=" + Math.round(x) +
                                      "  y=" + Math.round(y)
                    }
                }
            }
        }

        // ── RIGHT: control panel ───────────────────────────────────────
        Rectangle {
            id: panel
            Layout.preferredWidth: 320
            Layout.fillHeight: true
            color: root.surface
            radius: 8

            // Title bar
            Rectangle {
                id: panelTitle
                width: parent.width
                height: 36
                color: root.accentDim
                radius: 8
                Rectangle { width: parent.width; height: 10; anchors.bottom: parent.bottom; color: root.accentDim }

                Text {
                    anchors.centerIn: parent
                    text: "Properties"
                    font.family: root.labelFont.family
                    font.bold: true
                    font.pixelSize: 13
                    color: root.textPrimary
                }
            }

            // Scrollable controls
            ScrollView {
                id: controlsScrollView
                anchors {
                    top: panelTitle.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 10
                }
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                ColumnLayout {
                    width: controlsScrollView.availableWidth
                    spacing: 6

                    // ── Section helper component ─────────────────────
                    component SectionHeader: Rectangle {
                        property alias text: lbl.text
                        Layout.fillWidth: true
                        height: 24
                        color: root.accentDim
                        radius: 4
                        Text {
                            id: lbl
                            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                            font.family: root.monoFont.family
                            font.pixelSize: root.monoFont.pixelSize
                            font.bold: true
                            color: root.accent
                        }
                    }

                    // ════════════════════════════════════════════════
                    //  1. GridLayout structure
                    // ════════════════════════════════════════════════
                    SectionHeader { text: "1 · Grid Structure" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Columns"; Layout.preferredWidth: 90; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: colsSpin
                            Layout.fillWidth: true
                            from: 1; to: 8; value: 3
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Rows"; Layout.preferredWidth: 90; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: rowsSpin
                            Layout.fillWidth: true
                            from: 1; to: 8; value: 2
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Cell Count"; Layout.preferredWidth: 90; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: cellCountSpin
                            Layout.fillWidth: true
                            from: 1; to: 12; value: 6
                            font: root.monoFont
                        }
                    }

                    // ════════════════════════════════════════════════
                    //  2. Spacing
                    // ════════════════════════════════════════════════
                    SectionHeader { text: "2 · Spacing" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Col Spacing"; Layout.preferredWidth: 90; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: colSpacingSpin
                            Layout.fillWidth: true
                            from: 0; to: 60; value: 8
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Row Spacing"; Layout.preferredWidth: 90; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: rowSpacingSpin
                            Layout.fillWidth: true
                            from: 0; to: 60; value: 8
                            font: root.monoFont
                        }
                    }

                    // ════════════════════════════════════════════════
                    //  3. Flow & Direction
                    // ════════════════════════════════════════════════
                    SectionHeader { text: "3 · Flow & Direction" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Flow"; Layout.preferredWidth: 90; font: root.labelFont; color: root.textPrimary }
                        ComboBox {
                            id: flowCombo
                            Layout.fillWidth: true
                            model: ["LeftToRight", "TopToBottom"]
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Direction"; Layout.preferredWidth: 90; font: root.labelFont; color: root.textPrimary }
                        ComboBox {
                            id: dirCombo
                            Layout.fillWidth: true
                            model: ["LeftToRight", "RightToLeft"]
                            font: root.monoFont
                        }
                    }

                    // ════════════════════════════════════════════════
                    //  4. Cell Span (applies to highlighted cell)
                    // ════════════════════════════════════════════════
                    SectionHeader { text: "4 · Cell Span (white border)" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Target Cell #"; Layout.preferredWidth: 110; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: spanTargetSpin
                            Layout.fillWidth: true
                            from: 1; to: cellCountSpin.value; value: 1
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Column Span"; Layout.preferredWidth: 110; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: colSpanSpin
                            Layout.fillWidth: true
                            from: 1; to: colsSpin.value; value: 1
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Row Span"; Layout.preferredWidth: 110; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: rowSpanSpin
                            Layout.fillWidth: true
                            from: 1; to: rowsSpin.value; value: 1
                            font: root.monoFont
                        }
                    }

                    // ════════════════════════════════════════════════
                    //  5. Fill
                    // ════════════════════════════════════════════════
                    SectionHeader { text: "5 · Fill (all cells)" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "fillWidth"; Layout.preferredWidth: 110; font: root.labelFont; color: root.textPrimary }
                        CheckBox {
                            id: fillWidthCheck
                            checked: true
                        }
                        Text { text: "fillHeight"; font: root.labelFont; color: root.textPrimary }
                        CheckBox {
                            id: fillHeightCheck
                            checked: true
                        }
                    }

                    // ════════════════════════════════════════════════
                    //  6. Alignment (all cells)
                    // ════════════════════════════════════════════════
                    SectionHeader { text: "6 · Alignment (all cells)" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Horizontal"; Layout.preferredWidth: 90; font: root.labelFont; color: root.textPrimary }
                        ComboBox {
                            id: alignHCombo
                            Layout.fillWidth: true
                            model: ["Left", "HCenter", "Right"]
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Vertical"; Layout.preferredWidth: 90; font: root.labelFont; color: root.textPrimary }
                        ComboBox {
                            id: alignVCombo
                            Layout.fillWidth: true
                            model: ["Top", "VCenter", "Bottom"]
                            font: root.monoFont
                        }
                    }

                    // ════════════════════════════════════════════════
                    //  7. Size Hints (all cells)
                    // ════════════════════════════════════════════════
                    SectionHeader { text: "7 · Size Hints (all cells, 0 = unset)" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Pref Width"; Layout.preferredWidth: 110; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: prefWidthSpin
                            Layout.fillWidth: true
                            from: 0; to: 400; value: 0
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Pref Height"; Layout.preferredWidth: 110; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: prefHeightSpin
                            Layout.fillWidth: true
                            from: 0; to: 400; value: 0
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Min Width"; Layout.preferredWidth: 110; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: minWidthSpin
                            Layout.fillWidth: true
                            from: 0; to: 400; value: 0
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Min Height"; Layout.preferredWidth: 110; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: minHeightSpin
                            Layout.fillWidth: true
                            from: 0; to: 400; value: 0
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Max Width"; Layout.preferredWidth: 110; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: maxWidthSpin
                            Layout.fillWidth: true
                            from: 0; to: 800; value: 0
                            font: root.monoFont
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Text { text: "Max Height"; Layout.preferredWidth: 110; font: root.labelFont; color: root.textPrimary }
                        SpinBox {
                            id: maxHeightSpin
                            Layout.fillWidth: true
                            from: 0; to: 800; value: 0
                            font: root.monoFont
                        }
                    }

                    // ── Reset button ──────────────────────────────────
                    Button {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        text: "Reset All to Defaults"
                        onClicked: {
                            colsSpin.value       = 3
                            rowsSpin.value       = 2
                            cellCountSpin.value  = 6
                            colSpacingSpin.value = 8
                            rowSpacingSpin.value = 8
                            flowCombo.currentIndex = 0
                            dirCombo.currentIndex  = 0
                            spanTargetSpin.value = 1
                            colSpanSpin.value    = 1
                            rowSpanSpin.value    = 1
                            fillWidthCheck.checked  = true
                            fillHeightCheck.checked = true
                            alignHCombo.currentIndex = 0
                            alignVCombo.currentIndex = 0
                            prefWidthSpin.value  = 0
                            prefHeightSpin.value = 0
                            minWidthSpin.value   = 0
                            minHeightSpin.value  = 0
                            maxWidthSpin.value   = 0
                            maxHeightSpin.value  = 0
                        }
                    }

                    // ── Live status readout ──────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        height: statusText.implicitHeight + 16
                        color: root.accentDim
                        radius: 4

                        Text {
                            id: statusText
                            anchors { fill: parent; margins: 8 }
                            font: root.monoFont
                            color: root.textPrimary
                            wrapMode: Text.WordWrap
                            text: {
                                "columns: "       + grid.columns        + "\n" +
                                "rows: "          + grid.rows           + "\n" +
                                "columnSpacing: " + grid.columnSpacing  + "\n" +
                                "rowSpacing: "    + grid.rowSpacing     + "\n" +
                                "flow: "          + (grid.flow === GridLayout.LeftToRight ? "LeftToRight" : "TopToBottom") + "\n" +
                                "direction: "     + (grid.layoutDirection === Qt.LeftToRight ? "LTR" : "RTL") + "\n" +
                                "cells: "         + cellCountSpin.value
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 8 }
                }
            }
        }
    }
}
