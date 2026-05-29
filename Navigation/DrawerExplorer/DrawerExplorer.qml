import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1100
    height: 700
    title: "Drawer · SwipeView · TabBar Explorer"
    color: "#1e1e2e"

    // ── Palette ──────────────────────────────────────────────────────────────
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
            color: parent.down ? Qt.darker(parent.btnColor, 1.25)
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

    // ── State ─────────────────────────────────────────────────────────────────
    property string statusMsg:    "Ready"
    property bool   drawerModal:  true
    property int    drawerEdge:   Qt.LeftEdge   // or Qt.BottomEdge

    function status(msg) { root.statusMsg = msg }

    // ── Page data ─────────────────────────────────────────────────────────────
    readonly property var pages: [
        { label: "Dashboard", icon: "⬡", color: "#a6e3a1" },
        { label: "Profile",   icon: "◉", color: "#89b4fa" },
        { label: "Settings",  icon: "⚙",  color: "#cba6f7" },
        { label: "About",     icon: "ℹ",  color: "#fab387" }
    ]

    // ═════════════════════════════════════════════════════════════════════════
    //  Navigation Drawer
    // ═════════════════════════════════════════════════════════════════════════
    Drawer {
        id: drawer
        width:  root.drawerEdge === Qt.LeftEdge ? 240 : root.width
        height: root.drawerEdge === Qt.BottomEdge ? 280 : root.height
        edge:   root.drawerEdge
        modal:  root.drawerModal

        // Dark overlay dim colour (modal only)
        Overlay.modal: Rectangle { color: "#88000000" }

        background: Rectangle { color: root.surface }

        onOpened:  root.status("Drawer opened  — position: " + drawer.position.toFixed(2))
        onClosed:  root.status("Drawer closed  — position: " + drawer.position.toFixed(2))

        ColumnLayout {
            anchors { fill: parent; margins: 0 }
            spacing: 0

            // Drawer header
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 64
                color: root.dimBg

                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    Text {
                        text: "Navigation"
                        color: root.textMain
                        font { family: "Segoe UI"; pixelSize: 16; bold: true }
                    }
                    Item { Layout.fillWidth: true }
                    // Close button
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: closeArea.containsMouse ? root.dimBg : "transparent"
                        Text { anchors.centerIn: parent; text: "✕"; color: root.subtext; font.pixelSize: 14 }
                        MouseArea { id: closeArea; anchors.fill: parent; hoverEnabled: true
                            onClicked: drawer.close() }
                    }
                }
            }

            // Nav items
            Repeater {
                model: root.pages
                delegate: Rectangle {
                    required property var   modelData
                    required property int   index
                    Layout.fillWidth: true
                    implicitHeight: 52
                    color: swipeView.currentIndex === index
                           ? Qt.rgba(1,1,1,0.07) : "transparent"

                    // Active indicator bar
                    Rectangle {
                        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                        width: 3
                        color: swipeView.currentIndex === index
                               ? modelData.color : "transparent"
                        radius: 2
                    }

                    RowLayout {
                        anchors { fill: parent; leftMargin: 20; rightMargin: 16 }
                        spacing: 14

                        Text {
                            text: modelData.icon
                            color: swipeView.currentIndex === index
                                   ? modelData.color : root.subtext
                            font.pixelSize: 18
                        }
                        Text {
                            text: modelData.label
                            color: swipeView.currentIndex === index
                                   ? root.textMain : root.subtext
                            font { family: "Segoe UI"; pixelSize: 14;
                                   bold: swipeView.currentIndex === index }
                        }
                        Item { Layout.fillWidth: true }
                        // Current-page chevron
                        Text {
                            visible: swipeView.currentIndex === index
                            text: "›"
                            color: modelData.color
                            font { pixelSize: 20; bold: true }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            swipeView.currentIndex = index
                            root.status("Drawer → " + modelData.label
                                        + "  (index " + index + ")")
                            drawer.close()
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Drawer footer
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: root.dimBg
            }
            Text {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.bottomMargin: 14
                Layout.topMargin: 10
                text: "position: " + drawer.position.toFixed(3)
                color: root.subtext
                font { family: "Consolas"; pixelSize: 11 }
            }
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    //  Root layout
    // ═════════════════════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── App bar ──────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            color: root.surface

            RowLayout {
                anchors { fill: parent; leftMargin: 8; rightMargin: 16 }
                spacing: 10

                // Hamburger button
                Rectangle {
                    width: 40; height: 40; radius: 6
                    color: hamArea.containsMouse ? root.dimBg : "transparent"

                    Column {
                        anchors.centerIn: parent
                        spacing: 5
                        Repeater {
                            model: 3
                            Rectangle { width: 18; height: 2; radius: 1; color: root.textMain }
                        }
                    }
                    MouseArea {
                        id: hamArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            drawer.open()
                            root.status("Drawer opened via hamburger")
                        }
                    }
                }

                Text {
                    text: root.pages[swipeView.currentIndex].label
                    color: root.textMain
                    font { family: "Segoe UI"; pixelSize: 17; bold: true }
                }

                Item { Layout.fillWidth: true }

                // TabBar ──────────────────────────────────────────────────────
                TabBar {
                    id: tabBar
                    currentIndex: swipeView.currentIndex

                    background: Rectangle { color: "transparent" }

                    Repeater {
                        model: root.pages
                        delegate: TabButton {
                            required property var   modelData
                            required property int   index
                            implicitWidth: 110
                            implicitHeight: 36

                            contentItem: Text {
                                text: parent.modelData.icon + "  " + parent.modelData.label
                                color: tabBar.currentIndex === parent.index
                                       ? parent.modelData.color : root.subtext
                                font { family: "Segoe UI"; pixelSize: 12;
                                       bold: tabBar.currentIndex === parent.index }
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: "transparent"
                                // Active underline
                                Rectangle {
                                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                                    width: tabBar.currentIndex === parent.parent.index ? parent.width - 16 : 0
                                    height: 2
                                    radius: 1
                                    color: parent.parent.modelData.color
                                    Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                                }
                            }

                            onClicked: {
                                swipeView.currentIndex = index
                                root.status("Tab → " + modelData.label
                                            + "  (index " + index + ")")
                            }
                        }
                    }
                }
            }
        }

        // Tab underline separator
        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: root.dimBg }

        // ── Main area ─────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // SwipeView ───────────────────────────────────────────────────────
            SwipeView {
                id: swipeView
                Layout.fillWidth: true
                Layout.fillHeight: true
                interactive: swipeInteractive.checked
                clip: true

                onCurrentIndexChanged: {
                    root.status("SwipeView → index " + currentIndex
                                + "  (" + root.pages[currentIndex].label + ")")
                }

                // Page 0 — Dashboard ──────────────────────────────────────────
                Rectangle {
                    color: "#1e1e2e"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 20
                        width: Math.min(parent.width * 0.7, 480)

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "⬡  Dashboard"
                            color: root.clrGreen
                            font { family: "Segoe UI"; pixelSize: 28; bold: true }
                        }

                        // Stat cards row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Repeater {
                                model: [
                                    { label: "Users",    val: "1,284", clr: root.clrBlue   },
                                    { label: "Sessions", val:   "347", clr: root.clrGreen  },
                                    { label: "Errors",   val:    "12", clr: root.clrRed    },
                                    { label: "Uptime",   val: "99.9%", clr: root.clrYellow }
                                ]
                                delegate: Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    implicitHeight: 72
                                    color: root.surface
                                    radius: 10
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Text { Layout.alignment: Qt.AlignHCenter
                                               text: modelData.val
                                               color: modelData.clr
                                               font { family: "Segoe UI"; pixelSize: 22; bold: true } }
                                        Text { Layout.alignment: Qt.AlignHCenter
                                               text: modelData.label
                                               color: root.subtext
                                               font { family: "Segoe UI"; pixelSize: 11 } }
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "SwipeView page 0 — swipe left/right or use the TabBar."
                            color: root.subtext
                            font { family: "Segoe UI"; pixelSize: 13 }
                        }
                    }
                }

                // Page 1 — Profile ────────────────────────────────────────────
                Rectangle {
                    color: "#1e1e2e"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 16
                        width: Math.min(parent.width * 0.55, 360)

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "◉  Profile"
                            color: root.clrBlue
                            font { family: "Segoe UI"; pixelSize: 28; bold: true }
                        }

                        // Avatar circle
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 72; height: 72; radius: 36
                            color: root.clrBlue
                            Text { anchors.centerIn: parent
                                   text: "P"; color: "#1e1e2e"
                                   font { pixelSize: 30; bold: true } }
                        }

                        Repeater {
                            model: ["Display name", "Email", "Username"]
                            delegate: ColumnLayout {
                                required property string modelData
                                Layout.fillWidth: true
                                spacing: 4
                                Text { text: modelData; color: root.subtext
                                       font { family: "Segoe UI"; pixelSize: 11 } }
                                Rectangle {
                                    Layout.fillWidth: true; implicitHeight: 34; radius: 6
                                    color: root.dimBg
                                    Text { anchors { left: parent.left; leftMargin: 10
                                                     verticalCenter: parent.verticalCenter }
                                           text: "—"; color: root.subtext
                                           font { family: "Consolas"; pixelSize: 13 } }
                                }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "SwipeView page 1"
                            color: root.subtext; font { family: "Segoe UI"; pixelSize: 13 }
                        }
                    }
                }

                // Page 2 — Settings ───────────────────────────────────────────
                Rectangle {
                    color: "#1e1e2e"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 14
                        width: Math.min(parent.width * 0.55, 360)

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "⚙  Settings"
                            color: root.accent
                            font { family: "Segoe UI"; pixelSize: 28; bold: true }
                        }

                        Repeater {
                            model: [
                                { label: "Dark mode",          on: true  },
                                { label: "Notifications",       on: false },
                                { label: "Auto-save",           on: true  },
                                { label: "Analytics opt-out",   on: false }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 44; radius: 8
                                color: root.surface

                                property bool toggled: modelData.on

                                RowLayout {
                                    anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                                    Text { text: modelData.label; color: root.textMain
                                           font { family: "Segoe UI"; pixelSize: 13 } }
                                    Item { Layout.fillWidth: true }
                                    // Mini toggle pill
                                    Rectangle {
                                        width: 42; height: 22; radius: 11
                                        color: parent.parent.toggled ? root.accent : root.dimBg
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Rectangle {
                                            width: 16; height: 16; radius: 8
                                            anchors.verticalCenter: parent.verticalCenter
                                            x: parent.parent.toggled ? parent.width - width - 3 : 3
                                            color: "#1e1e2e"
                                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                        }
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: parent.parent.parent.toggled = !parent.parent.parent.toggled
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "SwipeView page 2"
                            color: root.subtext; font { family: "Segoe UI"; pixelSize: 13 }
                        }
                    }
                }

                // Page 3 — About ──────────────────────────────────────────────
                Rectangle {
                    color: "#1e1e2e"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 16
                        width: Math.min(parent.width * 0.6, 400)

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "ℹ  About"
                            color: root.clrOrange
                            font { family: "Segoe UI"; pixelSize: 28; bold: true }
                        }

                        Repeater {
                            model: [
                                { k: "Framework",  v: "PySide6 6.11.1" },
                                { k: "Qt Version", v: "6.11.1"         },
                                { k: "Explorer",   v: "DrawerExplorer"  },
                                { k: "Theme",      v: "Catppuccin Mocha"}
                            ]
                            delegate: RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Rectangle { implicitWidth: 110; implicitHeight: 32; radius: 6; color: root.surface
                                    Text { anchors.centerIn: parent; text: modelData.k
                                           color: root.subtext; font { family: "Segoe UI"; pixelSize: 12 } } }
                                Rectangle { Layout.fillWidth: true; implicitHeight: 32; radius: 6; color: root.dimBg
                                    Text { anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                           text: modelData.v; color: root.textMain
                                           font { family: "Consolas"; pixelSize: 12 } } }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "SwipeView page 3"
                            color: root.subtext; font { family: "Segoe UI"; pixelSize: 13 }
                        }
                    }
                }
            }

            // Right divider
            Rectangle { width: 1; Layout.fillHeight: true; color: root.dimBg }

            // ── Control panel ──────────────────────────────────────────────
            Rectangle {
                implicitWidth: 264
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

                        // ── Drawer controls ───────────────────────────────
                        SectionLabel { text: "DRAWER" }
                        Divider {}

                        ActionBtn {
                            Layout.fillWidth: true
                            text: "Open Drawer"
                            btnColor: root.clrGreen
                            onClicked: { drawer.open(); root.status("drawer.open()") }
                        }
                        ActionBtn {
                            Layout.fillWidth: true
                            text: "Close Drawer"
                            btnColor: root.clrRed
                            onClicked: { drawer.close(); root.status("drawer.close()") }
                        }

                        // Edge selector
                        SectionLabel { text: "edge" }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Repeater {
                                model: [{ label: "Left", edge: Qt.LeftEdge }, { label: "Bottom", edge: Qt.BottomEdge }]
                                delegate: ActionBtn {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    text: modelData.label
                                    btnColor: root.drawerEdge === modelData.edge ? root.accent : root.dimBg
                                    contentItem: Text {
                                        text: parent.text
                                        color: root.drawerEdge === parent.modelData.edge ? "#1e1e2e" : root.textMain
                                        font { family: "Segoe UI"; pixelSize: 13; bold: true }
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: {
                                        drawer.close()
                                        root.drawerEdge = modelData.edge
                                        root.status("drawer.edge → " + modelData.label)
                                    }
                                }
                            }
                        }

                        // Modal toggle
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "modal"; color: root.textMain
                                   font { family: "Segoe UI"; pixelSize: 13 }
                                   Layout.fillWidth: true }
                            Button {
                                id: modalBtn
                                implicitWidth: 56; implicitHeight: 28
                                checkable: true; checked: root.drawerModal
                                contentItem: Text {
                                    text: parent.checked ? "ON" : "OFF"
                                    color: parent.checked ? "#1e1e2e" : root.textMain
                                    font { family: "Segoe UI"; pixelSize: 12; bold: true }
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: parent.checked ? root.accent : root.dimBg; radius: 6
                                }
                                onToggled: {
                                    root.drawerModal = checked
                                    root.status("drawer.modal → " + checked)
                                }
                            }
                        }

                        // Drawer position readout
                        Text {
                            Layout.fillWidth: true
                            text: "position: " + drawer.position.toFixed(3)
                            color: root.textMain
                            font { family: "Consolas"; pixelSize: 12 }
                        }

                        Item { implicitHeight: 4 }

                        // ── SwipeView controls ────────────────────────────
                        SectionLabel { text: "SWIPEVIEW" }
                        Divider {}

                        // Page jump buttons
                        Repeater {
                            model: root.pages
                            delegate: ActionBtn {
                                required property var   modelData
                                required property int   index
                                Layout.fillWidth: true
                                text: modelData.icon + "  " + modelData.label
                                btnColor: swipeView.currentIndex === index ? root.accent : root.dimBg
                                contentItem: Text {
                                    text: parent.text
                                    color: swipeView.currentIndex === parent.index ? "#1e1e2e" : root.textMain
                                    font { family: "Segoe UI"; pixelSize: 13; bold: true }
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    swipeView.currentIndex = index
                                    root.status("SwipeView.currentIndex = " + index)
                                }
                            }
                        }

                        // Interactive toggle
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "interactive (swipe)"; color: root.textMain
                                   font { family: "Segoe UI"; pixelSize: 13 }
                                   Layout.fillWidth: true }
                            Button {
                                id: swipeInteractive
                                implicitWidth: 56; implicitHeight: 28
                                checkable: true; checked: true
                                contentItem: Text {
                                    text: parent.checked ? "ON" : "OFF"
                                    color: parent.checked ? "#1e1e2e" : root.textMain
                                    font { family: "Segoe UI"; pixelSize: 12; bold: true }
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                background: Rectangle {
                                    color: parent.checked ? root.clrGreen : root.dimBg; radius: 6
                                }
                                onToggled: root.status("swipe interactive → " + checked)
                            }
                        }

                        Item { implicitHeight: 4 }

                        // ── SwipeView info ────────────────────────────────
                        SectionLabel { text: "LIVE INFO" }
                        Divider {}

                        Text {
                            Layout.fillWidth: true
                            text: "SwipeView.count: " + swipeView.count
                            color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "currentIndex: " + swipeView.currentIndex
                            color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "TabBar.currentIndex: " + tabBar.currentIndex
                            color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "Drawer.position: " + drawer.position.toFixed(3)
                            color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "Drawer.modal: " + drawer.modal
                            color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "Drawer.edge: " + (root.drawerEdge === Qt.LeftEdge ? "LeftEdge" : "BottomEdge")
                            color: root.textMain; font { family: "Consolas"; pixelSize: 12 }
                        }

                        Item { implicitHeight: 20 }
                    }
                }
            }
        }

        // ── Status bar ───────────────────────────────────────────────────────
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
