# Table Explorer

> Single window: a live editable table on the left, controls panel on the right.  
> Covers **QAbstractTableModel**, cell-level CRUD, spreadsheet-style cell references, row/column data extraction, CSV export, and how to wrap all of it in a **reusable QML component**.

---

## Run

```bash
cd Tables/TableExplorer
python main.py
```

Starts with a seeded 6 × 5 employee table (Name · Department · Level · Salary · Since).

---

## File Overview

| File | Role |
|---|---|
| `table_backend.py` | Python `QAbstractTableModel` subclass — all data and CRUD logic |
| `main.py` | App entry point — seeds sample data, exposes model to QML |
| `SmartTable.qml` | **Reusable table component** — headers, selection, inline editing |
| `TableExplorer.qml` | Main explorer window — two-panel layout + controls |

---

## Backend — `TableModel` (`table_backend.py`)

`TableModel` extends `QAbstractTableModel`.  All public operations are exposed as `@Slot` methods so QML can call them directly.

### Bindable QML Properties

| Property | Type | Description |
|---|---|---|
| `rows` | `int` | Live row count — updates whenever structure changes |
| `cols` | `int` | Live column count — updates whenever structure changes |

Both are decorated with `@Property(int, notify=structureChanged)`.  The custom `structureChanged = Signal()` is emitted after every add / remove / reset so QML bindings auto-refresh.

### Required QAbstractTableModel overrides

| Method | Purpose |
|---|---|
| `rowCount(parent)` | Returns number of data rows |
| `columnCount(parent)` | Returns number of columns |
| `data(index, role)` | Returns cell value for `DisplayRole` / `EditRole` |
| `setData(index, value, role)` | Writes a cell and emits `dataChanged` |
| `headerData(section, orientation, role)` | Returns column names (horizontal) and 1-based row numbers (vertical) |
| `flags(index)` | Marks every cell as `Enabled | Selectable | Editable` |

### Slots callable from QML

**Row / Column CRUD**

| Slot | Signature | Effect |
|---|---|---|
| `addRow` | `()` | Appends a blank row — emits `rowsInserted` |
| `removeRow` | `(row: int)` | Deletes row at index — emits `rowsRemoved` |
| `addColumn` | `()` | Appends a blank column — emits `columnsInserted` |
| `removeColumn` | `(col: int)` | Deletes column at index — emits `columnsRemoved` |

> Uses `beginInsertRows` / `endInsertRows` (and column equivalents) so the view animates the change correctly.

**Cell CRUD**

| Slot | Signature | Returns |
|---|---|---|
| `setCell` | `(row, col, value: str)` | — |
| `getCell` | `(row, col)` | `str` — cell value or `""` |
| `setColumnHeader` | `(col, name: str)` | — (emits `headerDataChanged`) |

**Cell References (spreadsheet-style)**

| Slot | Signature | Returns | Example |
|---|---|---|---|
| `cellRef` | `(row, col)` | `str` | `cellRef(2, 1)` → `"B3"` |
| `parseCellRef` | `(ref: str)` | `[row, col]` or `[-1, -1]` | `parseCellRef("B3")` → `[2, 1]` |

Column 0 = A, column 1 = B, … column 25 = Z.  Row index is 0-based; the string uses 1-based row numbers.

**Data Extraction**

| Slot | Signature | Returns |
|---|---|---|
| `getRow` | `(row: int)` | `list[str]` — all values in that row |
| `getColumn` | `(col: int)` | `list[str]` — all values in that column |
| `exportCsv` | `()` | Full table as a CSV string (headers + data) |

**Bulk Operations**

| Slot | Effect |
|---|---|
| `clearAll()` | Blanks every cell, structure unchanged — emits `dataChanged` for the whole range |
| `resetTable(rows, cols)` | Replaces the table with a fresh empty grid — uses `beginResetModel` / `endResetModel` |

---

## SmartTable.qml — Reusable Component

Drop `SmartTable` anywhere and hand it a model:

```qml
SmartTable {
    anchors.fill: parent
    tableModel:   myModel    // any QAbstractTableModel
}
```

### Public API

**Required property**

```qml
required property var tableModel
```

**Optional properties**

| Property | Default | Description |
|---|---|---|
| `editable` | `true` | Enables double-click inline editing |
| `cellWidth` | `130` | Uniform column width (px) |
| `cellHeight` | `38` | Row height (px) |
| `headerHeight` | `32` | Horizontal header height (px) |
| `rowHeaderWidth` | `36` | Vertical row-number column width (px) |
| `columnWidths` | `null` | Optional `function(col) → int` for per-column widths |

**Selection**

```qml
property int selectedRow   // -1 = nothing selected
property int selectedCol
```

**Signals**

