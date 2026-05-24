import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ══════════════════════════════════════════════════════════════════════
//  WINDOW 1 — Playground  (full-screen, no side chrome)
// ══════════════════════════════════════════════════════════════════════
ApplicationWindow {
    id: playWin
    visible: true
    width: 920
    height: 700
    minimumWidth: 600
    minimumHeight: 500
    title: "Number Animation Explorer — Playground"
    color: "#1e1e2e"

    // ── Palette ──────────────────────────────────────────────────────
    readonly property color surface:   "#313244"
    readonly property color dimBg:     "#45475a"
    readonly property color textMain:  "#cdd6f4"
    readonly property color accent:    "#cba6f7"
    readonly property color clrBlue:   "#89b4fa"
    readonly property color clrRed:    "#f38ba8"
    readonly property color clrGreen:  "#a6e3a1"
    readonly property color clrTeal:   "#89dceb"
    readonly property color clrOrange: "#fab387"

    // ── Easing showcase state ─────────────────────────────────────────
    property bool showcaseLaunched: false

    readonly property var easingDemos: [
        { name: "Linear",       type: Easing.Linear,       clr: "#f38ba8" },
        { name: "InOutQuad",    type: Easing.InOutQuad,    clr: "#fab387" },
        { name: "OutBounce",    type: Easing.OutBounce,    clr: "#f9e2af" },
        { name: "OutElastic",   type: Easing.OutElastic,   clr: "#a6e3a1" },
        { name: "OutBack",      type: Easing.OutBack,      clr: "#89dceb" },
        { name: "InOutExpo",    type: Easing.InOutExpo,    clr: "#cba6f7" },
    ]

    // ── Root layout ───────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Hint banner
        Rectangle {
            Layout.fillWidth: true
            height: 28; radius: 14
            color: playWin.dimBg
            Text {
                anchors.centerIn: parent
                text: "Resize this window freely  |  Adjust settings in the Properties window"
                font.family: "Segoe UI"; font.pixelSize: 11
                color: playWin.textMain
            }
        }

        // ── 2 × 2 demo tiles ─────────────────────────────────────────
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            columnSpacing: 10; rowSpacing: 10

            // ───────────────────────────────────────────────────────────
            //  TILE A · Behavior on property
            // ───────────────────────────────────────────────────────────
            Rectangle {
                id: tileA
                Layout.fillWidth: true; Layout.fillHeight: true
                color: playWin.surface; radius: 8; clip: true

                Rectangle {
                    id: tileAHead
                    width: parent.width; height: 30; radius: 4
                    color: playWin.dimBg
                    Rectangle { width: parent.width; height: 8; anchors.bottom: parent.bottom; color: playWin.dimBg }
                    Text { anchors.centerIn: parent; text: "A · Behavior on property"
                           font.family: "Consolas"; font.pixelSize: 11; font.bold: true; color: playWin.accent }
                }

                Rectangle {
                    id: behaviorBox
                    width: 60; height: 60; radius: 8
                    color: playWin.clrBlue
                    x: 16
                    y: tileAHead.height + (tileA.height - tileAHead.height) / 2 - 30

                    // ── The three Behaviors being demonstrated ──────
                    Behavior on x {
                        NumberAnimation { duration: durSpin.value; easing.type: easingCombo.currentValue }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: durSpin.value }
                    }
                    Behavior on rotation {
                        NumberAnimation { duration: durSpin.value; easing.type: easingCombo.currentValue }
                    }

                    Text { anchors.centerIn: parent; text: "B"
                           font.bold: true; font.pixelSize: 18; color: "#1e1e2e" }
                }

                Text {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 6 }
                    text: "x=" + Math.round(behaviorBox.x) +
                          "  opacity=" + behaviorBox.opacity.toFixed(2) +
                          "  rot=" + Math.round(behaviorBox.rotation) + "°"
                    font.family: "Consolas"; font.pixelSize: 10
                    color: playWin.textMain; opacity: 0.55
                }
            }

            // ───────────────────────────────────────────────────────────
            //  TILE B · Standalone NumberAnimation
            // ───────────────────────────────────────────────────────────
            Rectangle {
                id: tileB
                Layout.fillWidth: true; Layout.fillHeight: true
                color: playWin.surface; radius: 8; clip: true

                Rectangle {
                    id: tileBHead
                    width: parent.width; height: 30; radius: 4
                    color: playWin.dimBg
                    Rectangle { width: parent.width; height: 8; anchors.bottom: parent.bottom; color: playWin.dimBg }
                    Text { anchors.centerIn: parent; text: "B · Standalone NumberAnimation"
                           font.family: "Consolas"; font.pixelSize: 11; font.bold: true; color: playWin.accent }
                }

                // Track line
                Rectangle {
                    anchors { left: parent.left; right: parent.right
                              verticalCenter: parent.verticalCenter; verticalCenterOffset: 12 }
                    anchors.leftMargin: 20; anchors.rightMargin: 20
                    height: 2; color: playWin.dimBg
                }

                Rectangle {
                    id: ball
                    width: 46; height: 46; radius: 23
                    color: playWin.clrRed
                    x: 20
                    y: tileBHead.height + (tileB.height - tileBHead.height) / 2 - 23 + 12

                    // ── The standalone animation ────────────────────
                    NumberAnimation {
                        id: ballAnim
                        target: ball
                        property: "x"
                        from: 20
                        to: tileB.width - ball.width - 20
                        duration: durSpin.value
                        easing.type: easingCombo.currentValue
                        loops: loopsSpin.value === 0 ? Animation.Infinite : loopsSpin.value
                    }

                    Text { anchors.centerIn: parent; text: "●"
                           font.pixelSize: 16; color: "#1e1e2e" }
                }

                Text {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 6 }
                    text: "x=" + Math.round(ball.x) +
                          "  running=" + ballAnim.running +
                          "  progress=" + ballAnim.progress.toFixed(2)
                    font.family: "Consolas"; font.pixelSize: 10
                    color: playWin.textMain; opacity: 0.55
                }
            }

            // ───────────────────────────────────────────────────────────
            //  TILE C · State Transitions
            // ───────────────────────────────────────────────────────────
            Rectangle {
                id: tileC
                Layout.fillWidth: true; Layout.fillHeight: true
                color: playWin.surface; radius: 8; clip: true

                Rectangle {
                    id: tileCHead
                    width: parent.width; height: 30; radius: 4
                    color: playWin.dimBg
                    Rectangle { width: parent.width; height: 8; anchors.bottom: parent.bottom; color: playWin.dimBg }
                    Text { anchors.centerIn: parent; text: "C · State Transitions"
                           font.family: "Consolas"; font.pixelSize: 11; font.bold: true; color: playWin.accent }
                }

                Rectangle {
                    id: stateCard
                    width: 120; height: 72; radius: 10
                    anchors { horizontalCenter: parent.horizontalCenter
                              verticalCenter: parent.verticalCenter; verticalCenterOffset: 10 }
                    color: playWin.clrGreen
                    state: "RELEASED"

                    // ── States and Transition ───────────────────────
                    states: [
                        State {
                            name: "PRESSED"
                            PropertyChanges { target: stateCard; scale: 1.35; color: playWin.clrOrange; rotation: 6 }
                        },
                        State {
                            name: "RELEASED"
                            PropertyChanges { target: stateCard; scale: 1.0; color: playWin.clrGreen; rotation: 0 }
                        }
                    ]
                    transitions: Transition {
                        NumberAnimation { properties: "scale,rotation"; duration: durSpin.value; easing.type: easingCombo.currentValue }
                        ColorAnimation  { properties: "color";          duration: durSpin.value / 2 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: stateCard.state === "PRESSED" ? "PRESSED!" : "Hold me"
                        font.bold: true; font.pixelSize: 13; color: "#1e1e2e"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed:  stateCard.state = "PRESSED"
                        onReleased: stateCard.state = "RELEASED"
                    }
                }

                Text {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 6 }
                    text: "scale=" + stateCard.scale.toFixed(2) +
                          "  rot=" + Math.round(stateCard.rotation) + "°" +
                          "  state=" + stateCard.state
                    font.family: "Consolas"; font.pixelSize: 10
                    color: playWin.textMain; opacity: 0.55
                }
            }

            // ───────────────────────────────────────────────────────────
            //  TILE D · Python Backend → Behavior
            // ───────────────────────────────────────────────────────────
            Rectangle {
                id: tileD
                Layout.fillWidth: true; Layout.fillHeight: true
                color: playWin.surface; radius: 8; clip: true

                Rectangle {
                    id: tileDHead
                    width: parent.width; height: 30; radius: 4
                    color: playWin.dimBg
                    Rectangle { width: parent.width; height: 8; anchors.bottom: parent.bottom; color: playWin.dimBg }
                    Text { anchors.centerIn: parent; text: "D · Python Signal → Behavior"
                           font.family: "Consolas"; font.pixelSize: 11; font.bold: true; color: playWin.accent }
                }

                // Progress track
                Rectangle {
                    id: progTrack
                    anchors { left: parent.left; right: parent.right
                              verticalCenter: parent.verticalCenter; verticalCenterOffset: 10 }
                    anchors.leftMargin: 20; anchors.rightMargin: 20
                    height: 26; radius: 13; color: playWin.dimBg

                    // ── Fill bar with Behavior on width ─────────────
                    Rectangle {
                        id: progFill
                        height: parent.height; radius: parent.radius
                        color: playWin.clrTeal

                        Behavior on width {
                            NumberAnimation { duration: durSpin.value; easing.type: easingCombo.currentValue }
                        }

                        width: backend.value * progTrack.width
                    }

                    Text {
                        anchors.centerIn: parent
                        text: (backend.value * 100).toFixed(1) + "%"
                        font.family: "Consolas"; font.pixelSize: 11; font.bold: true
                        color: playWin.textMain
                    }
                }

                Text {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 6 }
                    text: "backend.value=" + backend.value.toFixed(3) +
                          "  bar.width=" + Math.round(progFill.width) + "px"
                    font.family: "Consolas"; font.pixelSize: 10
                    color: playWin.textMain; opacity: 0.55
                }
            }
        } // end 2×2 GridLayout

        // ── Easing Showcase strip ─────────────────────────────────────
        Rectangle {
            id: showcaseRect
            Layout.fillWidth: true
            height: 156
            color: playWin.surface; radius: 8; clip: true

            Text {
                id: showcaseLabel
                anchors { top: parent.top; left: parent.left; topMargin: 6; leftMargin: 10 }
                text: "Easing Showcase — all six curves launched simultaneously"
                font.family: "Consolas"; font.bold: true; font.pixelSize: 11
                color: playWin.accent
            }

            // Dot rows
            Item {
                id: dotArea
                anchors {
                    top: showcaseLabel.bottom; left: parent.left; right: parent.right
                    bottom: parent.bottom
                    topMargin: 2; leftMargin: 4; rightMargin: 4; bottomMargin: 4
                }

                Repeater {
                    model: playWin.easingDemos
                    delegate: Item {
                        readonly property real rowH: dotArea.height / playWin.easingDemos.length
                        width: dotArea.width
                        height: rowH
                        y: index * rowH

                        // Curve label
                        Text {
                            anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                            text: modelData.name
                            font.family: "Consolas"; font.pixelSize: 10
                            color: modelData.clr; width: 86
                        }

                        // Track line
                        Rectangle {
                            anchors { left: parent.left; leftMargin: 96; right: parent.right
                                      rightMargin: 4; verticalCenter: parent.verticalCenter }
                            height: 1; color: playWin.dimBg; opacity: 0.6
                        }

                        // Animated dot — Behavior fires when showcaseLaunched toggles
                        Rectangle {
                            width: 13; height: 13; radius: 7
                            color: modelData.clr
                            anchors.verticalCenter: parent.verticalCenter
                            x: playWin.showcaseLaunched ? (parent.width - 17) : 96

                            Behavior on x {
                                NumberAnimation {
                                    duration: showcaseDurSpin.value
                                    easing.type: modelData.type
                                }
                            }
                        }
                    }
                }
            }
        } // end showcase strip

    } // end root ColumnLayout

    Component.onCompleted: ctrlWin.show()

    // ══════════════════════════════════════════════════════════════════
    //  WINDOW 2 — Properties / Controls  (separate OS window, stays on top)
    // ══════════════════════════════════════════════════════════════════
    Window {
        id: ctrlWin
        title: "Animation Properties"
        width: 330; height: 740
        minimumWidth: 290; minimumHeight: 500
        color: "#1e1e2e"
        flags: Qt.Window | Qt.WindowStaysOnTopHint

        Component.onCompleted: {
            x = playWin.x + playWin.width + 10
            y = playWin.y
        }

        readonly property color dimBg:     "#45475a"
        readonly property color textMain:  "#cdd6f4"
        readonly property color accent:    "#cba6f7"
        readonly property font  monoFont:  Qt.font({ family: "Consolas", pixelSize: 12 })
        readonly property font  labelFont: Qt.font({ family: "Segoe UI",  pixelSize: 12 })

        // Title bar
        Rectangle {
            id: ctrlTitleBar
            width: parent.width; height: 36
            color: ctrlWin.dimBg
            Text {
                anchors.centerIn: parent
                text: "Animation Properties"
                font.family: "Segoe UI"; font.bold: true; font.pixelSize: 13
                color: ctrlWin.textMain
            }
        }

        // Scrollable form
        ScrollView {
            id: sv
            anchors {
                top: ctrlTitleBar.bottom; left: parent.left
                right: parent.right; bottom: liveBox.top
                margins: 10; bottomMargin: 6
            }
            clip: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: sv.availableWidth
                spacing: 6

                component SectionHeader: Rectangle {
                    property alias text: sLbl.text
                    Layout.fillWidth: true; height: 24; radius: 4
                    color: ctrlWin.dimBg
                    Text {
                        id: sLbl
                        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                        font.family: "Consolas"; font.pixelSize: 12; font.bold: true
                        color: ctrlWin.accent
                    }
                }

                // ════════════════════════════════════════════════════
                //  1. Common Animation Settings  (applied to A B C D)
                // ════════════════════════════════════════════════════
                SectionHeader { text: "1 · Common Settings  (A B C D)" }

                RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    Text { text: "Duration (ms)"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textMain }
                    SpinBox {
                        id: durSpin
                        Layout.fillWidth: true; from: 50; to: 5000; value: 600
                        stepSize: 50; font: ctrlWin.monoFont
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    Text { text: "Easing Type"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textMain }
                    ComboBox {
                        id: easingCombo
                        Layout.fillWidth: true
                        font: ctrlWin.monoFont
                        textRole: "text"; valueRole: "value"
                        currentIndex: 3   // InOutQuad default
                        model: [
                            { text: "Linear",       value: Easing.Linear       },
                            { text: "InQuad",       value: Easing.InQuad       },
                            { text: "OutQuad",      value: Easing.OutQuad      },
                            { text: "InOutQuad",    value: Easing.InOutQuad    },
                            { text: "InCubic",      value: Easing.InCubic      },
                            { text: "OutCubic",     value: Easing.OutCubic     },
                            { text: "InOutCubic",   value: Easing.InOutCubic   },
                            { text: "InSine",       value: Easing.InSine       },
                            { text: "OutSine",      value: Easing.OutSine      },
                            { text: "InOutSine",    value: Easing.InOutSine    },
                            { text: "InExpo",       value: Easing.InExpo       },
                            { text: "OutExpo",      value: Easing.OutExpo      },
                            { text: "InOutExpo",    value: Easing.InOutExpo    },
                            { text: "InBack",       value: Easing.InBack       },
                            { text: "OutBack",      value: Easing.OutBack      },
                            { text: "InOutBack",    value: Easing.InOutBack    },
                            { text: "InBounce",     value: Easing.InBounce     },
                            { text: "OutBounce",    value: Easing.OutBounce    },
                            { text: "InOutBounce",  value: Easing.InOutBounce  },
                            { text: "InElastic",    value: Easing.InElastic    },
                            { text: "OutElastic",   value: Easing.OutElastic   },
                            { text: "InOutElastic", value: Easing.InOutElastic },
                        ]
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    Text { text: "Loops (0 = ∞)"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textMain }
                    SpinBox {
                        id: loopsSpin
                        Layout.fillWidth: true; from: 0; to: 10; value: 1
                        font: ctrlWin.monoFont
                    }
                }

                // ════════════════════════════════════════════════════
                //  2. Demo A — Behavior
                // ════════════════════════════════════════════════════
                SectionHeader { text: "2 · Demo A — Behavior" }

                RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    Button {
                        Layout.fillWidth: true; text: "Toggle X"
                        onClicked: behaviorBox.x = (behaviorBox.x < 40)
                                   ? (tileA.width - behaviorBox.width - 16) : 16
                    }
                    Button {
                        Layout.fillWidth: true; text: "Toggle Opacity"
                        onClicked: behaviorBox.opacity = (behaviorBox.opacity > 0.5) ? 0.1 : 1.0
                    }
                }
                Button {
                    Layout.fillWidth: true; text: "Spin +90°"
                    onClicked: behaviorBox.rotation += 90
                }

                // ════════════════════════════════════════════════════
                //  3. Demo B — Standalone NumberAnimation
                // ════════════════════════════════════════════════════
                SectionHeader { text: "3 · Demo B — Standalone Anim" }

                RowLayout {
                    Layout.fillWidth: true; spacing: 4
                    Button { Layout.fillWidth: true; text: "▶ Play";   onClicked: ballAnim.start() }
                    Button { Layout.fillWidth: true; text: "⏸ Pause";  onClicked: ballAnim.pause() }
                    Button { Layout.fillWidth: true; text: "⏹ Stop";   onClicked: ballAnim.stop()  }
                }
                Button {
                    Layout.fillWidth: true; text: "↺ Restart"
                    onClicked: { ballAnim.stop(); ball.x = 20; ballAnim.start() }
                }

                // ════════════════════════════════════════════════════
                //  4. Demo D — Python Backend
                // ════════════════════════════════════════════════════
                SectionHeader { text: "4 · Demo D — Python Backend" }

                Button {
                    Layout.fillWidth: true
                    text: "Randomize  (Python emits signal)"
                    onClicked: backend.randomize()
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    Text { text: "Set Value"; Layout.preferredWidth: 70; font: ctrlWin.labelFont; color: ctrlWin.textMain }
                    Slider {
                        id: backendSlider
                        Layout.fillWidth: true
                        from: 0; to: 1; stepSize: 0.01
                        onMoved: backend.setValue(value)
                    }
                }
                // Keep slider thumb in sync when Python randomizes
                Connections {
                    target: backend
                    function onValueChanged() { backendSlider.value = backend.value }
                }

                // ════════════════════════════════════════════════════
                //  5. Easing Showcase
                // ════════════════════════════════════════════════════
                SectionHeader { text: "5 · Easing Showcase" }

                RowLayout {
                    Layout.fillWidth: true; spacing: 6
                    Text { text: "Duration (ms)"; Layout.preferredWidth: 110; font: ctrlWin.labelFont; color: ctrlWin.textMain }
                    SpinBox {
                        id: showcaseDurSpin
                        Layout.fillWidth: true; from: 200; to: 6000; value: 1400
                        stepSize: 100; font: ctrlWin.monoFont
                    }
                }
                Button {
                    Layout.fillWidth: true
                    text: playWin.showcaseLaunched ? "◀  Reset Dots" : "▶  Launch All Easings"
                    onClicked: playWin.showcaseLaunched = !playWin.showcaseLaunched
                }

                // ── Reset ─────────────────────────────────────────────
                Button {
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    text: "Reset All to Defaults"
                    onClicked: {
                        durSpin.value         = 600
                        easingCombo.currentIndex = 3
                        loopsSpin.value       = 1
                        ballAnim.stop(); ball.x = 20
                        behaviorBox.x         = 16
                        behaviorBox.opacity   = 1.0
                        behaviorBox.rotation  = 0
                        showcaseDurSpin.value = 1400
                        playWin.showcaseLaunched = false
                    }
                }

                Item { Layout.preferredHeight: 4 }
            }
        } // end ScrollView

        // Live status readout
        Rectangle {
            id: liveBox
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 10 }
            height: liveText.implicitHeight + 14
            color: ctrlWin.dimBg; radius: 4

            Text {
                id: liveText
                anchors { fill: parent; margins: 7 }
                font.family: "Consolas"; font.pixelSize: 10
                color: ctrlWin.textMain; wrapMode: Text.WordWrap
                text: "box.x="       + Math.round(behaviorBox.x) +
                      "  opacity="   + behaviorBox.opacity.toFixed(2) +
                      "  rot="       + Math.round(behaviorBox.rotation) + "°\n" +
                      "ball.x="      + Math.round(ball.x) +
                      "  running="   + ballAnim.running +
                      "  progress="  + ballAnim.progress.toFixed(2) + "\n" +
                      "card.scale="  + stateCard.scale.toFixed(2) +
                      "  state="     + stateCard.state + "\n" +
                      "python="      + (backend.value * 100).toFixed(1) +
                      "%  bar.w="    + Math.round(progFill.width) + "px"
            }
        }

    } // end ctrlWin
} // end playWin
