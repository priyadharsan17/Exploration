// SortFilterExplorer.qml
// ─────────────────────────────────────────────────────────────────────
// Interactive explorer for QSortFilterProxyModel.
//
// LEFT  — ListView of styled item cards (name · category · score · active)
//         Cards highlight on selection; inactive items are dimmed.
//
// RIGHT — Controls panel (ScrollView):
//           · Live search (substring match on name)
//           · Category filter (pill buttons — All + 5 categories)
//           · Active-only toggle
//           · Sort field (Name / Score / Category) + direction toggle
//           · Add item form (name · score · category · active)
//           · Remove selected item
//
// HEADER — Stats bar inside the list panel: "Showing N of M"
// BOTTOM — Status bar (last operation)
// ─────────────────────────────────────────────────────────────────────

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible:        true
    width:          1160
    height:         820
    minimumWidth:   900
    minimumHeight:  600
    title:          "SortFilter Explorer — QSortFilterProxyModel · Multi-Criteria · Role Sort"
    color:          "#1e1e2e"

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
    property int    selectedRow:    -1
    property string filterCategory: ""
    property int    sortField:      0      // 0=Name  1=Score  2=Category
    property bool   sortAsc:        true
    property string addCategory:    "Frontend"
    property bool   addActive:      true
    property string lastOp:         "Ready — click a card to select"

    // ── Helpers ────────────────────────────────────────────────────────
    readonly property var categories: ["Frontend", "Backend", "Database", "DevOps", "Mobile"]

    function catColor(cat) {
        switch (cat) {
            case "Frontend":  return root.clrBlue
            case "Backend":   return root.clrGreen
            case "Database":  return root.clrOrange
            case "DevOps":    return root.clrYellow
            case "Mobile":    return root.accent
            default:          return root.subtext
        }
    }

    function scoreColor(s) {
        if (s >= 80) return root.clrGreen
        if (s >= 60) return root.clrYellow
        return root.clrRed
    }

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
            font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
            color: "#1e1e2e"
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

        RowLayout {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            spacing:           10

            // ════════════════════════════════════════════════════════════
            //  LEFT — List panel
            // ════════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                color:  root.surface
                radius: 8
                clip:   true

                // Header
                Rectangle {
                    id: listHeader
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 38
                    color: "transparent"

                    RowLayout {
                        anchors.fill:        parent
                        anchors.leftMargin:  12
                        anchors.rightMargin: 12

                        Text {
                            text:  "Tech Ecosystem"
                            color: root.accent
                            font.family: "Segoe UI"; font.pixelSize: 14; font.bold: true
                            Layout.fillWidth: true
                        }
                        Text {
                            text:  "Showing " + proxyModel.filteredCount + " of " + proxyModel.totalCount
                            color: root.subtext
                            font.family: "Segoe UI"; font.pixelSize: 11
                        }
                    }
                }

                Rectangle {
                    anchors { top: listHeader.bottom; left: parent.left; right: parent.right }
                    height: 1; color: root.dimBg
                }

                // List
                ListView {
                    id: listView
                    anchors {
                        top:    listHeader.bottom; topMargin: 2
                        bottom: parent.bottom;     bottomMargin: 2
                        left:   parent.left;       leftMargin:   2
                        right:  parent.right;      rightMargin:  2
                    }
                    model:   proxyModel
                    clip:    true
                    spacing: 3

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded; width: 8
                    }

                    // ── Card delegate ─────────────────────────────────
                    delegate: Rectangle {
                        id: card

                        required property int    index
                        required property string itemName
                        required property string category
                        required property int    score
                        required property bool   isActive

                        width:          listView.width - 10
                        height:         76
                        radius:         6
                        color:          root.selectedRow === index
                                        ? Qt.rgba(203/255, 166/255, 247/255, 0.15)
                                        : mouseArea.containsMouse
                                          ? Qt.rgba(1, 1, 1, 0.04)
                                          : "transparent"
                        opacity:        card.isActive ? 1.0 : 0.55

                        // Selection bar
                        Rectangle {
                            visible: root.selectedRow === card.index
                            width: 3; height: parent.height - 8
                            anchors { left: parent.left; leftMargin: 2; verticalCenter: parent.verticalCenter }
                            color:  root.accent
                            radius: 2
                        }

                        // Category color strip
                        Rectangle {
                            width:  4
                            height: parent.height - 16
                            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                            color:  root.catColor(card.category)
                            radius: 2
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.selectedRow = card.index
                                root.lastOp = "Selected: \"" + card.itemName + "\"  ·  " + card.category + "  ·  Score " + card.score
                            }
                        }

                        // Card content
                        ColumnLayout {
                            anchors {
                                left:  parent.left;  leftMargin:  22
                                right: parent.right; rightMargin: 12
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: 4

                            // Row 1: category badge + active dot
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                // Category badge
                                Rectangle {
                                    height: 16
                                    width:  catLabel.implicitWidth + 10
                                    color:  Qt.rgba(root.catColor(card.category).r,
                                                    root.catColor(card.category).g,
                                                    root.catColor(card.category).b, 0.2)
                                    border.color: root.catColor(card.category)
                                    border.width: 1
                                    radius: 8

                                    Text {
                                        id: catLabel
                                        anchors.centerIn: parent
                                        text:  card.category
                                        color: root.catColor(card.category)
                                        font.family: "Segoe UI"; font.pixelSize: 9; font.bold: true
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                // Active indicator
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: card.isActive ? root.clrGreen : root.subtext
                                }
                                Text {
                                    text:  card.isActive ? "Active" : "Inactive"
                                    color: card.isActive ? root.clrGreen : root.subtext
                                    font.family: "Segoe UI"; font.pixelSize: 10
                                }
                            }

                            // Row 2: name + score
                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text:  card.itemName
                                    color: root.textMain
                                    font.family: "Segoe UI"; font.pixelSize: 14; font.bold: true
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text:  card.score
                                    color: root.scoreColor(card.score)
                                    font.family: "Consolas"; font.pixelSize: 14; font.bold: true
                                    Layout.preferredWidth: 30
                                    horizontalAlignment: Text.AlignRight
                                }
                            }

                            // Row 3: score bar
                            Rectangle {
                                Layout.fillWidth: true
                                height: 4; radius: 2
                                color: root.dimBg

                                Rectangle {
                                    width:  parent.width * card.score / 100
                                    height: parent.height
                                    radius: parent.radius
                                    color:  root.scoreColor(card.score)
                                }
                            }
                        }
                    }
                    // ── End card delegate ─────────────────────────────
                }
            }
            // ════ end LEFT ════════════════════════════════════════════

            // ════════════════════════════════════════════════════════════
            //  RIGHT — Controls panel
            // ════════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillHeight:     true
                Layout.preferredWidth: 292
                color:  root.surface
                radius: 8
                clip:   true

                ScrollView {
                    id: ctrlScroll
                    anchors.fill:    parent
                    anchors.margins: 10
                    contentWidth:    availableWidth
                    clip:            true

                    ColumnLayout {
                        width:   ctrlScroll.availableWidth
                        spacing: 6

                        // ── Search ───────────────────────────────────
                        SectionLabel { text: "Search" }

                        StyledField {
                            id:              searchField
                            placeholderText: "Filter by name…"
                            onTextChanged:   proxyModel.setSearchText(text)
                        }

                        Divider {}

                        // ── Category filter ───────────────────────────
                        SectionLabel { text: "Category" }

                        // "All" button
                        Button {
                            Layout.fillWidth: true
                            implicitHeight:   28
                            text: "All  (" + proxyModel.totalCount + ")"

                            property bool isSelected: root.filterCategory === ""

                            background: Rectangle {
                                color:        parent.isSelected ? Qt.rgba(root.textMain.r, root.textMain.g, root.textMain.b, 0.15) : root.dimBg
                                border.color: parent.isSelected ? root.textMain : "transparent"
                                border.width: 1; radius: 5
                            }
                            contentItem: Text {
                                text:  parent.text
                                color: root.textMain
                                font.family: "Segoe UI"; font.pixelSize: 11; font.bold: parent.isSelected
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment:   Text.AlignVCenter
                            }
                            onClicked: {
                                root.filterCategory = ""
                                proxyModel.setCategoryFilter("")
                                root.lastOp = "Category filter cleared"
                            }
                        }

                        // Per-category buttons
                        Repeater {
                            model: root.categories

                            Button {
                                property string cat:        modelData
                                property color  catCol:     root.catColor(modelData)
                                property bool   isSelected: root.filterCategory === cat

                                Layout.fillWidth: true
                                implicitHeight:   28
                                text: modelData

                                background: Rectangle {
                                    color:        parent.isSelected ? Qt.rgba(parent.catCol.r, parent.catCol.g, parent.catCol.b, 0.2) : root.dimBg
                                    border.color: parent.isSelected ? parent.catCol : "transparent"
                                    border.width: 1; radius: 5
                                }
                                contentItem: Text {
                                    text:  parent.text
                                    color: parent.isSelected ? parent.catCol : root.textMain
                                    font.family: "Segoe UI"; font.pixelSize: 11; font.bold: parent.isSelected
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment:   Text.AlignVCenter
                                }
                                onClicked: {
                                    root.filterCategory = cat
                                    proxyModel.setCategoryFilter(cat)
                                    root.lastOp = "Category filter: " + cat
                                }
                            }
                        }

                        Divider {}

                        // ── Active only ───────────────────────────────
                        SectionLabel { text: "Status Filter" }

                        Button {
                            id: activeToggle
                            Layout.fillWidth: true
                            implicitHeight:   30
                            checkable:        true
                            checked:          false
                            text: checked ? "⬤  Active only" : "⬤  Showing all"

                            background: Rectangle {
                                color:  parent.checked ? Qt.rgba(root.clrGreen.r, root.clrGreen.g, root.clrGreen.b, 0.2) : root.dimBg
                                border.color: parent.checked ? root.clrGreen : "transparent"
                                border.width: 1; radius: 5
                            }
                            contentItem: Text {
                                text:  parent.text
                                color: parent.checked ? root.clrGreen : root.textMain
                                font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment:   Text.AlignVCenter
                            }
                            onCheckedChanged: {
                                proxyModel.setActiveOnly(checked)
                                root.lastOp = checked ? "Active-only filter on" : "Active-only filter off"
                            }
                        }

                        Divider {}

                        // ── Sort ──────────────────────────────────────
                        SectionLabel { text: "Sort by" }

                        // Sort field selector
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Repeater {
                                model: ["Name", "Score", "Category"]

                                Button {
                                    property int  fieldIdx:    index
                                    property bool isSelected:  root.sortField === index

                                    Layout.fillWidth: true
                                    implicitHeight:   28
                                    text: modelData

                                    background: Rectangle {
                                        color:        parent.isSelected ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.25) : root.dimBg
                                        border.color: parent.isSelected ? root.accent : "transparent"
                                        border.width: 1; radius: 5
                                    }
                                    contentItem: Text {
                                        text:  parent.text
                                        color: parent.isSelected ? root.accent : root.textMain
                                        font.family: "Segoe UI"; font.pixelSize: 11; font.bold: parent.isSelected
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment:   Text.AlignVCenter
                                    }
                                    onClicked: {
                                        root.sortField = fieldIdx
                                        proxyModel.setSortField(fieldIdx)
                                        root.lastOp = "Sorted by " + modelData + (root.sortAsc ? " ↑" : " ↓")
                                    }
                                }
                            }
                        }

                        // Sort direction toggle
                        Button {
                            id: dirToggle
                            Layout.fillWidth: true
                            implicitHeight:   30
                            checkable:        true
                            checked:          true    // true = ascending
                            text: checked ? "↑  Ascending" : "↓  Descending"

                            background: Rectangle {
                                color: root.dimBg; radius: 5
                            }
                            contentItem: Text {
                                text:  parent.text
                                color: root.textMain
                                font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment:   Text.AlignVCenter
                            }
                            onCheckedChanged: {
                                root.sortAsc = checked
                                proxyModel.setSortAscending(checked)
                                root.lastOp = "Sort direction: " + (checked ? "ascending" : "descending")
                            }
                        }

                        Divider {}

                        // ── Add item ──────────────────────────────────
                        SectionLabel { text: "Add Item" }

                        StyledField {
                            id:              addNameField
                            placeholderText: "Name…"
                        }

                        // Score input
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Text {
                                text: "Score (0–100)"
                                color: root.subtext
                                font.family: "Segoe UI"; font.pixelSize: 10
                            }
                            StyledField {
                                id:              addScoreField
                                placeholderText: "85"
                                inputMethodHints: Qt.ImhDigitsOnly
                                validator: IntValidator { bottom: 0; top: 100 }
                                Layout.preferredWidth: 60
                            }
                        }

                        // Category picker for new item
                        Repeater {
                            model: root.categories

                            Button {
                                property string cat:        modelData
                                property color  catCol:     root.catColor(modelData)
                                property bool   isSelected: root.addCategory === cat

                                Layout.fillWidth: true
                                implicitHeight:   26
                                text: modelData

                                background: Rectangle {
                                    color:        parent.isSelected ? Qt.rgba(parent.catCol.r, parent.catCol.g, parent.catCol.b, 0.2) : root.dimBg
                                    border.color: parent.isSelected ? parent.catCol : "transparent"
                                    border.width: 1; radius: 5
                                }
                                contentItem: Text {
                                    text:  parent.text
                                    color: parent.isSelected ? parent.catCol : root.textMain
                                    font.family: "Segoe UI"; font.pixelSize: 11; font.bold: parent.isSelected
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment:   Text.AlignVCenter
                                }
                                onClicked: root.addCategory = cat
                            }
                        }

                        // Active toggle for new item
                        Button {
                            Layout.fillWidth: true
                            implicitHeight:   28
                            checkable:        true
                            checked:          root.addActive
                            text: checked ? "⬤  Active" : "○  Inactive"

                            background: Rectangle {
                                color:        parent.checked ? Qt.rgba(root.clrGreen.r, root.clrGreen.g, root.clrGreen.b, 0.15) : root.dimBg
                                border.color: parent.checked ? root.clrGreen : root.subtext
                                border.width: 1; radius: 5
                            }
                            contentItem: Text {
                                text:  parent.text
                                color: parent.checked ? root.clrGreen : root.subtext
                                font.family: "Segoe UI"; font.pixelSize: 11; font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment:   Text.AlignVCenter
                            }
                            onCheckedChanged: root.addActive = checked
                        }

                        ActionBtn {
                            btnColor: root.clrGreen
                            text:     "+ Add Item"
                            onClicked: {
                                let name  = addNameField.text.trim()
                                let score = parseInt(addScoreField.text) || 0
                                if (!name) { root.lastOp = "✖  Enter a name"; return }
                                proxyModel.addItem(name, root.addCategory, score, root.addActive)
                                root.lastOp = "✔  Added \"" + name + "\"  ·  " + root.addCategory + "  ·  " + score
                                addNameField.text  = ""
                                addScoreField.text = ""
                            }
                        }

                        Divider {}

                        // ── Remove selected ───────────────────────────
                        ActionBtn {
                            btnColor: root.clrRed
                            text:     "✖  Remove Selected"
                            onClicked: {
                                if (root.selectedRow < 0) {
                                    root.lastOp = "✖  Nothing selected"
                                    return
                                }
                                let ok = proxyModel.removeProxyRow(root.selectedRow)
                                if (ok) {
                                    root.lastOp = "✔  Item removed"
                                    root.selectedRow = -1
                                } else {
                                    root.lastOp = "✖  Remove failed"
                                }
                            }
                        }

                        Item { height: 8 }
                    }
                }
            }
            // ════ end RIGHT ═══════════════════════════════════════════
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
