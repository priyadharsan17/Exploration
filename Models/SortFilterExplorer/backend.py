"""
backend.py
────────────────────────────────────────────────────────────────────────
Two classes:

ItemModel   — QAbstractListModel source with four roles:
                itemName   (str)   display name
                category   (str)   grouping label
                score      (int)   0–100 popularity score
                isActive   (bool)  actively maintained flag

FilterProxy — QSortFilterProxyModel subclass that:
                • overrides filterAcceptsRow for multi-criteria filtering
                  (text search  +  category  +  active-only toggle)
                • overrides lessThan for role-based custom sorting
                • exposes filteredCount / totalCount as bindable QML properties
                • exposes all filter / sort controls as @Slot methods

Instantiation
─────────────
    source = ItemModel()
    proxy  = FilterProxy(source)
    proxy.sort(0)                        # initial sort
    engine.rootContext().setContextProperty("proxyModel", proxy)

QML uses proxyModel as the ListView model.
All CRUD and filter/sort controls go through proxyModel slots.

QML-bindable Properties (auto-update via countChanged signal)
─────────────────────────────────────────────────────────────
    proxyModel.filteredCount  → int   items currently visible
    proxyModel.totalCount     → int   items in source model

Slots callable from QML
────────────────────────
    setSearchText(text)          live substring filter on name
    setCategoryFilter(category)  exact-match category filter; "" = all
    setActiveOnly(bool)          show only isActive=true items
    setSortField(field)          0=name  1=score  2=category
    setSortAscending(bool)       True = ascending
    addItem(name, category, score, active)  append to source
    removeProxyRow(row) → bool   delete by proxy row (maps to source)
"""

from PySide6.QtCore import (
    QAbstractListModel, QModelIndex, QSortFilterProxyModel, Qt,
    Signal, Slot, Property,
)


# ── Source model ──────────────────────────────────────────────────────────────

class ItemModel(QAbstractListModel):

    NAME_ROLE     = Qt.UserRole + 1
    CATEGORY_ROLE = Qt.UserRole + 2
    SCORE_ROLE    = Qt.UserRole + 3
    ACTIVE_ROLE   = Qt.UserRole + 4

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items: list[dict] = []

    # ── QAbstractListModel required overrides ─────────────────────────

    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:
        return 0 if parent.isValid() else len(self._items)

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self._items):
            return None
        item = self._items[index.row()]
        if role in (Qt.DisplayRole, self.NAME_ROLE):
            return item["name"]
        if role == self.CATEGORY_ROLE:
            return item["category"]
        if role == self.SCORE_ROLE:
            return item["score"]
        if role == self.ACTIVE_ROLE:
            return item["active"]
        return None

    def roleNames(self) -> dict:
        return {
            Qt.DisplayRole:     b"display",
            self.NAME_ROLE:     b"itemName",
            self.CATEGORY_ROLE: b"category",
            self.SCORE_ROLE:    b"score",
            self.ACTIVE_ROLE:   b"isActive",
        }

    # ── Python-side helpers ───────────────────────────────────────────

    def append(self, name: str, category: str, score: int, active: bool) -> None:
        row = len(self._items)
        self.beginInsertRows(QModelIndex(), row, row)
        self._items.append({"name": name, "category": category,
                            "score": score, "active": active})
        self.endInsertRows()

    def remove_at(self, row: int) -> bool:
        if row < 0 or row >= len(self._items):
            return False
        self.beginRemoveRows(QModelIndex(), row, row)
        self._items.pop(row)
        self.endRemoveRows()
        return True


# ── Proxy model ───────────────────────────────────────────────────────────────

class FilterProxy(QSortFilterProxyModel):

    countChanged = Signal()

    def __init__(self, source: ItemModel, parent=None):
        super().__init__(parent)
        self._search      = ""
        self._category    = ""      # "" = show all categories
        self._active_only = False
        self._sort_role   = ItemModel.NAME_ROLE
        self._sort_asc    = True

        self.setSourceModel(source)

        # keep filteredCount / totalCount bindings live
        self.rowsInserted.connect(self.countChanged)
        self.rowsRemoved.connect(self.countChanged)
        self.modelReset.connect(self.countChanged)

    # ── QSortFilterProxyModel overrides ──────────────────────────────

    def filterAcceptsRow(self, source_row: int, source_parent: QModelIndex) -> bool:
        m   = self.sourceModel()
        idx = m.index(source_row, 0, source_parent)

        name     = m.data(idx, ItemModel.NAME_ROLE)     or ""
        category = m.data(idx, ItemModel.CATEGORY_ROLE) or ""
        active   = m.data(idx, ItemModel.ACTIVE_ROLE)   or False

        if self._search and self._search.lower() not in name.lower():
            return False
        if self._category and category != self._category:
            return False
        if self._active_only and not active:
            return False
        return True

    def lessThan(self, left: QModelIndex, right: QModelIndex) -> bool:
        m  = self.sourceModel()
        lv = m.data(left,  self._sort_role)
        rv = m.data(right, self._sort_role)
        if isinstance(lv, str):
            return lv.lower() < rv.lower()
        return (lv or 0) < (rv or 0)

    # ── QML-bindable properties ───────────────────────────────────────

    @Property(int, notify=countChanged)
    def filteredCount(self) -> int:
        return self.rowCount()

    @Property(int, notify=countChanged)
    def totalCount(self) -> int:
        src = self.sourceModel()
        return src.rowCount() if src else 0

    # ── Slots ─────────────────────────────────────────────────────────

    @Slot(str)
    def setSearchText(self, text: str) -> None:
        self._search = text.strip()
        self.invalidateFilter()

    @Slot(str)
    def setCategoryFilter(self, category: str) -> None:
        self._category = category
        self.invalidateFilter()

    @Slot(bool)
    def setActiveOnly(self, value: bool) -> None:
        self._active_only = value
        self.invalidateFilter()

    @Slot(int)
    def setSortField(self, field: int) -> None:
        roles = [ItemModel.NAME_ROLE, ItemModel.SCORE_ROLE, ItemModel.CATEGORY_ROLE]
        self._sort_role = roles[field] if 0 <= field < len(roles) else ItemModel.NAME_ROLE
        self.sort(0, Qt.AscendingOrder if self._sort_asc else Qt.DescendingOrder)

    @Slot(bool)
    def setSortAscending(self, asc: bool) -> None:
        self._sort_asc = asc
        self.sort(0, Qt.AscendingOrder if asc else Qt.DescendingOrder)

    @Slot(str, str, int, bool)
    def addItem(self, name: str, category: str, score: int, active: bool) -> None:
        src = self.sourceModel()
        if src:
            src.append(name.strip(), category, score, active)

    @Slot(int, result=bool)
    def removeProxyRow(self, proxy_row: int) -> bool:
        if proxy_row < 0:
            return False
        src_idx = self.mapToSource(self.index(proxy_row, 0))
        src = self.sourceModel()
        if src and src_idx.isValid():
            return src.remove_at(src_idx.row())
        return False
