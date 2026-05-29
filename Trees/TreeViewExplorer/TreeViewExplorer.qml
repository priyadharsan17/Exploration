// TreeViewExplorer.qml
// ─────────────────────────────────────────────────────────────────────
// Interactive explorer for QAbstractItemModel (tree) via QML TreeView.
//
// LEFT  — TreeView with expand/collapse, node selection, hover highlight
// RIGHT — Controls panel:
//           · Selected node info (name, id)
//           · Add child to selected node
//           · Add top-level node
//           · Rename selected node
//           · Remove selected node
//           · Node info  (path, child count, leaf check)
//           · Expand / Collapse all
// BOTTOM — Status bar (last operation)
// ─────────────────────────────────────────────────────────────────────

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible:       true
    width:         1100
    height:        700
    minimumWidth:  860
    minimumHeight: 520
    title:         "TreeView Explorer — QAbstractItemModel · CRUD · Path"
    color:         "#1e1e2e"

    // ── Palette (Catppuccin Mocha) ─────────────────────────────────────
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

    // ── App state ──────────────────────────────────────────────────────
    property int    selectedNodeId:   -1
    property string selectedNodeName: ""
    property string lastOp:           "Ready — click a node to select; click a branch to expand/collapse"

    // ── Reusable components ────────────────────────────────────────────
    component ActionBtn: Button {
        property color btnColor: root.dimBg
        Layout.fillWidth: true
        implicitHeight: 30
        background: Rectangle {
            color: parent.down    ? Qt.darker (parent.btnColor, 1.4)  :
                   parent.hovered ? Qt.lighter(parent.btnColor, 1.12) :
                                    parent.btnColor
            radius: 5
        }
        contentItem: Text {
            text: parent.text
            font.family:   "Segoe UI"; font.pixelSize: 11; font.bold: true
            color:         "#1e1e2e"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
        }
    }

    component StyledField: TextField {
        background: Rectangle { color: root.dimBg; radius: 5 }
        color:                root.textMain
        font.family:          "Consolas"; font.pixelSize: 11
        placeholderTextColor: root.subtext
        Layout.fillWidth:     true
    }

    component Divider: Rectangle {
        Layout.fillWidth: true
        height: 1; color: root.dimBg
        Layout.topMargin: 2; Layout.bottomMargin: 2
    }

    component SectionLabel: Text {
        font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
        color: root.subtext
    }

    // ── Root layout ────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill:    parent
        anchors.margins: 10
        spacing:         8

        // ── Main row (tree + controls) ─────────────────────────────────
        RowLayout {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            spacing:           10

            // ════════════════════════════════════════════════════════════
            //  LEFT — Tree panel
            // ════════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                color:  root.surface
                radius: 8
                clip:   true

                // Header
                Text {
                    id: treeHeader
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    anchors.margins: 10
                    height: 28
                    text:  "Technology Stack"
                    color: root.accent
                    font.family: "Segoe UI"; font.pixelSize: 14; font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    anchors { top: treeHeader.bottom; left: parent.left; right: parent.right }
                    height: 1; color: root.dimBg
                }

                // Tree
                TreeView {
                    id: treeView
                    anchors {
                        top:    treeHeader.bottom; topMargin: 2
                        bottom: parent.bottom;     bottomMargin: 2
                        left:   parent.left;       leftMargin:   2
                        right:  parent.right;      rightMargin:  2
                    }
                    model: treeModel
                    clip:  true

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width:  8
                    }

                    // ── Delegate ────────────────────────────────────────
                    delegate: Rectangle {
                        id: row

                        // Properties injected by TreeView
                        required property int  depth
                        required property bool hasChildren
                        required property bool expanded
                        required property bool isTreeNode
                        required property int  row       // visual row index

                        // Properties from the model roles
                        required property string display
                        required property int    nodeId

                        implicitWidth:  Math.max(treeView.width, contentRow.implicitWidth + depth * 22 + 36)
                        implicitHeight: 34

                        color: root.selectedNodeId === nodeId
                               ? Qt.rgba(203/255, 166/255, 247/255, 0.18)
                               : mouseArea.containsMouse
                                 ? Qt.rgba(1, 1, 1, 0.05)
                                 : "transparent"

                        // Hover + click
                        MouseArea {
                            id: mouseArea
                            anchors.fill:    parent
                            hoverEnabled:    true
                            onClicked: {
                                root.selectedNodeId   = row.nodeId
                                root.selectedNodeName = row.display
                                root.lastOp = "Selected: \"" + row.display + "\"  (id " + row.nodeId + ")"
                                if (row.hasChildren)
                                    treeView.toggleExpanded(row.row)
                            }
                        }

                        // Selection indicator bar
                        Rectangle {
                            visible: root.selectedNodeId === row.nodeId
                            width:   3; height: parent.height
                            anchors.left: parent.left
                            color: root.accent
                            radius: 2
                        }

                        // Row content
                        RowLayout {
                            id: contentRow
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left:           parent.left
                            anchors.leftMargin:     row.depth * 22 + 10
                            spacing: 6

                            // Expand / collapse arrow
                            Text {
                                text: row.hasChildren ? (row.expanded ? "▾" : "▸") : ""
                                color: root.accent
                                font.pixelSize: 14
                                Layout.preferredWidth: 14
                            }

                            // Icon
                            Text {
                                text: row.hasChildren ? "🗂" : "▪"
                                font.pixelSize: row.hasChildren ? 14 : 10
                                color: root.clrBlue
                            }

                            // Label
                            Text {
                                text:            row.display
                                color:           row.hasChildren ? root.clrBlue : root.textMain
                                font.family:     "Segoe UI"
                                font.pixelSize:  13
                                font.bold:       row.hasChildren
                            }
                        }
                    }
                    // ── End delegate ────────────────────────────────────
                }
            }
            // ════ end LEFT ═══════════════════════════════════════════════

            // ════════════════════════════════════════════════════════════
            //  RIGHT — Controls panel
            // ════════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillHeight:    true
                Layout.preferredWidth: 268
                color:  root.surface
                radius: 8

                ColumnLayout {
                    anchors.fill:    parent
                    anchors.margins: 12
                    spacing:         6

                    // ── Selected node info ───────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        height:  66
                        color:   root.dimBg
                        radius:  6

                        ColumnLayout {
                            anchors.fill:    parent
                            anchors.margins: 10
                            spacing:         2

                            Text {
                                text:  "Selected Node"
                                color: root.subtext
                                font.family: "Segoe UI"; font.pixelSize: 10; font.bold: true
                            }
                            Text {
                                text:  root.selectedNodeName !== "" ? root.selectedNodeName : "(none)"
                                color: root.selectedNodeName !== "" ? root.accent : root.subtext
                                font.family: "Segoe UI"; font.pixelSize: 13; font.bold: true
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text:  root.selectedNodeId !== -1 ? "id: " + root.selectedNodeId : ""
                                color: root.subtext
                                font.family: "Consolas"; font.pixelSize: 10
                            }
                        }
                    }

                    Divider {}

                    // ── Add node ─────────────────────────────────────────
                    SectionLabel { text: "Add Node" }

                    StyledField {
                        id: addField
                        placeholderText: "Node name…"
                    }

                    ActionBtn {
                        btnColor: root.clrGreen
                        text:     "Add Child to Selected"
                        onClicked: {
                            if (root.selectedNodeId === -1) {
                                root.lastOp = "✖  Select a parent node first"
                                return
                            }
                            let newId = treeModel.addNode(root.selectedNodeId, addField.text)
                            if (newId !== -1) {
                                root.lastOp = "✔  Added \"" + addField.text.trim() + "\" under \"" + root.selectedNodeName + "\""
                                addField.text = ""
                            } else {
                                root.lastOp = "✖  Enter a valid node name"
                            }
                        }
                    }

                    ActionBtn {
                        btnColor: root.clrOrange
                        text:     "Add Top-Level Node"
                        onClicked: {
                            let newId = treeModel.addNode(-1, addField.text)
                            if (newId !== -1) {
                                root.lastOp = "✔  Added top-level node \"" + addField.text.trim() + "\""
                                addField.text = ""
                            } else {
                                root.lastOp = "✖  Enter a valid node name"
                            }
                        }
                    }

                    Divider {}

                    // ── Rename ───────────────────────────────────────────
                    SectionLabel { text: "Rename Selected" }

                    StyledField {
                        id: renameField
                        placeholderText: "New name…"
                    }

                    ActionBtn {
                        btnColor: root.clrBlue
                        text:     "Rename"
                        onClicked: {
                            if (root.selectedNodeId === -1) {
                                root.lastOp = "✖  Nothing selected"
                                return
                            }
                            let ok = treeModel.renameNode(root.selectedNodeId, renameField.text)
                            if (ok) {
                                root.lastOp = "✔  Renamed \"" + root.selectedNodeName + "\" → \"" + renameField.text.trim() + "\""
                                root.selectedNodeName = renameField.text.trim()
                                renameField.text = ""
                            } else {
                                root.lastOp = "✖  Enter a valid name"
                            }
                        }
                    }

                    Divider {}

                    // ── Remove ───────────────────────────────────────────
                    ActionBtn {
                        btnColor: root.clrRed
                        text:     "Remove Selected Node"
                        onClicked: {
                            if (root.selectedNodeId === -1) {
                                root.lastOp = "✖  Nothing selected"
                                return
                            }
                            let name = root.selectedNodeName
                            let ok   = treeModel.removeNode(root.selectedNodeId)
                            if (ok) {
                                root.lastOp = "✔  Removed \"" + name + "\" (and all descendants)"
                                root.selectedNodeId   = -1
                                root.selectedNodeName = ""
                            } else {
                                root.lastOp = "✖  Cannot remove this node"
                            }
                        }
                    }

                    Divider {}

                    // ── Node info ────────────────────────────────────────
                    SectionLabel { text: "Node Info" }

                    ActionBtn {
                        text: "Get Full Path"
                        onClicked: {
                            if (root.selectedNodeId === -1) { root.lastOp = "✖  Nothing selected"; return }
                            let path = treeModel.getPath(root.selectedNodeId)
                            root.lastOp = "Path: " + path
                        }
                    }

                    ActionBtn {
                        text: "Child Count"
                        onClicked: {
                            if (root.selectedNodeId === -1) { root.lastOp = "✖  Nothing selected"; return }
                            let n = treeModel.childCount(root.selectedNodeId)
                            root.lastOp = "\"" + root.selectedNodeName + "\" has " + n + " direct child" + (n === 1 ? "" : "ren")
                        }
                    }

                    ActionBtn {
                        text: "Is Leaf?"
                        onClicked: {
                            if (root.selectedNodeId === -1) { root.lastOp = "✖  Nothing selected"; return }
                            let leaf = treeModel.isLeaf(root.selectedNodeId)
                            root.lastOp = "\"" + root.selectedNodeName + "\" is " + (leaf ? "a leaf node (no children)" : "a branch node (has children)")
                        }
                    }

                    Divider {}

                    // ── Expand / Collapse all ────────────────────────────
                    SectionLabel { text: "View" }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        ActionBtn {
                            text: "Expand All"
                            onClicked: {
                                treeView.expandRecursively()
                                root.lastOp = "✔  Expanded all nodes"
                            }
                        }
                        ActionBtn {
                            text: "Collapse All"
                            onClicked: {
                                treeView.collapseRecursively()
                                root.lastOp = "✔  Collapsed all nodes"
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
            // ════ end RIGHT ═══════════════════════════════════════════════
        }

        // ── Status bar ─────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height:  28
            color:   root.dimBg
            radius:  5

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left:           parent.left
                anchors.leftMargin:     12
                text:  root.lastOp
                color: root.textMain
                font.family: "Segoe UI"; font.pixelSize: 12
                elide: Text.ElideRight
            }
        }
    }
}
