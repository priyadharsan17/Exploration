"""
tree_backend.py
────────────────────────────────────────────────────────────────────────
A QAbstractItemModel subclass that manages a named-node tree and exposes
CRUD operations as QML-callable @Slot methods.

Instantiation
─────────────
    model = TreeModel()
    engine.rootContext().setContextProperty("treeModel", model)

Custom Roles (accessible in QML via role name)
────────────────────────────────────────────────
    display     → str   node name          (Qt.DisplayRole alias)
    nodeName    → str   node name          (NAME_ROLE)
    nodeId      → int   unique stable id   (NODE_ID_ROLE)

Slots callable from QML
────────────────────────
    addNode(parentId, name) → int
        Add a child named *name* under the node with *parentId*.
        Pass parentId = -1 to add a top-level node.
        Returns the new node's id, or -1 on failure.

    removeNode(nodeId) → bool
        Remove the node and all its descendants.

    renameNode(nodeId, name) → bool
        Rename a node.

    getPath(nodeId) → str
        Return the full path from the root, e.g. "Backend / FastAPI".

    childCount(nodeId) → int
        Number of direct children. Pass -1 for the root.

    isLeaf(nodeId) → bool
        True when the node has no children.
"""

from PySide6.QtCore import (
    QAbstractItemModel, QModelIndex, Qt,
    Signal, Slot,
)


# ── Tree node ─────────────────────────────────────────────────────────────────

class TreeNode:
    _next_id: int = 0

    @classmethod
    def _alloc_id(cls) -> int:
        nid = cls._next_id
        cls._next_id += 1
        return nid

    def __init__(self, name: str, parent: "TreeNode | None" = None):
        self.id:          int                   = TreeNode._alloc_id()
        self.name:        str                   = name
        self.parent_node: TreeNode | None       = parent
        self.children:    list[TreeNode]        = []
        self._row:        int                   = 0   # index within parent.children

    def add_child(self, child: "TreeNode") -> None:
        child._row = len(self.children)
        child.parent_node = self
        self.children.append(child)

    def remove_child(self, child: "TreeNode") -> None:
        self.children.remove(child)
        for i, c in enumerate(self.children):
            c._row = i


# ── Model ─────────────────────────────────────────────────────────────────────

class TreeModel(QAbstractItemModel):

    NAME_ROLE    = Qt.UserRole + 1
    NODE_ID_ROLE = Qt.UserRole + 2

    structureChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._root    = TreeNode("__root__")
        self._id_map: dict[int, TreeNode] = {}   # id → node (excludes root)

    # ── Internal helpers ──────────────────────────────────────────────────────

    def _node(self, index: QModelIndex) -> TreeNode:
        return self._root if not index.isValid() else index.internalPointer()

    def _index_for(self, node: TreeNode) -> QModelIndex:
        if node is self._root:
            return QModelIndex()
        return self.createIndex(node._row, 0, node)

    def _register(self, node: TreeNode) -> None:
        self._id_map[node.id] = node
        for c in node.children:
            self._register(c)

    def _unregister(self, node: TreeNode) -> None:
        self._id_map.pop(node.id, None)
        for c in node.children:
            self._unregister(c)

    # ── QAbstractItemModel required overrides ─────────────────────────────────

    def index(self, row: int, col: int, parent: QModelIndex = QModelIndex()) -> QModelIndex:
        if not self.hasIndex(row, col, parent):
            return QModelIndex()
        child = self._node(parent).children[row]
        return self.createIndex(row, col, child)

    def parent(self, index: QModelIndex) -> QModelIndex:   # type: ignore[override]
        if not index.isValid():
            return QModelIndex()
        p = index.internalPointer().parent_node
        if p is None or p is self._root:
            return QModelIndex()
        return self.createIndex(p._row, 0, p)

    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:
        if parent.column() > 0:
            return 0
        return len(self._node(parent).children)

    def columnCount(self, parent: QModelIndex = QModelIndex()) -> int:  # noqa: ARG002
        return 1

    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):
        if not index.isValid():
            return None
        node: TreeNode = index.internalPointer()
        if role in (Qt.DisplayRole, self.NAME_ROLE):
            return node.name
        if role == self.NODE_ID_ROLE:
            return node.id
        return None

    def roleNames(self) -> dict:
        return {
            Qt.DisplayRole:    b"display",
            self.NAME_ROLE:    b"nodeName",
            self.NODE_ID_ROLE: b"nodeId",
        }

    def headerData(self, section: int, orientation: Qt.Orientation, role: int = Qt.DisplayRole):
        if orientation == Qt.Horizontal and role == Qt.DisplayRole and section == 0:
            return "Name"
        return None

    # ── Seed helpers (Python-only) ────────────────────────────────────────────

    def add_root_child(self, name: str) -> TreeNode:
        node = TreeNode(name)
        self._root.add_child(node)
        self._register(node)
        return node

    def add_child_to(self, parent_node: TreeNode, name: str) -> TreeNode:
        node = TreeNode(name)
        parent_node.add_child(node)
        self._register(node)
        return node

    # ── QML Slots ─────────────────────────────────────────────────────────────

    @Slot(int, str, result=int)
    def addNode(self, parent_id: int, name: str) -> int:
        name = name.strip()
        if not name:
            return -1

        if parent_id == -1:
            parent_node = self._root
            parent_idx  = QModelIndex()
        else:
            parent_node = self._id_map.get(parent_id)
            if parent_node is None:
                return -1
            parent_idx = self._index_for(parent_node)

        row = len(parent_node.children)
        self.beginInsertRows(parent_idx, row, row)
        new_node = TreeNode(name)
        parent_node.add_child(new_node)
        self._id_map[new_node.id] = new_node
        self.endInsertRows()
        self.structureChanged.emit()
        return new_node.id

    @Slot(int, result=bool)
    def removeNode(self, node_id: int) -> bool:
        node = self._id_map.get(node_id)
        if node is None:
            return False
        parent_node = node.parent_node
        if parent_node is None:
            return False

        parent_idx = self._index_for(parent_node)
        row = node._row
        self.beginRemoveRows(parent_idx, row, row)
        parent_node.remove_child(node)
        self._unregister(node)
        self.endRemoveRows()
        self.structureChanged.emit()
        return True

    @Slot(int, str, result=bool)
    def renameNode(self, node_id: int, name: str) -> bool:
        name = name.strip()
        if not name:
            return False
        node = self._id_map.get(node_id)
        if node is None:
            return False
        node.name = name
        idx = self._index_for(node)
        self.dataChanged.emit(idx, idx, [Qt.DisplayRole, self.NAME_ROLE])
        return True

    @Slot(int, result=str)
    def getPath(self, node_id: int) -> str:
        node = self._id_map.get(node_id)
        if node is None:
            return ""
        parts: list[str] = []
        n = node
        while n is not None and n is not self._root:
            parts.append(n.name)
            n = n.parent_node
        return " / ".join(reversed(parts))

    @Slot(int, result=int)
    def childCount(self, node_id: int) -> int:
        if node_id == -1:
            return len(self._root.children)
        node = self._id_map.get(node_id)
        return len(node.children) if node else 0

    @Slot(int, result=bool)
    def isLeaf(self, node_id: int) -> bool:
        node = self._id_map.get(node_id)
        return node is not None and len(node.children) == 0
