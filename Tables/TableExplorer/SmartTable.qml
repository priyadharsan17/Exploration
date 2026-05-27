// SmartTable.qml
// ─────────────────────────────────────────────────────────────────────
// Reusable table component backed by any QAbstractTableModel.
//
// USAGE
// ─────
//   SmartTable {
//       anchors.fill: parent
//       tableModel:   myModel      // required — must be a QAbstractTableModel
//
//       // optional overrides:
//       editable:     true
//       cellWidth:    130
//       cellHeight:   38
//
//       onCellClicked: function(row, col) { ... }
//       onCellEdited:  function(row, col, newValue) { ... }
//   }
//
// SELECTION
// ─────────
//   Read selectedRow / selectedCol to know the current selection.
//   Set them from outside to programmatically highlight a cell.
//
// STRUCTURAL CHANGES
// ──────────────────
//   If your model emits a custom `structureChanged` signal (as
//   table_backend.TableModel does), connect to it and call
//   forceLayout() to make the TableView re-measure column widths:
//
//   Connections {
//       target: myModel
//       function onStructureChanged() { smartTable.forceLayout() }
//   }
//
// ─────────────────────────────────────────────────────────────────────

import QtQuick
import QtQuick.Controls

Item {
    id: tableRoot

    // ── Public API ────────────────────────────────────────────────────
    required property var tableModel   // QAbstractTableModel

    property bool editable:       true  // double-click to edit
    property int  cellWidth:      130   // default width for every column
    property int  cellHeight:     38    // height for every row
    property int  headerHeight:   32    // horizontal header row height
    property int  rowHeaderWidth: 36    // row-number column width

    // Override columnWidths with a function(col)=>int for per-column widths.
    // Leave null to use cellWidth uniformly.
    property var  columnWidths: null

    // ── Theme (override any of these from the outside) ─────────────────
    property color colHeaderBg:   "#45475a"
    property color colHeaderText: "#cdd6f4"
    property color rowHeaderBg:   "#2a2a3e"
    property color rowHeaderText: "#6c7086"
    property color cellBg:        "#1e1e2e"
    property color cellBgAlt:     "#22223a"
    property color cellText:      "#cdd6f4"
    property color selBg:         "#cba6f718"
    property color selBorder:     "#cba6f7"
    property color editBg:        "#313244"
    property color editText:      "#a6e3a1"
    property color borderClr:     "#3a3a52"

    // ── Selection state ───────────────────────────────────────────────
    property int selectedRow: -1
    property int selectedCol: -1

    // ── Signals ───────────────────────────────────────────────────────
    signal cellClicked(int row, int col)
    signal cellEdited(int row, int col, string newValue)

    // ── Internal — tracks which cell is in edit mode ──────────────────
    property int _editRow: -1
    property int _editCol: -1

    // ── Public method — call after structural model changes ───────────
    function forceLayout() {
        tv.forceLayout()
    }

    // ── Corner cell (top-left intersection of both headers) ───────────
    Rectangle {
        id: corner
        x: 0; y: 0
        width:  tableRoot.rowHeaderWidth
        height: tableRoot.headerHeight
        color:  tableRoot.colHeaderBg
        Rectangle {
            width: parent.width; height: 1
            anchors.bottom: parent.bottom; color: tableRoot.borderClr
        }
        Rectangle {
            width: 1; height: parent.height
            anchors.right: parent.right; color: tableRoot.borderClr
        }
        Text {
            anchors.centerIn: parent
            text: "#"
            font.family: "Consolas"; font.pixelSize: 10; font.bold: true
            color: tableRoot.colHeaderText; opacity: 0.35
        }
    }

    // ── Horizontal (column) header ────────────────────────────────────
    HorizontalHeaderView {
        id: hHeader
        anchors { top: parent.top; left: corner.right; right: parent.right }
        height: tableRoot.headerHeight
        syncView: tv
        clip: true

        delegate: Rectangle {
            implicitWidth:  tableRoot.cellWidth
            implicitHeight: tableRoot.headerHeight
            color: tableRoot.colHeaderBg
            Rectangle {
                width: parent.width; height: 1
                anchors.bottom: parent.bottom; color: tableRoot.borderClr
            }
            Rectangle {
                width: 1; height: parent.height
                anchors.right: parent.right; color: tableRoot.borderClr
            }
            Text {
                anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                text: display
                font.family: "Consolas"; font.pixelSize: 12; font.bold: true
                color: tableRoot.colHeaderText
                verticalAlignment:   Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }
    }

    // ── Vertical (row number) header ──────────────────────────────────
    VerticalHeaderView {
        id: vHeader
        anchors { top: hHeader.bottom; left: parent.left; bottom: parent.bottom }
        width: tableRoot.rowHeaderWidth
        syncView: tv
        clip: true

        delegate: Rectangle {
            implicitWidth:  tableRoot.rowHeaderWidth
            implicitHeight: tableRoot.cellHeight
            color: tableRoot.rowHeaderBg
            Rectangle {
                height: parent.height; width: 1
                anchors.right: parent.right; color: tableRoot.borderClr
            }
            Rectangle {
                width: parent.width; height: 1
                anchors.bottom: parent.bottom; color: tableRoot.borderClr
            }
            Text {
                anchors.centerIn: parent
                text: display
                font.family: "Consolas"; font.pixelSize: 11
                color: tableRoot.rowHeaderText
            }
        }
    }

    // ── Data cell area ────────────────────────────────────────────────
    TableView {
        id: tv
        anchors {
            top: hHeader.bottom; left: vHeader.right
            right: parent.right; bottom: parent.bottom
        }
        model: tableRoot.tableModel
        clip:  true

        columnWidthProvider: function(col) {
            return tableRoot.columnWidths
                ? tableRoot.columnWidths(col)
                : tableRoot.cellWidth
        }
        rowHeightProvider: function() { return tableRoot.cellHeight }

        ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }
        ScrollBar.vertical:   ScrollBar { policy: ScrollBar.AsNeeded }

        // ── Cell delegate ─────────────────────────────────────────────
        delegate: Rectangle {
            id: cell

            required property int    row
            required property int    column
            required property string display   // Qt.DisplayRole → data()

            implicitWidth:  tableRoot.cellWidth
            implicitHeight: tableRoot.cellHeight

            property bool isSelected: tableRoot.selectedRow === row &&
                                      tableRoot.selectedCol === column
            property bool isEditing:  tableRoot._editRow === row &&
                                      tableRoot._editCol === column

            // Defer focus to next event loop tick to avoid binding loop
            onIsEditingChanged: {
                if (isEditing) Qt.callLater(function() {
                    ti.forceActiveFocus()
                    ti.selectAll()
                })
            }

            color: isSelected
                ? tableRoot.selBg
                : (row % 2 === 0 ? tableRoot.cellBg : tableRoot.cellBgAlt)

            // Bottom border
            Rectangle {
                width: parent.width; height: 1
                anchors.bottom: parent.bottom
                color: tableRoot.borderClr
            }
            // Right border
            Rectangle {
                width: 1; height: parent.height
                anchors.right: parent.right
                color: tableRoot.borderClr
            }
            // Left accent bar on selected row
            Rectangle {
                visible: isSelected
                width: 3; height: parent.height
                anchors.left: parent.left
                color: tableRoot.selBorder
            }

            // ── Read mode ─────────────────────────────────────────────
            Text {
                visible: !cell.isEditing
                anchors { fill: parent; leftMargin: 8; rightMargin: 6 }
                text: display
                font.family: "Segoe UI"; font.pixelSize: 12
                color: tableRoot.cellText
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            // ── Edit mode (double-click activates) ────────────────────
            Rectangle {
                visible: cell.isEditing
                anchors.fill: parent
                color: tableRoot.editBg

                Rectangle {
                    width: parent.width; height: 2
                    anchors.bottom: parent.bottom
                    color: tableRoot.selBorder
                }

                TextInput {
                    id: ti
                    anchors { fill: parent; leftMargin: 8; rightMargin: 6 }
                    text: cell.display
                    font.family: "Segoe UI"; font.pixelSize: 12
                    color: tableRoot.editText
                    verticalAlignment: Text.AlignVCenter
                    selectByMouse: true
                    clip: true

                    Keys.onReturnPressed:  commit()
                    Keys.onTabPressed:     commit()
                    Keys.onEscapePressed:  cancel()

                    onActiveFocusChanged: {
                        if (!activeFocus && cell.isEditing) commit()
                    }

                    function commit() {
                        let r = cell.row
                        let c = cell.column
                        let v = ti.text
                        tableRoot.tableModel.setCell(r, c, v)
                        tableRoot.cellEdited(r, c, v)
                        tableRoot._editRow = -1
                        tableRoot._editCol = -1
                    }

                    function cancel() {
                        tableRoot._editRow = -1
                        tableRoot._editCol = -1
                    }
                }
            }

            // ── Mouse interaction ─────────────────────────────────────
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    tableRoot.selectedRow = cell.row
                    tableRoot.selectedCol = cell.column
                    tableRoot.cellClicked(cell.row, cell.column)
                }
                onDoubleClicked: {
                    if (tableRoot.editable) {
                        tableRoot.selectedRow = cell.row
                        tableRoot.selectedCol = cell.column
                        tableRoot._editRow    = cell.row
                        tableRoot._editCol    = cell.column
                    }
                }
            }
        }
    }
}
