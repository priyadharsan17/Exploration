import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

QQuickStyle.setStyle("Basic")

app    = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.load(Path(__file__).parent / "IDELayoutExplorer.qml")

if not engine.rootObjects():
    sys.exit(-1)

sys.exit(app.exec())
