"""
table_backend.py
────────────────────────────────────────────────────────────────────────
A QAbstractTableModel subclass that manages a 2-D in-memory table and
exposes all CRUD operations as QML-callable @Slot methods.

Instantiation
─────────────
    model = TableModel(rows=5, cols=4)
    engine.rootContext().setContextProperty("tableModel", model)

QML-bindable Properties
────────────────────────
    tableModel.rows   → int   current row count  (updates on change)
    tableModel.cols   → int   current col count  (updates on change)

Slots callable from QML
────────────────────────
    Row / Column CRUD
        addRow()                 append a blank row at the bottom
        addColumn()              append a blank column on the right
        removeRow(row)           delete row at index
        removeColumn(col)        delete column at index

    Cell CRUD
        setCell(row, col, val)   write one cell
        getCell(row, col) → str  read one cell

    Header
        setColumnHeader(col, name)  rename a column header

    Cell reference  (spreadsheet-style — "A1", "B3", ...)
        cellRef(row, col) → str        row 0 col 1  →  "B1"
        parseCellRef(ref) → [row, col] "B3"  →  [2, 1]
                                       invalid ref  →  [-1, -1]

    Data extraction
        getRow(row)    → list[str]   all values in a row
        getColumn(col) → list[str]   all values in a column
        exportCsv()    → str         full table as CSV text

    Bulk
        clearAll()               blank every cell, keep structure
        resetTable(rows, cols)   replace with a fresh empty grid
"""

from PySide6.QtCore import (
    QAbstractTableModel, QModelIndex, Qt,
    Signal, Slot, Property,
)


