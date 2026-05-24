import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


def main():
    app = QGuiApplication(sys.argv)
    app.setApplicationName("ColumnLayout Explorer")
    app.setOrganizationName("Exploration")

    engine = QQmlApplicationEngine()

    qml_file = Path(__file__).parent / "ColumnExplorer.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        print("ERROR: Failed to load QML file.")
        sys.exit(1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
