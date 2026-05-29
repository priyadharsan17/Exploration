import random

from PySide6.QtCore import QObject, Signal, Slot

_COLORS = ["#89b4fa", "#cba6f7", "#a6e3a1", "#fab387", "#f9e2af", "#f38ba8"]


class DragDropBackend(QObject):
    """Minimal backend for the Kanban drag-drop explorer.

    Responsibilities:
    - Assign a random Catppuccin accent color to each new card
    - Emit boardReset so QML can restore the initial board state
    """

    boardReset = Signal()
    cardAdded  = Signal(str, int, str)   # title, colIndex (0/1/2), color

    @Slot()
    def resetBoard(self) -> None:
        self.boardReset.emit()

    @Slot(str, int)
    def addCard(self, title: str, col_index: int) -> None:
        title = title.strip()
        if not title:
            return
        color = random.choice(_COLORS)
        self.cardAdded.emit(title, col_index, color)
