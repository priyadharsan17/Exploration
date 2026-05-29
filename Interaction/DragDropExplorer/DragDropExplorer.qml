import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ─────────────────────────────────────────────────────────────────────────────
//  DragDropExplorer  –  Kanban-style card board
//  Demonstrates: MouseArea.drag.target proxy, Drag attached properties,
//                DropArea, ListModel reorder, preventStealing inside Flickable
// ─────────────────────────────────────────────────────────────────────────────
ApplicationWindow {
    id: root
    visible: true
    width:  1200
    height: 720
    title:  "Drag & Drop Explorer"
    color:  "#1e1e2e"

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
            verticalAlignment:   Text.AlignVCenter
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

    // ── Board data  (three plain ListModels) ─────────────────────────────────
    ListModel {
        id: todoModel
        ListElement { title: "Design mockups";   cardColor: "#89b4fa" }
        ListElement { title: "Write unit tests"; cardColor: "#f9e2af" }
        ListElement { title: "Update docs";      cardColor: "#a6e3a1" }
    }
    ListModel {
        id: inProgressModel
        ListElement { title: "Build API";   cardColor: "#cba6f7" }
        ListElement { title: "Code review"; cardColor: "#fab387" }
    }
    ListModel {
        id: doneModel
        ListElement { title: "Setup CI/CD";         cardColor: "#a6e3a1" }
        ListElement { title: "Initial scaffolding"; cardColor: "#89b4fa" }
    }

    // Indexed access so the Repeater delegates can look up by column index
    readonly property var colModels:  [todoModel, inProgressModel, doneModel]
    readonly property var colNames:   ["Todo", "In Progress", "Done"]
    readonly property var colAccents: [root.clrBlue, root.clrOrange, root.clrGreen]

    // ── Drag state ────────────────────────────────────────────────────────────
    property int    dragSourceCol:   -1   // which column the card came from
    property int    dragSourceIndex: -1   // index within that column's model
    property string dragTitle:       ""
    property string dragCardColor:   "#89b4fa"
    property string statusMsg:       "Drag a card to move it between columns. Click × to remove."

    // Proxy alias so nested Repeater delegates can resolve floatingCard via root.proxy
    readonly property alias proxy: floatingCard

    function status(msg) { root.statusMsg = msg }

    function resetBoard() {
        todoModel.clear()
        todoModel.append({ title: "Design mockups",   cardColor: "#89b4fa" })
        todoModel.append({ title: "Write unit tests", cardColor: "#f9e2af" })
        todoModel.append({ title: "Update docs",      cardColor: "#a6e3a1" })
        inProgressModel.clear()
        inProgressModel.append({ title: "Build API",   cardColor: "#cba6f7" })
        inProgressModel.append({ title: "Code review", cardColor: "#fab387" })
        doneModel.clear()
        doneModel.append({ title: "Setup CI/CD",         cardColor: "#a6e3a1" })
        doneModel.append({ title: "Initial scaffolding", cardColor: "#89b4fa" })
        root.status("Board reset to initial state.")
    }

    // ── Backend connections ───────────────────────────────────────────────────
    Connections {
        target: backend
        function onBoardReset()                    { root.resetBoard() }
        function onCardAdded(title, colIndex, clr) {
            root.colModels[colIndex].append({ title: title, cardColor: clr })
            root.status("Added \"" + title + "\" \u2192 " + root.colNames[colIndex])
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    //  Floating drag proxy
    //
    //  Pattern: one shared "ghost" card at z:999 (sibling of the layout, so
    //  it can paint over all columns). The card's MouseArea sets drag.target
    //  to this item, which moves it with the cursor. DropAreas detect it via
    //  Drag.keys. On release, Drag.drop() triggers onDropped synchronously.
    // ═════════════════════════════════════════════════════════════════════════
    Rectangle {
        id: floatingCard
        z:       999
        visible: false
        width:   200
        height:  64
        radius:  8
        color:   root.surface
        border.color: root.dragCardColor
        border.width: 2
        opacity: 0.92

        property string cardTitle: ""

        //  Drag.active: true  → QML DnD system tracks this item's position
        //  and routes it to overlapping DropAreas whose keys include "kanban".
        Drag.active:    floatingCard.visible
        Drag.keys:      ["kanban"]
        Drag.hotSpot.x: width  / 2   // DropArea hit-testing uses hotSpot
        Drag.hotSpot.y: height / 2

        Rectangle {
            width: 4; height: parent.height - 20
            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
            radius: 2
            color: root.dragCardColor
        }
        Text {
            anchors {
                left: parent.left; leftMargin: 22
                right: parent.right; rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
            text:     floatingCard.cardTitle
            color:    root.textMain
            font { family: "Segoe UI"; pixelSize: 13; bold: true }
            wrapMode: Text.WordWrap
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    //  Root layout
    // ═════════════════════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── Header ────────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            color: root.surface

            RowLayout {
                anchors { fill: parent; leftMargin: 20; rightMargin: 20 }
                Column {
                    spacing: 2
                    Text {
                        text: "Drag & Drop Explorer"
                        color: root.textMain
                        font { family: "Segoe UI"; pixelSize: 18; bold: true }
                    }
                    Text {
                        text: "MouseArea.drag.target · Drag attached · DropArea · ListModel reorder"
                        color: root.subtext
                        font { family: "Segoe UI"; pixelSize: 12 }
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: root.dimBg }

        // ── Main row ──────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            spacing: 0

            // ── Kanban board  (3 columns) ─────────────────────────────────────
            RowLayout {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                Layout.margins:    16
                spacing:           14

                Repeater {
                    model: 3

                    // ── Column ────────────────────────────────────────────────
                    Rectangle {
                        id: colRect
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        radius: 10
                        color:  "#1e1e2e"
                        border.width: 2
                        border.color: colRect.dropHighlight
                                      ? root.colAccents[colIdx]
                                      : Qt.rgba(1, 1, 1, 0.06)

                        property int  colIdx:        index
                        property bool dropHighlight: false

                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        // ── DropArea ─────────────────────────────────────────
                        //  keys must match floatingCard.Drag.keys.
                        //  onDropped fires synchronously when Drag.drop() is
                        //  called in the card's MouseArea.onReleased.
                        DropArea {
                            anchors.fill: parent
                            keys: ["kanban"]

                            onEntered: colRect.dropHighlight = true
                            onExited:  colRect.dropHighlight = false

                            onDropped: function(drop) {
                                colRect.dropHighlight = false

                                var srcCol = root.dragSourceCol
                                var srcIdx = root.dragSourceIndex

                                // Same-column drop → no-op
                                if (srcCol === colRect.colIdx) return

                                var title = root.dragTitle
                                var clr   = root.dragCardColor

                                // Remove from source, append to target
                                root.colModels[srcCol].remove(srcIdx)
                                root.colModels[colRect.colIdx].append({ title: title, cardColor: clr })

                                root.status(
                                    "Moved \"" + title + "\" \u2192 " + root.colNames[colRect.colIdx]
                                    + "   [Todo " + todoModel.count
                                    + "  \u00b7  In Progress " + inProgressModel.count
                                    + "  \u00b7  Done " + doneModel.count + "]"
                                )
                                drop.acceptProposedAction()
                            }
                        }

                        ColumnLayout {
                            anchors { fill: parent; margins: 10 }
                            spacing: 8

                            // Column header badge
                            Rectangle {
                                Layout.fillWidth: true
                                height: 38
                                radius: 6
                                color:  root.colAccents[colIdx]

                                RowLayout {
                                    anchors { fill: parent; leftMargin: 14; rightMargin: 10 }
                                    Text {
                                        text:  root.colNames[colIdx]
                                        color: "#1e1e2e"
                                        font { family: "Segoe UI"; pixelSize: 14; bold: true }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Rectangle {
                                        width: 24; height: 24; radius: 12
                                        color: Qt.rgba(0, 0, 0, 0.20)
                                        Text {
                                            anchors.centerIn: parent
                                            text:  root.colModels[colIdx].count
                                            color: "#1e1e2e"
                                            font { family: "Segoe UI"; pixelSize: 12; bold: true }
                                        }
                                    }
                                }
                            }

                            // Card list
                            Flickable {
                                Layout.fillWidth:  true
                                Layout.fillHeight: true
                                contentHeight: cardsCol.implicitHeight
                                clip: true

                                Column {
                                    id: cardsCol
                                    width:   parent.width
                                    spacing: 6

                                    Repeater {
                                        model: root.colModels[colIdx]

                                        // ── Card ─────────────────────────────
                                        Rectangle {
                                            id: cardItem
                                            width:  cardsCol.width
                                            height: 64
                                            radius: 8
                                            color:  root.dimBg

                                            // Dim the source card while dragging
                                            opacity: (root.dragSourceCol   === colIdx &&
                                                      root.dragSourceIndex === index)
                                                     ? 0.20 : 1.0
                                            Behavior on opacity { NumberAnimation { duration: 80 } }

                                            // Left accent bar
                                            Rectangle {
                                                width: 4; height: parent.height - 20
                                                anchors {
                                                    left: parent.left; leftMargin: 8
                                                    verticalCenter: parent.verticalCenter
                                                }
                                                radius: 2
                                                color:  model.cardColor
                                            }

                                            // Title text
                                            Text {
                                                anchors {
                                                    left: parent.left;    leftMargin:  22
                                                    right: removeBtn.left; rightMargin: 8
                                                    verticalCenter: parent.verticalCenter
                                                }
                                                text:     model.title
                                                color:    root.textMain
                                                font { family: "Segoe UI"; pixelSize: 13 }
                                                wrapMode: Text.WordWrap
                                            }

                                            // × remove button
                                            Rectangle {
                                                id: removeBtn
                                                width: 24; height: 24
                                                anchors {
                                                    right: parent.right; rightMargin: 8
                                                    verticalCenter: parent.verticalCenter
                                                }
                                                radius: 6
                                                color: rmHover.containsMouse ? root.clrRed : "transparent"
                                                Behavior on color { ColorAnimation { duration: 80 } }

                                                Text {
                                                    anchors.centerIn: parent
                                                    text:  "×"
                                                    color: rmHover.containsMouse ? "#1e1e2e" : root.subtext
                                                    font { pixelSize: 16; bold: true }
                                                }
                                                MouseArea {
                                                    id: rmHover
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        root.status("Removed \"" + model.title + "\"")
                                                        root.colModels[colIdx].remove(index)
                                                    }
                                                }
                                            }

                                            // ── Drag initiator ───────────────
                                            //
                                            //  drag.target: floatingCard  — MouseArea hands off
                                            //    pointer movement to the proxy rect.
                                            //
                                            //  preventStealing: true  — ensures this MouseArea
                                            //    keeps the grab even when inside a Flickable.
                                            //
                                            //  onPressed: position the proxy so the cursor is at
                                            //    its visual center (hotSpot), then show it.
                                            //
                                            //  onReleased: Drag.drop() finalises the drop by
                                            //    searching for an overlapping DropArea and firing
                                            //    its onDropped synchronously.
                                            MouseArea {
                                                anchors {
                                                    fill: parent
                                                    rightMargin: 36   // don't compete with removeBtn
                                                }
                                                drag.target:      root.proxy
                                                drag.threshold:   4
                                                cursorShape:      Qt.OpenHandCursor
                                                preventStealing:  true

                                                onPressed: function(mouse) {
                                                    root.dragSourceCol   = colIdx
                                                    root.dragSourceIndex = index
                                                    root.dragTitle       = model.title
                                                    root.dragCardColor   = model.cardColor

                                                    root.proxy.cardTitle = model.title

                                                    // Map cursor position to root.contentItem space,
                                                    // offset so cursor lands at proxy centre.
                                                    var pos = mapToItem(
                                                        root.contentItem,
                                                        mouse.x - root.proxy.width  / 2,
                                                        mouse.y - root.proxy.height / 2
                                                    )
                                                    root.proxy.x = pos.x
                                                    root.proxy.y = pos.y
                                                    root.proxy.visible = true
                                                }

                                                onReleased: {
                                                    // Capture root before Drag.drop() fires onDropped
                                                    // synchronously. onDropped calls model.remove(),
                                                    // which destroys this delegate's QML context.
                                                    // After that, the QML id `root` can no longer be
                                                    // resolved — so we save it to a local JS var first.
                                                    var r = root
                                                    var p = r.proxy
                                                    p.Drag.drop()       // may destroy this delegate
                                                    p.visible = false
                                                    r.dragSourceCol   = -1
                                                    r.dragSourceIndex = -1
                                                }
                                            }
                                        }
                                    }   // Repeater (cards)
                                }       // Column
                            }           // Flickable
                        }               // ColumnLayout (column body)
                    }                   // Rectangle (colRect)
                }                       // Repeater (columns)
            }                           // RowLayout (board)

            // Right panel divider
            Rectangle { width: 1; Layout.fillHeight: true; color: root.dimBg }

            // ── Control panel ─────────────────────────────────────────────────
            Rectangle {
                implicitWidth:     252
                Layout.fillHeight: true
                color: root.surface

                ScrollView {
                    id: ctrlScroll
                    anchors { fill: parent; margins: 12 }
                    clip: true
                    contentWidth: availableWidth

                    ColumnLayout {
                        width:   ctrlScroll.availableWidth
                        spacing: 10

                        SectionLabel { text: "ADD CARD" }
                        Divider {}

                        TextField {
                            id: titleField
                            Layout.fillWidth:    true
                            placeholderText:     "Card title…"
                            color:               root.textMain
                            placeholderTextColor: root.subtext
                            font { family: "Segoe UI"; pixelSize: 13 }
                            leftPadding: 10
                            background: Rectangle { color: root.dimBg; radius: 6 }
                            Keys.onReturnPressed: addBtn.clicked()
                        }

                        ComboBox {
                            id: colSelector
                            Layout.fillWidth: true
                            model: root.colNames
                            contentItem: Text {
                                leftPadding: 10
                                text:  colSelector.displayText
                                color: root.textMain
                                font { family: "Segoe UI"; pixelSize: 13 }
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle { color: root.dimBg; radius: 6 }
                            popup: Popup {
                                y:       colSelector.height + 2
                                width:   colSelector.width
                                padding: 4
                                background: Rectangle { color: root.surface; radius: 6 }
                                contentItem: ListView {
                                    implicitHeight: contentHeight
                                    model: colSelector.delegateModel
                                    clip:  true
                                }
                            }
                            delegate: ItemDelegate {
                                width: colSelector.width
                                contentItem: Text {
                                    leftPadding: 10
                                    text:  modelData
                                    color: root.textMain
                                    font { family: "Segoe UI"; pixelSize: 13 }
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color:  parent.highlighted ? root.dimBg : "transparent"
                                    radius: 4
                                }
                            }
                        }

                        ActionBtn {
                            id: addBtn
                            Layout.fillWidth: true
                            text:    "Add Card"
                            enabled: titleField.text.trim().length > 0
                            onClicked: {
                                backend.addCard(titleField.text.trim(), colSelector.currentIndex)
                                titleField.clear()
                                titleField.forceActiveFocus()
                            }
                        }

                        Divider {}
                        SectionLabel { text: "ACTIONS" }
                        Divider {}

                        ActionBtn {
                            Layout.fillWidth: true
                            text:     "Reset Board"
                            btnColor: root.clrRed
                            onClicked: backend.resetBoard()
                        }

                        Divider {}
                        SectionLabel { text: "STATS" }
                        Divider {}

                        Repeater {
                            model: 3
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text:  root.colNames[index]
                                    color: root.colAccents[index]
                                    font { family: "Segoe UI"; pixelSize: 12 }
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: root.colModels[index].count
                                          + (root.colModels[index].count === 1 ? " card" : " cards")
                                    color: root.subtext
                                    font { family: "Segoe UI"; pixelSize: 12 }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Total: "
                                  + (todoModel.count + inProgressModel.count + doneModel.count)
                                  + " cards"
                            color: root.textMain
                            font { family: "Segoe UI"; pixelSize: 12; bold: true }
                        }

                        Divider {}
                        SectionLabel { text: "HOW IT WORKS" }
                        Divider {}

                        Text {
                            Layout.fillWidth: true
                            text: "• drag.target: floatingCard\n"
                                + "  proxy moves with cursor\n"
                                + "• Drag.active: visible\n"
                                + "  activates the DnD system\n"
                                + "• Drag.keys match DropArea.keys\n"
                                + "  filter valid drop targets\n"
                                + "• DropArea.onDropped\n"
                                + "  remove srcIdx, append to col\n"
                                + "• Drag.drop() on release\n"
                                + "  fires onDropped synchronously\n"
                                + "• preventStealing: true\n"
                                + "  beats Flickable grab"
                            color: root.subtext
                            font { family: "Segoe UI"; pixelSize: 11 }
                            wrapMode: Text.WordWrap
                            lineHeight: 1.4
                        }

                        Item { Layout.preferredHeight: 4 }
                    }
                }
            }
        }   // RowLayout (main row)

        // ── Status bar ────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight:   30
            color: "#11111b"

            Text {
                anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                text:  root.statusMsg
                color: root.subtext
                font { family: "Segoe UI"; pixelSize: 12 }
                elide: Text.ElideRight
                width: parent.width - 24
            }
        }
    }   // ColumnLayout (root)
}
