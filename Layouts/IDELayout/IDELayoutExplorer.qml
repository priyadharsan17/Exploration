import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ─────────────────────────────────────────────────────────────────────────────
//  IDE Layout Explorer
//  Demonstrates: SplitView (horizontal + vertical), tab bars, activity bar,
//  toolbar, status bar, console input, resizable panels — all mouse-draggable.
// ─────────────────────────────────────────────────────────────────────────────
ApplicationWindow {
    id: root
    visible: true
    width:  1280
    height: 800
    minimumWidth:  920
    minimumHeight: 580
    title: "IDE Layout Explorer  ·  PySide6 + QML"

    // ── Catppuccin Mocha ─────────────────────────────────────────────────────
    readonly property color bgBase:    "#1e1e2e"
    readonly property color bgMantle:  "#181825"
    readonly property color bgCrust:   "#11111b"
    readonly property color bgSurface: "#313244"
    readonly property color bgOverlay: "#45475a"
    readonly property color textMain:  "#cdd6f4"
    readonly property color textSub:   "#a6adc8"
    readonly property color textMuted: "#6c7086"
    readonly property color clrAccent: "#cba6f7"
    readonly property color clrGreen:  "#a6e3a1"
    readonly property color clrRed:    "#f38ba8"
    readonly property color clrBlue:   "#89b4fa"
    readonly property color clrOrange: "#fab387"
    readonly property color clrYellow: "#f9e2af"
    readonly property color clrTeal:   "#89dceb"

    // ── State ────────────────────────────────────────────────────────────────
    property int  activeActivity:   0     // 0 Explorer | 1 Search | 2 Table | 3 Timeline
    property bool sidePanelOpen:    true
    property int  activeEditorTab:  0
    property int  activeBottomTab:  0

    color: root.bgBase

    // ── Helpers ──────────────────────────────────────────────────────────────
    function fileColor(name) {
        if (name.endsWith(".py"))  return root.clrGreen
        if (name.endsWith(".qml")) return root.clrBlue
        if (name.endsWith(".md"))  return root.clrYellow
        return root.textSub
    }
    function fileExt(name) {
        let p = name.lastIndexOf(".")
        return p >= 0 ? name.slice(p + 1).toUpperCase() : "  "
    }
    function editorLang() {
        return (["QML", "Python", "Python"])[root.activeEditorTab]
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  ROOT COLUMN LAYOUT
    // ─────────────────────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ══════════════════════════════════════════════════════════════════════
        //  TOP TOOLBAR
        // ══════════════════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            height: 38
            color: root.bgCrust

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                spacing: 0

                // Menu items
                Repeater {
                    model: ["File", "Edit", "View", "Run", "Terminal", "Help"]
                    delegate: Rectangle {
                        height: 38
                        width:  menuLbl.implicitWidth + 16
                        color:  mhover.containsMouse ? root.bgSurface : "transparent"
                        radius: 3
                        Text {
                            id: menuLbl
                            anchors.centerIn: parent
                            text:  modelData
                            color: root.textSub
                            font.pixelSize: 13
                        }
                        HoverHandler { id: mhover }
                    }
                }

                Item { Layout.fillWidth: true }

                // Search bar
                Rectangle {
                    width: 220; height: 24; radius: 4
                    color: root.bgSurface
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 4
                        Text { text: "⌕";             color: root.textMuted; font.pixelSize: 14 }
                        Text { text: "Search (Ctrl+P)"; color: root.textMuted; font.pixelSize: 12 }
                    }
                }

                Item { width: 8 }

                // Run / Debug buttons
                Repeater {
                    model: [
                        { label: "▶  Run",   clr: root.clrGreen },
                        { label: "⬡  Debug", clr: root.clrBlue  },
                    ]
                    delegate: Rectangle {
                        height: 24; width: rl.implicitWidth + 16; radius: 4
                        color: rhover.containsMouse ? root.bgSurface : "transparent"
                        Text { id: rl; anchors.centerIn: parent; text: modelData.label; color: modelData.clr; font.pixelSize: 12 }
                        HoverHandler { id: rhover }
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  MIDDLE AREA  (activity bar + resizable panels)
        // ══════════════════════════════════════════════════════════════════════
        Item {
            Layout.fillWidth:  true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ── ACTIVITY BAR ──────────────────────────────────────────────
                Rectangle {
                    width: 48
                    Layout.fillHeight: true
                    color: root.bgCrust

                    ColumnLayout {
                        anchors.top:   parent.top
                        anchors.left:  parent.left
                        anchors.right: parent.right
                        anchors.topMargin: 4
                        spacing: 2

                        Repeater {
                            model: [
                                { icon: "≡",  label: "Explorer"  },
                                { icon: "⌕",  label: "Search"    },
                                { icon: "▦",  label: "Table"     },
                                { icon: "〰", label: "Timeline"  },
                            ]
                            delegate: Item {
                                Layout.fillWidth: true
                                height: 46

                                // Active indicator bar (left edge)
                                Rectangle {
                                    visible: root.activeActivity === index
                                    width: 2; height: parent.height
                                    anchors.left: parent.left
                                    color: root.clrAccent
                                }
                                // Background highlight
                                Rectangle {
                                    anchors.fill: parent
                                    color: root.activeActivity === index
                                           ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
                                }
                                // Icon
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    font.pixelSize: 22
                                    color: root.activeActivity === index
                                           ? root.textMain : root.textMuted
                                }
                                HoverHandler { id: ahover }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (root.activeActivity === index)
                                            root.sidePanelOpen = !root.sidePanelOpen
                                        else {
                                            root.activeActivity = index
                                            root.sidePanelOpen  = true
                                        }
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Settings (bottom)
                        Rectangle {
                            Layout.fillWidth: true; height: 46
                            color: "transparent"
                            Text { anchors.centerIn: parent; text: "⚙"; font.pixelSize: 22; color: root.textMuted }
                        }
                    }
                }

                // ── HORIZONTAL SPLIT (side panel | editor+console) ────────────
                SplitView {
                    id: mainSplit
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    orientation: Qt.Horizontal

                    handle: Rectangle {
                        implicitWidth: 4
                        color: SplitHandle.hovered || SplitHandle.pressed
                               ? root.clrAccent : root.bgSurface
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    // ── SIDE PANEL ────────────────────────────────────────────
                    Rectangle {
                        id: sidePanel
                        visible: root.sidePanelOpen
                        SplitView.preferredWidth: 260
                        SplitView.minimumWidth:   160
                        SplitView.maximumWidth:   520
                        color: root.bgMantle

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0

                            // Panel heading
                            Rectangle {
                                Layout.fillWidth: true; height: 30
                                color: "transparent"
                                Text {
                                    anchors.left: parent.left; anchors.leftMargin: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: (["EXPLORER","SEARCH","TABLE","TIMELINE"])[root.activeActivity]
                                    font.pixelSize: 11; font.weight: Font.DemiBold
                                    font.letterSpacing: 0.8
                                    color: root.textMuted
                                }
                            }

                            // ── Panel content (one per activity) ─────────────
                            StackLayout {
                                Layout.fillWidth:  true
                                Layout.fillHeight: true
                                currentIndex: root.activeActivity

                                // ── [0] EXPLORER — file tree ─────────────────
                                ListView {
                                    clip: true
                                    model: ListModel {
                                        ListElement { nm:"IDELayoutExplorer"; depth:0; isDir:true  }
                                        ListElement { nm:"src";               depth:1; isDir:true  }
                                        ListElement { nm:"main.py";           depth:2; isDir:false }
                                        ListElement { nm:"backend.py";        depth:2; isDir:false }
                                        ListElement { nm:"qml";               depth:1; isDir:true  }
                                        ListElement { nm:"IDELayout.qml";     depth:2; isDir:false }
                                        ListElement { nm:"Components.qml";    depth:2; isDir:false }
                                        ListElement { nm:"assets";            depth:1; isDir:true  }
                                        ListElement { nm:"README.md";         depth:1; isDir:false }
                                        ListElement { nm:"requirements.txt";  depth:1; isDir:false }
                                    }
                                    delegate: Rectangle {
                                        width: ListView.view.width; height: 24
                                        color: ehover.containsMouse ? root.bgSurface : "transparent"
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 6 + model.depth * 14
                                            spacing: 4
                                            Text {
                                                text:  model.isDir ? "▸" : " "
                                                color: root.clrOrange; font.pixelSize: 10
                                            }
                                            Text {
                                                text:  model.nm
                                                color: model.isDir ? root.clrOrange : root.fileColor(model.nm)
                                                font.pixelSize: 13
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                        }
                                        HoverHandler { id: ehover }
                                    }
                                }

                                // ── [1] SEARCH — results list ─────────────────
                                ColumnLayout {
                                    clip: true; spacing: 6

                                    Rectangle {
                                        Layout.fillWidth: true; height: 28
                                        Layout.leftMargin: 8; Layout.rightMargin: 8; Layout.topMargin: 4
                                        color: root.bgSurface; radius: 4
                                        Text {
                                            anchors.fill: parent; anchors.leftMargin: 8
                                            verticalAlignment: Text.AlignVCenter
                                            text: "Find in files..."; color: root.textMuted; font.pixelSize: 13
                                        }
                                    }

                                    Repeater {
                                        model: [
                                            { f:"main.py",       ln:4,  txt:"from PySide6.QtGui" },
                                            { f:"main.py",       ln:7,  txt:"QQuickStyle.setStyle" },
                                            { f:"backend.py",    ln:1,  txt:"from PySide6.QtCore" },
                                            { f:"IDELayout.qml", ln:12, txt:"SplitView {" },
                                            { f:"IDELayout.qml", ln:86, txt:"SplitView.preferredWidth" },
                                        ]
                                        delegate: Rectangle {
                                            Layout.fillWidth: true; height: 44
                                            Layout.leftMargin: 4; Layout.rightMargin: 4
                                            color: srhover.containsMouse ? root.bgSurface : "transparent"; radius: 3
                                            ColumnLayout {
                                                anchors.fill: parent; anchors.margins: 6; spacing: 2
                                                Text { text: modelData.f + "  :" + modelData.ln; color: root.clrAccent; font.pixelSize: 11 }
                                                Text { text: modelData.txt; color: root.textSub; font.family: "Consolas"; font.pixelSize: 12 }
                                            }
                                            HoverHandler { id: srhover }
                                        }
                                    }
                                    Item { Layout.fillHeight: true }
                                }

                                // ── [2] TABLE — data grid ─────────────────────
                                ColumnLayout {
                                    clip: true; spacing: 0

                                    // Header row
                                    Rectangle {
                                        Layout.fillWidth: true; height: 26
                                        color: root.bgSurface
                                        Row {
                                            anchors.fill: parent
                                            Repeater {
                                                model: ["Name", "Type", "Size", "Modified"]
                                                delegate: Rectangle {
                                                    width: sidePanel.width / 4; height: 26; color: "transparent"
                                                    Text { anchors.centerIn: parent; text: modelData; color: root.textSub; font.pixelSize: 11; font.weight: Font.DemiBold }
                                                    Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: root.bgOverlay }
                                                }
                                            }
                                        }
                                    }
                                    // Data rows
                                    ListView {
                                        Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                                        model: ListModel {
                                            ListElement { nm:"main.py";           tp:"Python";   sz:"1.2 KB"; md:"Today"      }
                                            ListElement { nm:"backend.py";        tp:"Python";   sz:"4.7 KB"; md:"Today"      }
                                            ListElement { nm:"IDELayout.qml";     tp:"QML";      sz:"8.3 KB"; md:"Today"      }
                                            ListElement { nm:"README.md";         tp:"Markdown"; sz:"0.8 KB"; md:"Yesterday"  }
                                            ListElement { nm:"requirements.txt";  tp:"Text";     sz:"0.1 KB"; md:"3 days ago" }
                                        }
                                        delegate: Rectangle {
                                            width: ListView.view.width; height: 26
                                            color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.025)
                                            Row {
                                                anchors.fill: parent
                                                Repeater {
                                                    model: [nm, tp, sz, md]
                                                    delegate: Rectangle {
                                                        width: sidePanel.width / 4; height: 26; color: "transparent"
                                                        Text { anchors.centerIn: parent; text: modelData; color: root.textSub; font.pixelSize: 12; elide: Text.ElideRight }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // ── [3] TIMELINE — event log ──────────────────
                                ListView {
                                    clip: true
                                    model: ListModel {
                                        ListElement { msg:"Session started";    time:"09:00"; clr:"#a6e3a1" }
                                        ListElement { msg:"main.py modified";   time:"09:14"; clr:"#89b4fa" }
                                        ListElement { msg:"Backend created";    time:"09:32"; clr:"#89b4fa" }
                                        ListElement { msg:"Runtime error";      time:"09:47"; clr:"#f38ba8" }
                                        ListElement { msg:"Bug fixed";          time:"10:01"; clr:"#a6e3a1" }
                                        ListElement { msg:"QML layout updated"; time:"10:15"; clr:"#89b4fa" }
                                        ListElement { msg:"Tests passed";       time:"10:28"; clr:"#a6e3a1" }
                                        ListElement { msg:"Commit pushed";      time:"10:45"; clr:"#cba6f7" }
                                    }
                                    delegate: RowLayout {
                                        width: ListView.view.width; height: 42; spacing: 0
                                        // Dot + vertical line
                                        Item {
                                            width: 40; Layout.fillHeight: true
                                            Rectangle {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                width: 2; height: parent.height; y: 0
                                                color: root.bgSurface
                                                visible: index < 7
                                            }
                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: 10; height: 10; radius: 5
                                                color: model.clr
                                            }
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true; spacing: 2
                                            Text { text: model.msg;  color: root.textMain;  font.pixelSize: 12 }
                                            Text { text: model.time; color: root.textMuted; font.pixelSize: 10 }
                                        }
                                    }
                                }
                            } // StackLayout side panel
                        }
                    } // side panel Rectangle

                    // ── VERTICAL SPLIT (editor | bottom panel) ────────────────
                    SplitView {
                        id: rightSplit
                        SplitView.fillWidth: true
                        orientation: Qt.Vertical

                        handle: Rectangle {
                            implicitHeight: 4
                            color: SplitHandle.hovered || SplitHandle.pressed
                                   ? root.clrAccent : root.bgSurface
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        // ── EDITOR AREA ───────────────────────────────────────
                        Item {
                            SplitView.fillHeight:   true
                            SplitView.minimumHeight: 120

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0

                                // File tab bar
                                Rectangle {
                                    Layout.fillWidth: true; height: 36
                                    color: root.bgCrust

                                    Row {
                                        height: parent.height
                                        Repeater {
                                            model: [
                                                { name: "IDELayout.qml", modified: false },
                                                { name: "main.py",       modified: true  },
                                                { name: "backend.py",    modified: false },
                                            ]
                                            delegate: Rectangle {
                                                width:  tabLbl.implicitWidth + 36
                                                height: 36
                                                color: root.activeEditorTab === index
                                                       ? root.bgBase : "transparent"

                                                // Top accent bar for active tab
                                                Rectangle {
                                                    visible: root.activeEditorTab === index
                                                    anchors.top: parent.top
                                                    width: parent.width; height: 2
                                                    color: root.clrAccent
                                                }
                                                RowLayout {
                                                    anchors.centerIn: parent; spacing: 5
                                                    Text {
                                                        text:  root.fileExt(modelData.name)
                                                        color: root.fileColor(modelData.name)
                                                        font.pixelSize: 10; font.weight: Font.Bold
                                                    }
                                                    Text {
                                                        id: tabLbl
                                                        text:  modelData.name
                                                        color: root.activeEditorTab === index
                                                               ? root.textMain : root.textMuted
                                                        font.pixelSize: 13
                                                    }
                                                    // Unsaved dot
                                                    Rectangle {
                                                        visible: modelData.modified
                                                        width: 6; height: 6; radius: 3
                                                        color: root.clrOrange
                                                    }
                                                }
                                                MouseArea { anchors.fill: parent; onClicked: root.activeEditorTab = index }
                                            }
                                        }
                                    }
                                }

                                // Code content
                                StackLayout {
                                    Layout.fillWidth:  true
                                    Layout.fillHeight: true
                                    currentIndex: root.activeEditorTab

                                    // IDELayout.qml
                                    ScrollView {
                                        clip: true
                                        background: Rectangle { color: root.bgBase }
                                        TextArea {
                                            readOnly: true
                                            font.family: "Consolas"; font.pixelSize: 14
                                            color: root.textMain; wrapMode: TextArea.NoWrap
                                            background: Rectangle { color: root.bgBase }
                                            leftPadding: 12; topPadding: 8
                                            text: [
                                                "import QtQuick",
                                                "import QtQuick.Controls",
                                                "import QtQuick.Layouts",
                                                "",
                                                "ApplicationWindow {",
                                                "    id: root",
                                                "    visible: true",
                                                "    width: 1280; height: 800",
                                                "    title: \"IDE Layout Explorer\"",
                                                "",
                                                "    // Horizontal split: side panel | editor+console",
                                                "    SplitView {",
                                                "        id: mainSplit",
                                                "        orientation: Qt.Horizontal",
                                                "        anchors.fill: parent",
                                                "",
                                                "        handle: Rectangle {",
                                                "            implicitWidth: 4",
                                                "            color: SplitHandle.hovered ? \"#cba6f7\" : \"#313244\"",
                                                "            Behavior on color { ColorAnimation { duration: 120 } }",
                                                "        }",
                                                "",
                                                "        // Side panel — drag the handle to resize",
                                                "        Rectangle {",
                                                "            SplitView.preferredWidth: 260",
                                                "            SplitView.minimumWidth:   160",
                                                "            SplitView.maximumWidth:   520",
                                                "        }",
                                                "",
                                                "        // Vertical split: editor (top) | console (bottom)",
                                                "        SplitView {",
                                                "            SplitView.fillWidth: true",
                                                "            orientation: Qt.Vertical",
                                                "",
                                                "            Item { SplitView.fillHeight: true }",
                                                "            Item {",
                                                "                SplitView.preferredHeight: 200",
                                                "                SplitView.minimumHeight:   80",
                                                "            }",
                                                "        }",
                                                "    }",
                                                "}",
                                            ].join("\n")
                                        }
                                    }

                                    // main.py
                                    ScrollView {
                                        clip: true
                                        background: Rectangle { color: root.bgBase }
                                        TextArea {
                                            readOnly: true
                                            font.family: "Consolas"; font.pixelSize: 14
                                            color: root.textMain; wrapMode: TextArea.NoWrap
                                            background: Rectangle { color: root.bgBase }
                                            leftPadding: 12; topPadding: 8
                                            text: [
                                                "import sys",
                                                "from pathlib import Path",
                                                "from PySide6.QtGui            import QGuiApplication",
                                                "from PySide6.QtQml             import QQmlApplicationEngine",
                                                "from PySide6.QtQuickControls2  import QQuickStyle",
                                                "",
                                                "QQuickStyle.setStyle(\"Basic\")",
                                                "",
                                                "app    = QGuiApplication(sys.argv)",
                                                "engine = QQmlApplicationEngine()",
                                                "engine.load(Path(__file__).parent / \"IDELayoutExplorer.qml\")",
                                                "",
                                                "if not engine.rootObjects():",
                                                "    sys.exit(-1)",
                                                "",
                                                "sys.exit(app.exec())",
                                            ].join("\n")
                                        }
                                    }

                                    // backend.py
                                    ScrollView {
                                        clip: true
                                        background: Rectangle { color: root.bgBase }
                                        TextArea {
                                            readOnly: true
                                            font.family: "Consolas"; font.pixelSize: 14
                                            color: root.textMain; wrapMode: TextArea.NoWrap
                                            background: Rectangle { color: root.bgBase }
                                            leftPadding: 12; topPadding: 8
                                            text: [
                                                "from PySide6.QtCore import (",
                                                "    QAbstractTableModel, QModelIndex,",
                                                "    Qt, Signal, Slot, Property,",
                                                ")",
                                                "",
                                                "class TableModel(QAbstractTableModel):",
                                                "    structureChanged = Signal()",
                                                "",
                                                "    def __init__(self, rows=5, cols=4, parent=None):",
                                                "        super().__init__(parent)",
                                                "        self._headers = [self._col_name(c) for c in range(cols)]",
                                                "        self._data    = [[\"\"] * cols for _ in range(rows)]",
                                                "",
                                                "    @Slot()",
                                                "    def addRow(self):",
                                                "        pos = self.rowCount()",
                                                "        self.beginInsertRows(QModelIndex(), pos, pos)",
                                                "        self._data.append([\"\"] * self.columnCount())",
                                                "        self.endInsertRows()",
                                                "        self.structureChanged.emit()",
                                                "",
                                                "    @Slot(int)",
                                                "    def deleteRow(self, row: int):",
                                                "        if 0 <= row < self.rowCount():",
                                                "            self.beginRemoveRows(QModelIndex(), row, row)",
                                                "            del self._data[row]",
                                                "            self.endRemoveRows()",
                                                "            self.structureChanged.emit()",
                                            ].join("\n")
                                        }
                                    }
                                } // code StackLayout
                            }
                        } // editor Item

                        // ── BOTTOM PANEL (Console / Output / Problems / Terminal)
                        Item {
                            SplitView.preferredHeight: 200
                            SplitView.minimumHeight:   80

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0

                                // Tab bar
                                Rectangle {
                                    Layout.fillWidth: true; height: 30
                                    color: root.bgCrust

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 4
                                        spacing: 0

                                        Repeater {
                                            model: ["Console", "Output", "Problems", "Terminal"]
                                            delegate: Rectangle {
                                                height: 30; width: btLbl.implicitWidth + 20; color: "transparent"
                                                Rectangle {
                                                    visible: root.activeBottomTab === index
                                                    anchors.top: parent.top
                                                    width: parent.width; height: 2
                                                    color: root.clrAccent
                                                }
                                                Text {
                                                    id: btLbl
                                                    anchors.centerIn: parent
                                                    text:  modelData
                                                    color: root.activeBottomTab === index ? root.textMain : root.textMuted
                                                    font.pixelSize: 12
                                                }
                                                MouseArea { anchors.fill: parent; onClicked: root.activeBottomTab = index }
                                            }
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: "✕"; color: root.textMuted; font.pixelSize: 13
                                            rightPadding: 10; verticalAlignment: Text.AlignVCenter; height: 30
                                        }
                                    }
                                }

                                // Panel content
                                StackLayout {
                                    Layout.fillWidth:  true
                                    Layout.fillHeight: true
                                    currentIndex: root.activeBottomTab

                                    // ── Console ───────────────────────────────
                                    ColumnLayout {
                                        spacing: 0; clip: true

                                        ScrollView {
                                            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                                            background: Rectangle { color: root.bgBase }
                                            ListView {
                                                id: consoleLog
                                                model: consoleModel
                                                delegate: Text {
                                                    width: consoleLog.width
                                                    leftPadding: 12; topPadding: 1
                                                    text:  model.txt
                                                    color: model.clr
                                                    font.family: "Consolas"; font.pixelSize: 13
                                                    wrapMode: Text.NoWrap
                                                }
                                            }
                                        }

                                        // Input line
                                        Rectangle {
                                            Layout.fillWidth: true; height: 28
                                            color: root.bgSurface
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 10; anchors.rightMargin: 8
                                                spacing: 6
                                                Text { text: "›"; color: root.clrAccent; font.family: "Consolas"; font.pixelSize: 18 }
                                                TextInput {
                                                    id: consoleInput
                                                    Layout.fillWidth: true
                                                    color: root.textMain
                                                    font.family: "Consolas"; font.pixelSize: 13
                                                    clip: true
                                                    onAccepted: {
                                                        if (text.length > 0) {
                                                            consoleModel.append({ txt: ">>> " + text, clr: root.clrAccent })
                                                            consoleModel.append({ txt: "    Done.",    clr: root.textSub  })
                                                            text = ""
                                                            Qt.callLater(function() { consoleLog.positionViewAtEnd() })
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // ── Output ────────────────────────────────
                                    ScrollView {
                                        clip: true
                                        background: Rectangle { color: root.bgBase }
                                        Text {
                                            leftPadding: 12; topPadding: 8
                                            font.family: "Consolas"; font.pixelSize: 13
                                            color: root.textSub
                                            text: "[Build]   Starting build...\n[Build]   Compiling QML sources...\n[Build]   Linking...\n[Build]   Done.  0 errors  0 warnings\n[Deploy]  Package ready."
                                        }
                                    }

                                    // ── Problems ──────────────────────────────
                                    ListView {
                                        clip: true
                                        model: ListModel {
                                            ListElement { sev:"⚠"; msg:"Unused import 'sys'";          file:"main.py:1"      }
                                            ListElement { sev:"ℹ"; msg:"Consider adding type hints";   file:"backend.py:34"  }
                                            ListElement { sev:"✓"; msg:"No issues in IDELayout.qml";   file:""               }
                                        }
                                        delegate: Rectangle {
                                            width: ListView.view.width; height: 30; color: "transparent"
                                            RowLayout {
                                                anchors.fill: parent; anchors.leftMargin: 12; spacing: 10
                                                Text {
                                                    text: model.sev; font.pixelSize: 13
                                                    color: model.sev === "⚠" ? root.clrYellow
                                                         : model.sev === "✓" ? root.clrGreen
                                                         : root.clrBlue
                                                }
                                                Text { text: model.msg;  color: root.textSub;   font.pixelSize: 13; Layout.fillWidth: true }
                                                Text { text: model.file; color: root.textMuted; font.pixelSize: 11 }
                                            }
                                        }
                                    }

                                    // ── Terminal ──────────────────────────────
                                    ScrollView {
                                        clip: true
                                        background: Rectangle { color: root.bgCrust }
                                        Text {
                                            leftPadding: 12; topPadding: 8
                                            font.family: "Consolas"; font.pixelSize: 13
                                            color: root.clrGreen
                                            text: "PS D:\\Projects\\Exploration> python main.py\n(.venv) [Python 3.12.6]\nLoading IDELayoutExplorer.qml...\nWindow opened (1280\u00d7800)\nPS D:\\Projects\\Exploration> _"
                                        }
                                    }
                                } // bottom StackLayout
                            }
                        } // bottom Item
                    } // rightSplit SplitView
                } // mainSplit SplitView
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        //  STATUS BAR
        // ══════════════════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true; height: 24
            color: root.clrAccent

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10; anchors.rightMargin: 10
                spacing: 0
                Text { text: "⎇  main";      color: root.bgCrust; font.pixelSize: 12 }
                Text { text: "    ✕ 0  ⚠ 1"; color: root.bgCrust; font.pixelSize: 12 }
                Item { Layout.fillWidth: true }
                Text { text: root.editorLang();              color: root.bgCrust; font.pixelSize: 12 }
                Text { text: "    UTF-8    Spaces: 4    Ln 1, Col 1"; color: root.bgCrust; font.pixelSize: 12 }
            }
        }
    } // root ColumnLayout

    // ── Console log seed data ─────────────────────────────────────────────────
    ListModel {
        id: consoleModel
        ListElement { txt:"IDE Layout Explorer v1.0"; clr:"#a6e3a1" }
        ListElement { txt:"PySide6 6.7  ·  Qt 6.7";  clr:"#6c7086" }
        ListElement { txt:"QML engine ready.";         clr:"#6c7086" }
        ListElement { txt:">>> Loading IDELayoutExplorer.qml"; clr:"#cba6f7" }
        ListElement { txt:"    Window opened (1280\u00d7800)"; clr:"#a6adc8" }
    }
}
