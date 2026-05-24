import sys
import random
from pathlib import Path

from PySide6.QtCore import QObject, Signal, Slot, Property
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


class AnimBackend(QObject):
    """Exposes a single float value (0.0–1.0) to QML.
    QML binds a Behavior on the progress bar width to this value,
    demonstrating how a Python signal drives a smooth QML animation.
    """
    valueChanged = Signal(float)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._value = 0.3

    @Property(float, notify=valueChanged)
    def value(self):
        return self._value

    @value.setter
    def value(self, v: float):
        v = round(max(0.0, min(1.0, float(v))), 4)
        if abs(self._value - v) > 1e-6:
            self._value = v
            self.valueChanged.emit(v)

    @Slot(float)
    def setValue(self, v: float):
        self.value = v

    @Slot()
    def randomize(self):
        self.value = random.random()


def main():
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Number Animation Explorer")
    app.setOrganizationName("Exploration")

    backend = AnimBackend()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("backend", backend)

    qml_file = Path(__file__).parent / "NumberAnimExplorer.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        print("ERROR: Failed to load QML file.")
        sys.exit(1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