```qml
signal cellClicked(int row, int col)
signal cellEdited(int row, int col, string newValue)
```

**Method**

```qml
function forceLayout()   // call after structural model changes
```

### Visual structure

```
┌────┬──────────┬──────────┬──────────┐
│  # │  Name    │  Dept    │  Level   │  ← HorizontalHeaderView
├────┼──────────┼──────────┼──────────┤
│  1 │  Alice   │  Eng...  │  Senior  │
│  2 │  Bob     │  Market  │  Lead    │  ← TableView (cell delegates)
│  3 │  Carol   │  Eng...  │  Staff   │
└────┴──────────┴──────────┴──────────┘
  ↑
VerticalHeaderView
```

- Corner rectangle (`#`) sits at the intersection of both headers.
- `HorizontalHeaderView` and `VerticalHeaderView` use `syncView: tv` — they scroll in sync with the data TableView automatically.
- Cell delegates declare `required property string display` which maps to `Qt.DisplayRole` via the model's `data()` method.

### Inline editing

1. **Double-click** a cell → `_editRow` / `_editCol` set → `isEditing` property becomes `true`.
2. `onIsEditingChanged` fires → `Qt.callLater` defers `forceActiveFocus()` to the next event loop tick (avoids binding loops).
3. `TextInput` appears pre-selected; `Return` / `Tab` commits, `Escape` cancels.
4. Focus-lost also commits (so clicking away saves the edit).
5. Commit calls `tableModel.setCell(row, col, value)` → Python `setData()` emits `dataChanged` → `display` role updates → `Text` shows new value.

> **Why `Qt.callLater`?**  
> Calling `forceActiveFocus()` directly inside a property-change handler can trigger QML's binding-loop detector because the focus change re-enters binding evaluation.  `Qt.callLater` schedules the call for after the current evaluation cycle.

---

## Controls Panel

### Row Operations

| Button | What happens |
|---|---|
| `+ Add Row` | `tblModel.addRow()` — blank row at bottom |
| `× Last Row` | `tblModel.removeRow(rows - 1)` |
| `× Selected` | `tblModel.removeRow(selectedRow)` — disabled when nothing is selected |

### Column Operations

| Button | What happens |
|---|---|
| `+ Add Col` | `tblModel.addColumn()` — blank column on right |
| `× Last Col` | `tblModel.removeColumn(cols - 1)` |
| Rename | `tblModel.setColumnHeader(col#, name)` |

### Cell Reference & Edit

Enter a spreadsheet-style reference (e.g. `B3`) in the ref field:

| Button | What happens |
|---|---|
| `Get` | Reads `tblModel.getCell(row, col)` and fills the value field |
| `Set` | Calls `tblModel.setCell(row, col, value)` |
| `Jump` | Sets `selectedRow` / `selectedCol` to highlight the cell |
| `→ Ref Input` | Populates the ref + value fields from the currently selected cell |

The **Selected** display auto-updates via a binding on `selectedRow` / `selectedCol`.

### Data Extraction

| Button | Output |
|---|---|
| `Get Row n` | `tblModel.getRow(n)` → JSON array in output panel |
| `Get Col n` | `tblModel.getColumn(n)` → JSON array in output panel |
| `Export as CSV` | `tblModel.exportCsv()` → full CSV in output panel |

The output panel appears automatically when there is content; click **✕ clear** to dismiss it.

### Table Settings

| Control | Effect |
|---|---|
| `Editable` checkbox | Toggles double-click editing on SmartTable |
| `Clear All Cells` | `tblModel.clearAll()` — blanks data, keeps structure |
| `Reset 6 × 5` | `tblModel.resetTable(6, 5)` — fresh empty table |

---

## Key Concepts

| Concept | Where to look |
|---|---|
| `QAbstractTableModel` subclass | `table_backend.py` — all five required overrides |
| `@Slot` for QML-callable methods | Every CRUD method in `table_backend.py` |
| `@Property(notify=signal)` for live bindings | `rows`, `cols` in `table_backend.py` |
| `beginInsertRows` / `endInsertRows` | `addRow`, `removeRow` in `table_backend.py` |
| `dataChanged` signal | `setData` in `table_backend.py` |
| `headerDataChanged` signal | `setColumnHeader` in `table_backend.py` |
| `beginResetModel` / `endResetModel` | `resetTable` in `table_backend.py` |
| `TableView` delegate with `required property` | Cell delegate in `SmartTable.qml` |
| `HorizontalHeaderView` + `VerticalHeaderView` | `SmartTable.qml` — `syncView:` links them to the TableView |
| Reusable QML component pattern | `SmartTable.qml` — `required property`, signals, public method |
| Avoiding QML binding loops | `onIsEditingChanged` + `Qt.callLater` in `SmartTable.qml` |
