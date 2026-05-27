import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ══════════════════════════════════════════════════════════════════════
//  ListView Transition Explorer
//
//  Demonstrates all five ListView transition types:
//    populate  — fires when the model is first assigned to the view
//    add       — fires when items are inserted into the model
//    remove    — fires when items are deleted from the model
//    displaced — fires on items that SHIFT because of another item's
//                add / remove / move
//    move      — fires on items explicitly reordered via ListModel.move()
// ══════════════════════════════════════════════════════════════════════
ApplicationWindow {
    id: root
    visible: true
    width:  980
    height: 720
    minimumWidth:  720
    minimumHeight: 520
    title: "ListView Transition Explorer"
    color: "#1e1e2e"

    // ── Palette ──────────────────────────────────────────────────────
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

    // ── Item color pool ───────────────────────────────────────────────
    readonly property var colorPool: [
        "#f38ba8", "#fab387", "#f9e2af", "#a6e3a1",
        "#89dceb", "#89b4fa", "#cba6f7", "#eba0ac"
    ]

    // ── State ─────────────────────────────────────────────────────────
    property int    colorIdx:    0
    property int    nextId:      0
    property int    selectedIdx: -1
    property string lastOp:      "app started  →  populate transition fired on initial load"

    // ── Transition legend data ─────────────────────────────────────────
    readonly property var transLegend: [
        { tname: "populate",  tcolor: "#f9e2af",
          tdesc: "Slide in from left + fade when the model is first assigned to the view" },
        { tname: "add",       tcolor: "#a6e3a1",
          tdesc: "Scale up from 0 + fade in when an item is inserted" },
        { tname: "remove",    tcolor: "#f38ba8",
          tdesc: "Fly off to the right + fade out when an item is deleted" },
        { tname: "displaced", tcolor: "#89b4fa",
          tdesc: "Spring to new slot — items shifted by another item's add/remove/move" },
        { tname: "move",      tcolor: "#cba6f7",
          tdesc: "Smooth slide when explicitly reordered via ListModel.move()" },
    ]

    // ── Reusable button component ──────────────────────────────────────
    component ActionBtn: Button {
        property color btnColor: root.dimBg
        Layout.fillWidth: true
        implicitHeight: 32
        background: Rectangle {
            color: parent.down    ? Qt.darker(parent.btnColor,  1.4)  :
                   parent.hovered ? Qt.lighter(parent.btnColor, 1.12) :
                                    parent.btnColor
            radius: 6
        }
        contentItem: Text {
            text: parent.text
            font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
            color: "#1e1e2e"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:   Text.AlignVCenter
        }
    }

    // ── Helper functions ───────────────────────────────────────────────
    function pickColor() {
        let c = colorPool[colorIdx % colorPool.length]
        colorIdx++
        return c
    }

    function doAdd(pos) {
        let nm = "Item " + nextId++
        let cl = pickColor()
        if (pos === "top") {
            itemModel.insert(0, { nm: nm, cl: cl })
            lastOp = 'insert(0, "' + nm + '")  →  add  +  displaced (items below shift down)'
        } else if (pos === "bottom") {
            itemModel.append({ nm: nm, cl: cl })
            lastOp = 'append("' + nm + '")  →  add only  (nothing below to displace)'
        } else {
            let i = Math.floor(Math.random() * (itemModel.count + 1))
            itemModel.insert(i, { nm: nm, cl: cl })
            lastOp = 'insert(' + i + ', "' + nm + '")  →  add  +  displaced'
        }
        selectedIdx = -1
    }

    function doRemove(pos) {
        if (itemModel.count === 0) return
        let i
        if (pos === "selected") {
            if (selectedIdx < 0 || selectedIdx >= itemModel.count) return
            i = selectedIdx
        } else if (pos === "top") {
            i = 0
        } else {
            i = itemModel.count - 1
        }
        let nm = itemModel.get(i).nm
        itemModel.remove(i)
        lastOp = 'remove(' + i + ', "' + nm + '")  →  remove  +  displaced (remaining items shift)'
        selectedIdx = -1
    }

    function doMove(dir) {
        if (selectedIdx < 0 || selectedIdx >= itemModel.count) return
        let newIdx = selectedIdx + dir
        if (newIdx < 0 || newIdx >= itemModel.count) return
        itemModel.move(selectedIdx, newIdx, 1)
        lastOp = 'move(' + selectedIdx + ' → ' + newIdx + ')  →  move  +  displaced'
        selectedIdx = newIdx
    }

    function doShuffle() {
        if (itemModel.count < 2) return
        let n = itemModel.count
        for (let i = n - 1; i > 0; i--) {
            let j = Math.floor(Math.random() * (i + 1))
            if (i !== j) itemModel.move(i, j, 1)
        }
        lastOp = "Fisher-Yates shuffle  →  move  +  displaced  (rapid-fire — watch all items animate)"
        selectedIdx = -1
    }

    // Detach the model, rebuild it, then reattach — this re-triggers populate
    function doReplayPopulate() {
        lv.model = null
        itemModel.clear()
        colorIdx = 0; nextId = 0; selectedIdx = -1
        for (let i = 0; i < 7; i++)
            itemModel.append({ nm: "Item " + nextId++, cl: pickColor() })
        lv.model = itemModel
        lastOp = "lv.model = null  →  append ×7  →  lv.model reassigned  →  populate!"
    }

    function doClear() {
        let n = itemModel.count
        itemModel.clear()
        selectedIdx = -1
        lastOp = "clear()  →  remove ×" + n + "  (Qt fires remove per item; no displaced because all gone)"
    }

    // ── Data model ────────────────────────────────────────────────────
    ListModel { id: itemModel }

    // ── Root layout ───────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        RowLayout {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            spacing: 10

            // ════════════════════════════════════════════════════════
            //  LEFT PANEL — ListView
            // ════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                color: root.surface; radius: 8; clip: true

                Rectangle {
                    id: listHead
                    width: parent.width; height: 34
                    color: root.dimBg; radius: 4
                    Rectangle { width: parent.width; height: 8; anchors.bottom: parent.bottom; color: root.dimBg }
                    Text {
                        anchors.centerIn: parent
                        text: {
                            let s = "ListView  ·  " + itemModel.count +
                                    " item" + (itemModel.count !== 1 ? "s" : "")
                            return root.selectedIdx >= 0
                                ? s + "  ·  selected [" + root.selectedIdx + "]"
                                : s
                        }
                        font.family: "Consolas"; font.pixelSize: 12; font.bold: true
                        color: root.accent
                    }
                }

                // Empty-list hint
                Text {
                    anchors.centerIn: parent
                    visible: itemModel.count === 0
                    text: "List is empty\nUse  ↺ Replay Populate  or  + Add"
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Segoe UI"; font.pixelSize: 13
                    color: root.subtext
                }

                ListView {
                    id: lv
                    anchors {
                        top: listHead.bottom; topMargin: 6
                        left: parent.left; right: parent.right; bottom: parent.bottom
                        leftMargin: 8; rightMargin: 8; bottomMargin: 8
                    }
                    model: itemModel
                    spacing: 6
                    clip: true

                    // ─────────────────────────────────────────────
                    //  T R A N S I T I O N S
                    // ─────────────────────────────────────────────

                    // POPULATE — fires when model is first assigned (or reassigned)
                    populate: Transition {
                        ParallelAnimation {
                            NumberAnimation {
                                property: "opacity"; from: 0; to: 1
                                duration: 500; easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                property: "x"; from: -80; to: 0
                                duration: 500; easing.type: Easing.OutCubic
                            }
                        }
                    }

                    // ADD — scale up from centre + fade in
                    add: Transition {
                        ParallelAnimation {
                            NumberAnimation {
                                property: "opacity"; from: 0; to: 1
                                duration: 400
                            }
                            NumberAnimation {
                                property: "scale"; from: 0; to: 1
                                duration: 400; easing.type: Easing.OutBack
                            }
                        }
                    }

                    // REMOVE — fly off to the right + fade out
                    remove: Transition {
                        ParallelAnimation {
                            NumberAnimation {
                                property: "opacity"; from: 1; to: 0
                                duration: 300
                            }
                            NumberAnimation {
                                property: "x"; to: lv.width + 60
                                duration: 300; easing.type: Easing.InCubic
                            }
                        }
                    }

                    // DISPLACED — items that shift due to another item's add/remove/move
                    displaced: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 420; easing.type: Easing.OutBack
                        }
                    }

                    // MOVE — explicitly reordered items (via ListModel.move())
                    move: Transition {
                        NumberAnimation {
                            properties: "x,y"
                            duration: 320; easing.type: Easing.InOutQuad
                        }
                    }

                    // ── Delegate ──────────────────────────────────
                    delegate: Rectangle {
                        id: card
                        required property int    index
                        required property string nm
                        required property string cl

                        width:           lv.width
                        height:          56
                        radius:          8
                        color:           root.selectedIdx === index ? Qt.lighter(cl, 1.4) : cl
                        scale:           1.0
                        transformOrigin: Item.Center

                        // Index badge
                        Rectangle {
                            id: badge
                            width: 28; height: 28; radius: 14
                            anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            color: "#00000030"
                            Text {
                                anchors.centerIn: parent
                                text: index
                                font.family: "Consolas"; font.pixelSize: 12; font.bold: true
                                color: "#1e1e2e"
                            }
                        }

                        Text {
                            anchors { left: badge.right; leftMargin: 10; verticalCenter: parent.verticalCenter }
                            text: nm
                            font.family: "Segoe UI"; font.pixelSize: 14
                            font.bold: root.selectedIdx === index
                            color: "#1e1e2e"
                        }

                        // Selection checkmark
                        Text {
                            visible: root.selectedIdx === index
                            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                            text: "✓"; font.pixelSize: 16; font.bold: true
                            color: "#1e1e2e"; opacity: 0.6
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.selectedIdx = (root.selectedIdx === index ? -1 : index)
                        }
                    }
                }
            }

            // ════════════════════════════════════════════════════════
            //  RIGHT PANEL — Controls + Legend
            // ════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillHeight: true
                width: 295
                color: root.surface; radius: 8; clip: true

                Rectangle {
                    id: ctrlHead
                    width: parent.width; height: 34
                    color: root.dimBg; radius: 4
                    Rectangle { width: parent.width; height: 8; anchors.bottom: parent.bottom; color: root.dimBg }
                    Text {
                        anchors.centerIn: parent
                        text: "Controls & Legend"
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
                        spacing: 10

                        // ── ADD ──────────────────────────────────
                        Text {
                            text: "Add Items  →  add  +  displaced"
                            font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
                            color: root.clrGreen
                        }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            ActionBtn { text: "+ Top";    btnColor: root.clrGreen; onClicked: root.doAdd("top") }
                            ActionBtn { text: "+ Bottom"; btnColor: root.clrGreen; onClicked: root.doAdd("bottom") }
                            ActionBtn { text: "+ Random"; btnColor: root.clrGreen; onClicked: root.doAdd("random") }
                        }

                        // ── REMOVE ───────────────────────────────
                        Text {
                            text: "Remove Items  →  remove  +  displaced"
                            font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
                            color: root.clrRed
                        }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            ActionBtn {
                                text: "× Selected"; btnColor: root.clrRed
                                enabled: root.selectedIdx >= 0
                                opacity: enabled ? 1.0 : 0.45
                                onClicked: root.doRemove("selected")
                            }
                            ActionBtn { text: "× Top";    btnColor: root.clrRed; onClicked: root.doRemove("top") }
                            ActionBtn { text: "× Bottom"; btnColor: root.clrRed; onClicked: root.doRemove("bottom") }
                        }

                        // ── REORDER ──────────────────────────────
                        Text {
                            text: "Reorder  →  move  +  displaced"
                            font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
                            color: root.clrBlue
                        }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            ActionBtn {
                                text: "↑ Up"; btnColor: root.clrBlue
                                enabled: root.selectedIdx > 0
                                opacity: enabled ? 1.0 : 0.45
                                onClicked: root.doMove(-1)
                            }
                            ActionBtn {
                                text: "↓ Down"; btnColor: root.clrBlue
                                enabled: root.selectedIdx >= 0 && root.selectedIdx < itemModel.count - 1
                                opacity: enabled ? 1.0 : 0.45
                                onClicked: root.doMove(1)
                            }
                            ActionBtn { text: "Shuffle"; btnColor: root.clrBlue; onClicked: root.doShuffle() }
                        }

                        // ── RESET ────────────────────────────────
                        Text {
                            text: "Reset"
                            font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
                            color: root.clrOrange
                        }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 5
                            ActionBtn {
                                text: "↺ Replay Populate"; btnColor: root.clrYellow
                                onClicked: root.doReplayPopulate()
                            }
                            ActionBtn {
                                text: "⌫ Clear All"; btnColor: root.clrOrange
                                onClicked: root.doClear()
                            }
                        }

                        // Divider
                        Rectangle { Layout.fillWidth: true; height: 1; color: root.dimBg; Layout.topMargin: 4 }

                        // ── TRANSITION LEGEND ─────────────────────
                        Text {
                            text: "Transition Legend"
                            font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
                            color: root.textMain
                        }

                        Repeater {
                            model: root.transLegend
                            delegate: RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Rectangle {
                                    width: 10; height: 10; radius: 5
                                    color: modelData.tcolor
                                    Layout.alignment: Qt.AlignVCenter | Qt.AlignTop
                                    Layout.topMargin: 2
                                }
                                Text {
                                    text: modelData.tname
                                    font.family: "Consolas"; font.pixelSize: 11; font.bold: true
                                    color: modelData.tcolor
                                    Layout.preferredWidth: 72
                                }
                                Text {
                                    text: modelData.tdesc
                                    font.family: "Segoe UI"; font.pixelSize: 10
                                    color: root.textMain; opacity: 0.7
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // ── Selected item info ────────────────────
                        Rectangle {
                            Layout.fillWidth: true
                            height: 40; radius: 6
                            color: root.dimBg
                            visible: root.selectedIdx >= 0 && root.selectedIdx < itemModel.count
                            Text {
                                anchors.centerIn: parent
                                text: root.selectedIdx >= 0 && root.selectedIdx < itemModel.count
                                    ? "Selected:  " + itemModel.get(root.selectedIdx).nm +
                                      "  (index " + root.selectedIdx + ")"
                                    : ""
                                font.family: "Consolas"; font.pixelSize: 11
                                color: root.accent
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Item { height: 4 }
                    }
                }
            }
        }

        // ── Status bar ───────────────────────────────────────────────
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

    // ── Seed initial data — detach then reattach to fire populate ─────
    Component.onCompleted: {
        lv.model = null
        for (let i = 0; i < 7; i++)
            itemModel.append({ nm: "Item " + nextId++, cl: pickColor() })
        lv.model = itemModel
    }
}
