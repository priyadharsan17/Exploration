import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

from drag_drop_backend import DragDropBackend


def main() -> None:
    QQuickStyle.setStyle("Basic")
    app = QGuiApplication(sys.argv)

    backend = DragDropBackend()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("backend", backend)

    qml_file = Path(__file__).parent / "DragDropExplorer.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
