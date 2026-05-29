import math
import random

from PySide6.QtCore import QObject, QTimer, Signal, Slot


class ChartsBackend(QObject):
    """
    Drives the live-data line chart.

    Pattern demonstrated:
        Python QTimer fires → emits newLinePoint(x, y)
        QML Connections receives the signal → calls LineSeries.append(x, y)
    """

    # Emitted on every timer tick with the next (x, y) coordinate
    newLinePoint = Signal(float, float)

    # Emitted when the series should be cleared
    resetLineSeries = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._x: float = 0.0
        self._timer = QTimer(self)
        self._timer.setInterval(500)
        self._timer.timeout.connect(self._tick)

    # ── Private ──────────────────────────────────────────────────────────────

    def _tick(self) -> None:
        """Emit a sine wave + small random noise as the next live point."""
        y = math.sin(self._x * 0.4) * 35.0 + random.uniform(-8.0, 8.0) + 50.0
        self.newLinePoint.emit(round(self._x, 1), round(y, 2))
        self._x += 0.5

    # ── Slots (callable from QML) ─────────────────────────────────────────────

    @Slot()
    def startLive(self) -> None:
        self._timer.start()

    @Slot()
    def stopLive(self) -> None:
        self._timer.stop()

    @Slot()
    def resetLine(self) -> None:
        """Clear the x counter and tell QML to clear the series."""
        self._x = 0.0
        self.resetLineSeries.emit()

    @Slot(int)
    def setInterval(self, ms: int) -> None:
        self._timer.setInterval(ms)
