// TableExplorer.qml
// ─────────────────────────────────────────────────────────────────────
// Interactive explorer for QAbstractTableModel CRUD operations.
//
// LEFT  — SmartTable (the reusable component from SmartTable.qml)
// RIGHT — Controls panel:
//           · Row operations    (add, remove last, remove selected)
//           · Column operations (add, remove last, rename)
//           · Cell reference    (get/set/jump via "A1"-style ref)
//           · Data extraction   (get row, get column, export CSV)
//           · Table settings    (editable toggle, clear, reset)
// BOTTOM — Output panel (shows extracted data / CSV)
//          Status bar (shows last operation)
// ─────────────────────────────────────────────────────────────────────

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width:  1240
    height: 780
    minimumWidth:  920
    minimumHeight: 580
    title: "Table Explorer — CRUD · Cell Reference · Data Extraction"
    color: "#1e1e2e"

    // ── Palette ───────────────────────────────────────────────────────
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
    readonly property color clrTeal:   "#89dceb"

    // ── App state ─────────────────────────────────────────────────────
    property string lastOp:     "Ready — click a cell to select, double-click to edit"
    property string outputText: ""

    // ── Reusable button component ──────────────────────────────────────
    component ActionBtn: Button {
        property color btnColor: root.dimBg
        Layout.fillWidth: true
        implicitHeight: 30
        background: Rectangle {
            color: parent.down    ? Qt.darker(parent.btnColor,  1.4)  :
                   parent.hovered ? Qt.lighter(parent.btnColor, 1.12) :
                                    parent.btnColor
            radius: 5
        }
        contentItem: Text {
            text: parent.text
            font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
            color: "#1e1e2e"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
        }
    }

    // ── Styled text field ──────────────────────────────────────────────
    component StyledField: TextField {
        background: Rectangle { color: root.dimBg; radius: 5 }
        color: root.textMain
        font.family: "Consolas"; font.pixelSize: 11
        placeholderTextColor: root.subtext
    }

    // ── Divider ────────────────────────────────────────────────────────
    component Divider: Rectangle {
        Layout.fillWidth: true
        height: 1; color: root.dimBg
        Layout.topMargin: 2; Layout.bottomMargin: 2
    }

    // ── Section label ─────────────────────────────────────────────────
    component SectionLabel: Text {
        font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
    }

    // ── Root layout ───────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // ── Main row (table + controls) ───────────────────────────────
        RowLayout {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            spacing: 10

            // ════════════════════════════════════════════════════════
            //  LEFT — SmartTable panel
            // ════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                color: root.surface; radius: 8; clip: true

                // Panel header
                Rectangle {
                    id: tableHead
                    width: parent.width; height: 34
                    color: root.dimBg; radius: 4
                    Rectangle {
                        width: parent.width; height: 8
                        anchors.bottom: parent.bottom; color: root.dimBg
                    }
                    Text {
                        anchors.centerIn: parent
                        text: {
                            let r = tblModel ? tblModel.rows : 0
                            let c = tblModel ? tblModel.cols : 0
                            return "SmartTable  \u00b7  " + r + " rows  \u00d7  " + c + " cols"
                        }
                        font.family: "Consolas"; font.pixelSize: 12; font.bold: true
                        color: root.accent
                    }
                }

                // ── SmartTable (the reusable component) ───────────────
                SmartTable {
                    id: smartTable
                    anchors {
                        top: tableHead.bottom; topMargin: 6
                        left: parent.left; right: parent.right; bottom: parent.bottom
                        leftMargin: 8; rightMargin: 8; bottomMargin: 8
                    }
                    tableModel: tblModel
                    editable:   editableCheck.checked

                    // Re-measure column widths after rows/cols are added/removed
                    Connections {
                        target: tblModel
                        function onStructureChanged() { smartTable.forceLayout() }
                    }

                    onCellClicked: function(row, col) {
                        root.lastOp = "Cell clicked  →  " + tblModel.cellRef(row, col) +
                                      "  [row " + row + ", col " + col + "]" +
                                      "  value: \"" + tblModel.getCell(row, col) + "\""
                    }
                    onCellEdited: function(row, col, value) {
                        root.lastOp = "Cell edited  →  " + tblModel.cellRef(row, col) +
                                      "  =  \"" + value + "\""
                    }
                }
            }

            // ════════════════════════════════════════════════════════
            //  RIGHT — Controls panel
            // ════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillHeight: true
                width: 318
                color: root.surface; radius: 8; clip: true

                Rectangle {
                    id: ctrlHead
                    width: parent.width; height: 34
                    color: root.dimBg; radius: 4
                    Rectangle {
                        width: parent.width; height: 8
                        anchors.bottom: parent.bottom; color: root.dimBg
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "Controls"
                        font.family: "Consolas"; font.pixelSize: 12; font.bold: true
                        color: root.accent
                    }
                }

                Flickable {
                    id: ctrlFlick
                    anchors {
                        top: ctrlHead.bottom; topMargin: 8
                        left: parent.left; right: parent.right; bottom: parent.bottom
                        leftMargin: 10; rightMargin: 10; bottomMargin: 10
                    }
                    contentWidth:  width
                    contentHeight: ctrlCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: ctrlCol
                        width: ctrlFlick.width
                        spacing: 8

                        // ─── ROW OPERATIONS ───────────────────────
                        SectionLabel { text: "Row Operations"; color: root.clrGreen }

                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            ActionBtn {
                                text: "+ Add Row"; btnColor: root.clrGreen
                                onClicked: {
                                    tblModel.addRow()
                                    root.lastOp = "addRow()  →  blank row appended at bottom"
                                }
                            }
                            ActionBtn {
                                text: "× Last Row"; btnColor: root.clrRed
                                onClicked: {
                                    let r = tblModel.getRowCount() - 1
                                    if (r >= 0) {
                                        tblModel.deleteRow(r)
                                        root.lastOp = "deleteRow(" + r + ")  \u2192  last row deleted"
                                        if (smartTable.selectedRow >= tblModel.getRowCount())
                                            smartTable.selectedRow = -1
                                    }
                                }
                            }
                            ActionBtn {
                                text: "× Selected"; btnColor: root.clrRed
                                enabled: smartTable.selectedRow >= 0
                                opacity: enabled ? 1.0 : 0.45
                                onClicked: {
                                    let r = smartTable.selectedRow
                                    tblModel.deleteRow(r)
                                    root.lastOp = "deleteRow(" + r + ")  \u2192  selected row deleted"
                                    smartTable.selectedRow = -1
                                    smartTable.selectedCol = -1
                                }
                            }
                        }

                        // ─── COLUMN OPERATIONS ────────────────────
                        Divider {}
                        SectionLabel { text: "Column Operations"; color: root.clrBlue }

                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            ActionBtn {
                                text: "+ Add Col"; btnColor: root.clrBlue
                                onClicked: {
                                    tblModel.addColumn()
                                    root.lastOp = "addColumn()  →  blank column appended on right"
                                }
                            }
                            ActionBtn {
                                text: "× Last Col"; btnColor: root.clrRed
                                onClicked: {
                                    let c = tblModel.getColCount() - 1
                                    if (c >= 0) {
                                        tblModel.deleteColumn(c)
                                        root.lastOp = "deleteColumn(" + c + ")  \u2192  last column deleted"
                                        if (smartTable.selectedCol >= tblModel.getColCount())
                                            smartTable.selectedCol = -1
                                    }
                                }
                            }
                        }

                        // Rename column
                        Text {
                            text: "Rename column header:"
                            font.family: "Segoe UI"; font.pixelSize: 10
                            color: root.subtext
                        }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            StyledField {
                                id: renameIdx
                                Layout.preferredWidth: 44
                                placeholderText: "col#"
                            }
                            StyledField {
                                id: renameName
                                Layout.fillWidth: true
                                placeholderText: "New header name"
                            }
                            ActionBtn {
                                text: "Rename"; btnColor: root.clrBlue
                                Layout.preferredWidth: 64
                                onClicked: {
                                    let c = parseInt(renameIdx.text)
                                    if (!isNaN(c) && renameName.text.length > 0) {
                                        tblModel.setColumnHeader(c, renameName.text)
                                        root.lastOp = 'setColumnHeader(' + c +
                                                      ', "' + renameName.text + '")'
                                    }
                                }
                            }
                        }

                        // ─── CELL REFERENCE & EDIT ────────────────
                        Divider {}
                        SectionLabel { text: "Cell Reference  (A1-style)"; color: root.clrYellow }

                        // Ref + value row
                        RowLayout {
                            Layout.fillWidth: true; spacing: 6
                            StyledField {
                                id: refInput
                                Layout.preferredWidth: 56
                                placeholderText: "A1"
                                font.pixelSize: 14; font.bold: true
                                color: root.clrYellow
                            }
                            Text {
                                text: "="
                                font.family: "Consolas"; font.pixelSize: 13
                                color: root.subtext
                                Layout.alignment: Qt.AlignVCenter
                            }
                            StyledField {
                                id: cellValInput
                                Layout.fillWidth: true
                                placeholderText: "value"
                            }
                        }

                        // Get / Set / Jump buttons
                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            ActionBtn {
                                text: "Get"; btnColor: root.clrYellow
                                onClicked: {
                                    let p = tblModel.parseCellRef(refInput.text)
                                    if (p[0] >= 0) {
                                        let v = tblModel.getCell(p[0], p[1])
                                        cellValInput.text = v
                                        root.lastOp = 'getCell(' + p[0] + ', ' + p[1] + ')' +
                                                      '  [' + refInput.text.toUpperCase() + ']' +
                                                      '  →  "' + v + '"'
                                    } else {
                                        root.lastOp = '"' + refInput.text + '"  →  invalid reference'
                                    }
                                }
                            }
                            ActionBtn {
                                text: "Set"; btnColor: root.clrYellow
                                onClicked: {
                                    let p = tblModel.parseCellRef(refInput.text)
                                    if (p[0] >= 0) {
                                        tblModel.setCell(p[0], p[1], cellValInput.text)
                                        root.lastOp = 'setCell(' + p[0] + ', ' + p[1] +
                                                      ', "' + cellValInput.text + '")' +
                                                      '  [' + refInput.text.toUpperCase() + ']'
                                    } else {
                                        root.lastOp = '"' + refInput.text + '"  →  invalid reference'
                                    }
                                }
                            }
                            ActionBtn {
                                text: "Jump"; btnColor: root.clrYellow
                                onClicked: {
                                    let p = tblModel.parseCellRef(refInput.text)
                                    if (p[0] >= 0) {
                                        smartTable.selectedRow = p[0]
                                        smartTable.selectedCol = p[1]
                                        root.lastOp = 'Jump to ' + refInput.text.toUpperCase() +
                                                      '  →  row ' + p[0] + ', col ' + p[1]
                                    } else {
                                        root.lastOp = '"' + refInput.text + '"  →  invalid reference'
                                    }
                                }
                            }
                        }

                        // Selected-cell shortcut
                        RowLayout {
                            Layout.fillWidth: true; spacing: 8
                            Text {
                                text: "Selected:"
                                font.family: "Segoe UI"; font.pixelSize: 10
                                color: root.subtext
                                Layout.alignment: Qt.AlignVCenter
                            }
                            Text {
                                text: {
                                    if (!tblModel || smartTable.selectedRow < 0) return "\u2014"
                                    return tblModel.cellRef(smartTable.selectedRow,
                                                            smartTable.selectedCol)
                                }
                                font.family: "Consolas"; font.pixelSize: 13; font.bold: true
                                color: root.accent
                                Layout.alignment: Qt.AlignVCenter
                            }
                            Item { Layout.fillWidth: true }
                            ActionBtn {
                                text: "→ Ref Input"
                                Layout.preferredWidth: 86
                                enabled: smartTable.selectedRow >= 0
                                opacity: enabled ? 1.0 : 0.45
                                onClicked: {
                                    refInput.text    = tblModel.cellRef(smartTable.selectedRow,
                                                                          smartTable.selectedCol)
                                    cellValInput.text = tblModel.getCell(smartTable.selectedRow,
                                                                           smartTable.selectedCol)
                                }
                            }
                        }

                        // ─── DATA EXTRACTION ──────────────────────
                        Divider {}
                        SectionLabel { text: "Data Extraction"; color: root.clrTeal }

                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            StyledField {
                                id: extractIdx
                                Layout.preferredWidth: 44
                                placeholderText: "0"
                            }
                            ActionBtn {
                                text: "Get Row"; btnColor: root.clrTeal
                                onClicked: {
                                    let n = parseInt(extractIdx.text)
                                    if (!isNaN(n)) {
                                        let vals = tblModel.getRow(n)
                                        root.outputText = "getRow(" + n + "):\n" +
                                                          JSON.stringify(vals, null, 2)
                                        root.lastOp = "getRow(" + n + ")  →  " +
                                                      vals.length + " values  (see output)"
                                    }
                                }
                            }
                            ActionBtn {
                                text: "Get Col"; btnColor: root.clrTeal
                                onClicked: {
                                    let n = parseInt(extractIdx.text)
                                    if (!isNaN(n)) {
                                        let vals = tblModel.getColumn(n)
                                        root.outputText = "getColumn(" + n + "):\n" +
                                                          JSON.stringify(vals, null, 2)
                                        root.lastOp = "getColumn(" + n + ")  →  " +
                                                      vals.length + " values  (see output)"
                                    }
                                }
                            }
                        }

                        ActionBtn {
                            text: "Export as CSV"; btnColor: root.clrTeal
                            onClicked: {
                                root.outputText = tblModel.exportCsv()
                                root.lastOp = "exportCsv()  →  see output panel below"
                            }
                        }

                        // ─── TABLE SETTINGS ───────────────────────
                        Divider {}
                        SectionLabel { text: "Table Settings"; color: root.clrOrange }

                        RowLayout {
                            Layout.fillWidth: true; spacing: 8
                            CheckBox {
                                id: editableCheck
                                checked: true
                                contentItem: Text {
                                    leftPadding: editableCheck.indicator.width + 4
                                    text: "Editable  (double-click cell)"
                                    font.family: "Segoe UI"; font.pixelSize: 11
                                    color: root.textMain
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            ActionBtn {
                                text: "Clear All Cells"; btnColor: root.clrOrange
                                onClicked: {
                                    tblModel.clearAll()
                                    root.lastOp = "clearAll()  →  all cells blanked, structure kept"
                                }
                            }
                            ActionBtn {
                                text: "Reset  6 × 5"; btnColor: root.clrRed
                                onClicked: {
                                    tblModel.resetTable(6, 5)
                                    smartTable.selectedRow = -1
                                    smartTable.selectedCol = -1
                                    root.lastOp = "resetTable(6, 5)  →  fresh empty 6×5 table"
                                }
                            }
                        }

                        Item { height: 4 }   // bottom padding
                    }
                }
            }
        }

        // ── Output panel (appears when there is output) ───────────────
        Rectangle {
            Layout.fillWidth: true
            height: 120; radius: 6
            color: root.surface
            visible: root.outputText.length > 0

            Rectangle {
                id: outHead
                width: parent.width; height: 26
                color: root.dimBg; radius: 4
                Rectangle {
                    width: parent.width; height: 8
                    anchors.bottom: parent.bottom; color: root.dimBg
                }
                Text {
                    anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                    text: "Output"
                    font.family: "Consolas"; font.pixelSize: 11; font.bold: true
                    color: root.clrTeal
                }
                Text {
                    anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                    text: "✕ clear"
                    font.family: "Segoe UI"; font.pixelSize: 10; color: root.subtext
                    MouseArea { anchors.fill: parent; onClicked: root.outputText = "" }
                }
            }

            Flickable {
                anchors {
                    top: outHead.bottom; left: parent.left
                    right: parent.right; bottom: parent.bottom
                    margins: 8; topMargin: 6
                }
                contentWidth:  Math.max(width, outContent.implicitWidth)
                contentHeight: Math.max(height, outContent.implicitHeight)
                clip: true

                Text {
                    id: outContent
                    text: root.outputText
                    font.family: "Consolas"; font.pixelSize: 11
                    color: root.clrTeal
                    wrapMode: Text.NoWrap
                }
            }
        }

        // ── Status bar ────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 28; radius: 6
            color: root.dimBg
            Text {
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                text: "⟫  " + root.lastOp
                font.family: "Consolas"; font.pixelSize: 10
                color: root.textMain; opacity: 0.8
                elide: Text.ElideRight
                width: parent.width - 20
            }
        }
    }
}
