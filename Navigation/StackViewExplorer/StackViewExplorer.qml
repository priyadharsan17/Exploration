import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    visible: true
    width: 1100
    height: 700
    title: "StackView Explorer"
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

    component StyledField: TextField {
        color: root.textMain
        font { family: "Consolas"; pixelSize: 13 }
        background: Rectangle { color: root.dimBg; radius: 6 }
        placeholderTextColor: root.subtext
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

    // ── Status ────────────────────────────────────────────────────────────────
    property string statusMsg: "Stack initialised — depth: 1"

    function updateStatus(msg) {
        root.statusMsg = msg + "  |  depth: " + stack.depth
    }

    // ── Transition helpers ────────────────────────────────────────────────────
    property string currentTransition: "Slide"
    readonly property var transitionNames: ["Slide", "Fade", "Scale", "None"]

    // ═════════════════════════════════════════════════════════════════════════
    //  Pages defined as named components
    // ═════════════════════════════════════════════════════════════════════════

    // Page A ──────────────────────────────────────────────────────────────────
    component PageA: Rectangle {
        color: root.surface
        radius: 10

        // Lifecycle signals
        StackView.onActivated:   root.updateStatus("PageA activated")
        StackView.onDeactivated: root.updateStatus("PageA deactivated")
        Component.onCompleted:   console.log("PageA created")
        Component.onDestruction: console.log("PageA destroyed")

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 18

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "🏠  Page A"
                color: root.clrGreen
                font { family: "Segoe UI"; pixelSize: 28; bold: true }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Home page — always at the bottom of the stack."
                color: root.textMain
                font { family: "Segoe UI"; pixelSize: 14 }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "StackView.index: " + StackView.index
                color: root.subtext
                font { family: "Consolas"; pixelSize: 12 }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "StackView.status: " + StackView.status
                color: root.subtext
                font { family: "Consolas"; pixelSize: 12 }
            }
            ActionBtn {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                text: "Push Page B"
                btnColor: root.clrBlue
                onClicked: {
                    stack.push(pageBComp)
                    root.updateStatus("push → PageB")
                }
            }
            ActionBtn {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                text: "Push Page C"
                btnColor: root.clrOrange
                onClicked: {
                    stack.push(pageCComp)
                    root.updateStatus("push → PageC")
                }
            }
        }
    }

    // Page B ──────────────────────────────────────────────────────────────────
    component PageB: Rectangle {
        color: root.surface
        radius: 10

        StackView.onActivated:   root.updateStatus("PageB activated")
        StackView.onDeactivated: root.updateStatus("PageB deactivated")
        Component.onCompleted:   console.log("PageB created")
        Component.onDestruction: console.log("PageB destroyed")

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 18

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "📄  Page B"
                color: root.clrBlue
                font { family: "Segoe UI"; pixelSize: 28; bold: true }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Secondary page — pushed on top of Page A."
                color: root.textMain
                font { family: "Segoe UI"; pixelSize: 14 }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "StackView.index: " + StackView.index
                color: root.subtext
                font { family: "Consolas"; pixelSize: 12 }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "StackView.status: " + StackView.status
                color: root.subtext
                font { family: "Consolas"; pixelSize: 12 }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                ActionBtn {
                    Layout.preferredWidth: 130
                    text: "← Pop"
                    btnColor: root.clrRed
                    onClicked: {
                        stack.pop()
                        root.updateStatus("pop ← back")
                    }
                }
                ActionBtn {
                    Layout.preferredWidth: 180
                    text: "Replace → Page C"
                    btnColor: root.clrOrange
                    onClicked: {
                        stack.replace(pageCComp)
                        root.updateStatus("replace → PageC")
                    }
                }
                ActionBtn {
                    Layout.preferredWidth: 150
                    text: "Push Page D"
                    btnColor: root.accent
                    onClicked: {
                        stack.push(pageDComp, { pageTitle: "From B" })
                        root.updateStatus("push → PageD (props)")
                    }
                }
            }
        }
    }

    // Page C ──────────────────────────────────────────────────────────────────
    component PageC: Rectangle {
        color: root.surface
        radius: 10

        StackView.onActivated:   root.updateStatus("PageC activated")
        StackView.onDeactivated: root.updateStatus("PageC deactivated")
        Component.onCompleted:   console.log("PageC created")
        Component.onDestruction: console.log("PageC destroyed")

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 18

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "🗂  Page C"
                color: root.clrOrange
                font { family: "Segoe UI"; pixelSize: 28; bold: true }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Can be pushed or used as a replace target."
                color: root.textMain
                font { family: "Segoe UI"; pixelSize: 14 }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "StackView.index: " + StackView.index
                color: root.subtext
                font { family: "Consolas"; pixelSize: 12 }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "StackView.status: " + StackView.status
                color: root.subtext
                font { family: "Consolas"; pixelSize: 12 }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                ActionBtn {
                    Layout.preferredWidth: 130
                    text: "← Pop"
                    btnColor: root.clrRed
                    onClicked: {
                        stack.pop()
                        root.updateStatus("pop ← back")
                    }
                }
                ActionBtn {
                    Layout.preferredWidth: 160
                    text: "Pop to Root"
                    btnColor: root.clrYellow
                    onClicked: {
                        stack.pop(null)   // null = pop all the way to root
                        root.updateStatus("pop → root")
                    }
                }
            }
        }
    }

    // Page D — receives initial properties ────────────────────────────────────
    component PageD: Rectangle {
        property string pageTitle: "Default"
        color: root.surface
        radius: 10

        StackView.onActivated:   root.updateStatus("PageD activated")
        StackView.onDeactivated: root.updateStatus("PageD deactivated")
        Component.onCompleted:   console.log("PageD created, title=" + pageTitle)
        Component.onDestruction: console.log("PageD destroyed")

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 18

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "⚙️  Page D"
                color: root.accent
                font { family: "Segoe UI"; pixelSize: 28; bold: true }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Received initial property — pageTitle: \"" + pageTitle + "\""
                color: root.textMain
                font { family: "Segoe UI"; pixelSize: 14 }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "StackView.index: " + StackView.index
                color: root.subtext
                font { family: "Consolas"; pixelSize: 12 }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "StackView.status: " + StackView.status
                color: root.subtext
                font { family: "Consolas"; pixelSize: 12 }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                ActionBtn {
                    Layout.preferredWidth: 130
                    text: "← Pop"
                    btnColor: root.clrRed
                    onClicked: {
                        stack.pop()
                        root.updateStatus("pop ← back")
                    }
                }
                ActionBtn {
                    Layout.preferredWidth: 160
                    text: "Clear Stack"
                    btnColor: root.clrRed
                    onClicked: {
                        stack.clear()
                        stack.push(pageAComp)
                        root.updateStatus("clear + push PageA")
                    }
                }
            }
        }
    }

    // ── Component instantiators (used with push/replace) ─────────────────────
    Component { id: pageAComp; PageA {} }
    Component { id: pageBComp; PageB {} }
    Component { id: pageCComp; PageC {} }
    Component { id: pageDComp; PageD {} }

    // ═════════════════════════════════════════════════════════════════════════
    //  Transition sets
    // ═════════════════════════════════════════════════════════════════════════

    // Slide transitions (default)
    property Transition slideEnter: Transition {
        NumberAnimation { property: "x"; from: stack.width; to: 0; duration: 280; easing.type: Easing.OutCubic }
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
    }
    property Transition slideExit: Transition {
        NumberAnimation { property: "x"; from: 0; to: -stack.width * 0.35; duration: 280; easing.type: Easing.OutCubic }
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 180 }
    }
    property Transition slidePopEnter: Transition {
        NumberAnimation { property: "x"; from: -stack.width * 0.35; to: 0; duration: 280; easing.type: Easing.OutCubic }
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180 }
    }
    property Transition slidePopExit: Transition {
        NumberAnimation { property: "x"; from: 0; to: stack.width; duration: 280; easing.type: Easing.OutCubic }
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 180 }
    }

    // Fade transitions
    property Transition fadeEnter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.InOutQuad }
    }
    property Transition fadeExit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
    }

    // Scale transitions
    property Transition scaleEnter: Transition {
        NumberAnimation { property: "scale"; from: 0.85; to: 1.0; duration: 280; easing.type: Easing.OutBack }
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
    }
    property Transition scaleExit: Transition {
        NumberAnimation { property: "scale"; from: 1.0; to: 0.85; duration: 200 }
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
    }

    // No-op (instant) transitions
    property Transition noopTransition: Transition {}

    function applyTransitions() {
        switch (root.currentTransition) {
        case "Slide":
            stack.pushEnter  = root.slideEnter
            stack.pushExit   = root.slideExit
            stack.popEnter   = root.slidePopEnter
            stack.popExit    = root.slidePopExit
            stack.replaceEnter = root.slideEnter
            stack.replaceExit  = root.slideExit
            break
        case "Fade":
            stack.pushEnter  = root.fadeEnter
            stack.pushExit   = root.fadeExit
            stack.popEnter   = root.fadeEnter
            stack.popExit    = root.fadeExit
            stack.replaceEnter = root.fadeEnter
            stack.replaceExit  = root.fadeExit
            break
        case "Scale":
            stack.pushEnter  = root.scaleEnter
            stack.pushExit   = root.scaleExit
            stack.popEnter   = root.scaleEnter
            stack.popExit    = root.scaleExit
            stack.replaceEnter = root.scaleEnter
            stack.replaceExit  = root.scaleExit
            break
        case "None":
            stack.pushEnter  = root.noopTransition
            stack.pushExit   = root.noopTransition
            stack.popEnter   = root.noopTransition
            stack.popExit    = root.noopTransition
            stack.replaceEnter = root.noopTransition
            stack.replaceExit  = root.noopTransition
            break
        }
    }

    // ═════════════════════════════════════════════════════════════════════════
    //  Root layout
    // ═════════════════════════════════════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // Title bar ──────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 50
            color: root.surface

            RowLayout {
                anchors { fill: parent; leftMargin: 16; rightMargin: 16 }

                Text {
                    text: "StackView Explorer"
                    color: root.textMain
                    font { family: "Segoe UI"; pixelSize: 18; bold: true }
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "depth: " + stack.depth
                    color: root.accent
                    font { family: "Consolas"; pixelSize: 14; bold: true }
                }
            }
        }

        Divider {}

        // Main area ──────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ── StackView ──────────────────────────────────────────────────
            StackView {
                id: stack
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Initial page
                initialItem: pageAComp

                // Apply default (slide) transitions on startup
                Component.onCompleted: {
                    root.applyTransitions()
                    root.updateStatus("PageA activated")
                }

                pushEnter:    root.slideEnter
                pushExit:     root.slideExit
                popEnter:     root.slidePopEnter
                popExit:      root.slidePopExit
                replaceEnter: root.slideEnter
                replaceExit:  root.slideExit

                // Clip so pages don't bleed during slide
                clip: true

                // Subtle inner padding around page content
                Pane {
                    anchors.fill: parent
                    padding: 16
                    background: Item {}

                    // The StackView itself is the content — the Pane just provides
                    // the padding clip region. Pages fill the StackView already,
                    // so we override the StackView padding with a wrapper instead.
                }
            }

            // Right divider
            Rectangle { width: 1; Layout.fillHeight: true; color: root.dimBg }

            // ── Control panel ──────────────────────────────────────────────
            Rectangle {
                implicitWidth: 292
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

                        SectionLabel { text: "NAVIGATION" }
                        Divider {}

                        ActionBtn {
                            Layout.fillWidth: true
                            text: "Push Page A"
                            btnColor: root.clrGreen
                            onClicked: {
                                stack.push(pageAComp)
                                root.updateStatus("push → PageA")
                            }
                        }
                        ActionBtn {
                            Layout.fillWidth: true
                            text: "Push Page B"
                            btnColor: root.clrBlue
                            onClicked: {
                                stack.push(pageBComp)
                                root.updateStatus("push → PageB")
                            }
                        }
                        ActionBtn {
                            Layout.fillWidth: true
                            text: "Push Page C"
                            btnColor: root.clrOrange
                            onClicked: {
                                stack.push(pageCComp)
                                root.updateStatus("push → PageC")
                            }
                        }
                        ActionBtn {
                            Layout.fillWidth: true
                            text: "Push Page D (with props)"
                            btnColor: root.accent
                            onClicked: {
                                stack.push(pageDComp, { pageTitle: "From panel" })
                                root.updateStatus("push → PageD (props)")
                            }
                        }

                        Item { implicitHeight: 6 }
                        Divider {}
                        Item { implicitHeight: 2 }

                        ActionBtn {
                            Layout.fillWidth: true
                            text: "Pop ←"
                            btnColor: root.clrRed
                            enabled: stack.depth > 1
                            onClicked: {
                                stack.pop()
                                root.updateStatus("pop ← back")
                            }
                        }
                        ActionBtn {
                            Layout.fillWidth: true
                            text: "Pop to Root"
                            btnColor: root.clrYellow
                            enabled: stack.depth > 1
                            onClicked: {
                                stack.pop(null)
                                root.updateStatus("pop → root")
                            }
                        }
                        ActionBtn {
                            Layout.fillWidth: true
                            text: "Replace → Page C"
                            btnColor: root.clrOrange
                            onClicked: {
                                stack.replace(pageCComp)
                                root.updateStatus("replace → PageC")
                            }
                        }
                        ActionBtn {
                            Layout.fillWidth: true
                            text: "Clear Stack"
                            btnColor: root.clrRed
                            onClicked: {
                                stack.clear()
                                stack.push(pageAComp)
                                root.updateStatus("clear + reset to PageA")
                            }
                        }

                        Item { implicitHeight: 6 }
                        SectionLabel { text: "TRANSITIONS" }
                        Divider {}

                        Repeater {
                            model: root.transitionNames
                            delegate: ActionBtn {
                                required property string modelData
                                Layout.fillWidth: true
                                text: modelData
                                btnColor: root.currentTransition === modelData
                                          ? root.accent : root.dimBg
                                contentItem: Text {
                                    text: parent.text
                                    color: root.currentTransition === parent.text
                                           ? "#1e1e2e" : root.textMain
                                    font { family: "Segoe UI"; pixelSize: 13; bold: true }
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    root.currentTransition = modelData
                                    root.applyTransitions()
                                    root.updateStatus("transition set to " + modelData)
                                }
                            }
                        }

                        Item { implicitHeight: 6 }
                        SectionLabel { text: "STACK INFO" }
                        Divider {}

                        Text {
                            Layout.fillWidth: true
                            text: "depth: " + stack.depth
                            color: root.textMain
                            font { family: "Consolas"; pixelSize: 13 }
                            wrapMode: Text.Wrap
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "currentItem: " + (stack.currentItem ? stack.currentItem.toString().split("(")[0] : "null")
                            color: root.textMain
                            font { family: "Consolas"; pixelSize: 11 }
                            wrapMode: Text.Wrap
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "busy: " + stack.busy
                            color: stack.busy ? root.clrYellow : root.subtext
                            font { family: "Consolas"; pixelSize: 13 }
                            wrapMode: Text.Wrap
                        }

                        Item { implicitHeight: 20 }
                    }
                }
            }
        }

        // Status bar ─────────────────────────────────────────────────────────
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