class TableModel(QAbstractTableModel):

    # Emitted after any structural change (rows/cols added/removed/reset).
    # QML binds tableModel.rows / tableModel.cols via this signal.
    structureChanged = Signal()

    # ── Construction ──────────────────────────────────────────────────

    def __init__(self, rows: int = 5, cols: int = 4, parent=None):
        super().__init__(parent)
        self._headers: list[str] = [self._default_header(c) for c in range(cols)]
        self._data:    list[list[str]] = [[""] * cols for _ in range(rows)]

    # ── QML-bindable properties ───────────────────────────────────────

    @Property(int, notify=structureChanged)
    def rows(self) -> int:
        return len(self._data)

    @Property(int, notify=structureChanged)
    def cols(self) -> int:
        return len(self._headers)

    # ── QAbstractTableModel required overrides ────────────────────────

    def rowCount(self, parent=QModelIndex()) -> int:
        return 0 if parent.isValid() else len(self._data)

    def columnCount(self, parent=QModelIndex()) -> int:
        return 0 if parent.isValid() else len(self._headers)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None
        if role in (Qt.DisplayRole, Qt.EditRole):
            return self._data[index.row()][index.column()]
        return None

    def setData(self, index, value, role=Qt.EditRole) -> bool:
        if not index.isValid() or role != Qt.EditRole:
            return False
        self._data[index.row()][index.column()] = str(value)
        self.dataChanged.emit(index, index, [Qt.EditRole, Qt.DisplayRole])
        return True

    def headerData(self, section: int, orientation, role=Qt.DisplayRole):
        if role != Qt.DisplayRole:
            return None
        if orientation == Qt.Horizontal:
            return self._headers[section] if section < len(self._headers) else ""
        return str(section + 1)          # 1-based row numbers

    def flags(self, index):
        if not index.isValid():
            return Qt.NoItemFlags
        return Qt.ItemIsEnabled | Qt.ItemIsSelectable | Qt.ItemIsEditable

    # ── Row CRUD ──────────────────────────────────────────────────────

    @Slot()
    def addRow(self):
        """Append a blank row at the bottom."""
        pos = self.rowCount()
        self.beginInsertRows(QModelIndex(), pos, pos)
        self._data.append([""] * self.columnCount())
        self.endInsertRows()
        self.structureChanged.emit()

    @Slot(int)
    def removeRow(self, row: int):
        """Delete the row at index *row*."""
        if 0 <= row < self.rowCount():
            self.beginRemoveRows(QModelIndex(), row, row)
            del self._data[row]
            self.endRemoveRows()
            self.structureChanged.emit()

    # ── Column CRUD ───────────────────────────────────────────────────

    @Slot()
    def addColumn(self):
        """Append a blank column on the right."""
        pos = self.columnCount()
        self.beginInsertColumns(QModelIndex(), pos, pos)
        self._headers.append(self._default_header(pos))
        for row in self._data:
            row.append("")
        self.endInsertColumns()
        self.structureChanged.emit()

    @Slot(int)
    def removeColumn(self, col: int):
        """Delete the column at index *col*."""
        if 0 <= col < self.columnCount():
            self.beginRemoveColumns(QModelIndex(), col, col)
            del self._headers[col]
            for row in self._data:
                del row[col]
            self.endRemoveColumns()
            self.structureChanged.emit()

    # ── Cell CRUD ─────────────────────────────────────────────────────

    @Slot(int, int, str)
    def setCell(self, row: int, col: int, value: str):
        """Write *value* into cell (row, col)."""
        idx = self.index(row, col)
        self.setData(idx, value, Qt.EditRole)

    @Slot(int, int, result=str)
    def getCell(self, row: int, col: int) -> str:
        """Read the value of cell (row, col). Returns '' if out of range."""
        if 0 <= row < self.rowCount() and 0 <= col < self.columnCount():
            return self._data[row][col]
        return ""

    # ── Header rename ─────────────────────────────────────────────────

    @Slot(int, str)
    def setColumnHeader(self, col: int, name: str):
        """Rename the column header at index *col*."""
        if 0 <= col < self.columnCount():
            self._headers[col] = name
            self.headerDataChanged.emit(Qt.Horizontal, col, col)

    # ── Cell reference helpers ─────────────────────────────────────────

    @Slot(int, int, result=str)
    def cellRef(self, row: int, col: int) -> str:
        """Return a spreadsheet-style reference, e.g. row=2 col=1 → 'B3'."""
        col_label = chr(65 + col) if col < 26 else f"C{col}"
        return f"{col_label}{row + 1}"

    @Slot(str, result="QVariantList")
    def parseCellRef(self, ref: str) -> list:
        """
        Parse a spreadsheet-style reference back to [row, col].
        'B3' → [2, 1].  Returns [-1, -1] if the ref is invalid or
        out of range for the current table size.
        """
        ref = ref.strip().upper()
        if not ref or not ref[0].isalpha():
            return [-1, -1]
        col = ord(ref[0]) - 65
        try:
            row = int(ref[1:]) - 1
        except ValueError:
            return [-1, -1]
        if 0 <= row < self.rowCount() and 0 <= col < self.columnCount():
            return [row, col]
        return [-1, -1]

    # ── Data extraction ───────────────────────────────────────────────

    @Slot(int, result="QVariantList")
    def getRow(self, row: int) -> list:
        """Return all cell values in *row* as a list."""
        if 0 <= row < self.rowCount():
            return list(self._data[row])
        return []

    @Slot(int, result="QVariantList")
    def getColumn(self, col: int) -> list:
        """Return all cell values in *col* as a list."""
        if 0 <= col < self.columnCount():
            return [self._data[r][col] for r in range(self.rowCount())]
        return []

    @Slot(result=str)
    def exportCsv(self) -> str:
        """Export the full table (headers + data) as a CSV string."""
        def quote(v: str) -> str:
            return f'"{v}"' if ("," in v or '"' in v or "\n" in v) else v

        lines = [",".join(self._headers)]
        for row in self._data:
            lines.append(",".join(quote(v) for v in row))
        return "\n".join(lines)

    # ── Bulk operations ───────────────────────────────────────────────

    @Slot()
    def clearAll(self):
        """Blank every cell but keep the row/column structure intact."""
        r, c = self.rowCount(), self.columnCount()
        if r == 0 or c == 0:
            return
        self._data = [[""] * c for _ in range(r)]
        self.dataChanged.emit(
            self.index(0, 0),
            self.index(r - 1, c - 1),
            [Qt.DisplayRole, Qt.EditRole],
        )

    @Slot(int, int)
    def resetTable(self, rows: int, cols: int):
        """Replace the table with a fresh rows × cols empty grid."""
        self.beginResetModel()
        self._headers = [self._default_header(c) for c in range(cols)]
        self._data    = [[""] * cols for _ in range(rows)]
        self.endResetModel()
        self.structureChanged.emit()

    # ── Internal helpers ──────────────────────────────────────────────

    @staticmethod
    def _default_header(col: int) -> str:
        """'Col A', 'Col B', … 'Col Z', 'Col 26', 'Col 27', …"""
        return f"Col {chr(65 + col)}" if col < 26 else f"Col {col}"
