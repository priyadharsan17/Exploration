# TreeView Explorer

> Single window: an interactive tree on the left, controls panel on the right.  
> Covers **QAbstractItemModel**, the `index()` / `parent()` contract, custom role names, and all CRUD operations on a live expandable tree.

---

## Run

```bash
cd Trees/TreeViewExplorer
python main.py
```

Starts with a seeded 5-category technology stack tree (Frontend · Backend · Database · DevOps · Mobile), each with four leaf items.

---

## File Overview

| File | Role |
|---|---|
| `tree_backend.py` | Python `QAbstractItemModel` subclass — `TreeNode` + `TreeModel` with full CRUD |
| `main.py` | App entry point — seeds sample data, exposes model as `treeModel` context property |
| `TreeViewExplorer.qml` | Main explorer window — tree view + controls panel + status bar |

---

## Backend — `TreeModel` (`tree_backend.py`)

`TreeModel` extends `QAbstractItemModel` — the most general Qt model class, required for hierarchical (tree) data.  All CRUD is exposed as `@Slot` methods so QML can call them directly.

### TreeNode

Each node holds:

| Field | Type | Description |
|---|---|---|
| `id` | `int` | Unique stable integer — allocated once, never reused |
| `name` | `str` | Display name |
| `parent_node` | `TreeNode \| None` | Parent reference (`None` only for the hidden root) |
| `children` | `list[TreeNode]` | Ordered list of child nodes |
| `_row` | `int` | Index within `parent_node.children` — kept in sync on every add/remove |

### Custom Roles

| Role constant | QML name | Type | Description |
|---|---|---|---|
| `Qt.DisplayRole` | `display` | `str` | Node name (standard Qt alias) |
| `NAME_ROLE` | `nodeName` | `str` | Node name (custom alias) |
| `NODE_ID_ROLE` | `nodeId` | `int` | Unique node id — used to identify the selected node across operations |

Custom role names are registered via `roleNames()` returning a `dict[int, bytes]`.  QML delegates can declare `required property int nodeId` and `TreeView` fills it in automatically.

### Required QAbstractItemModel overrides

| Method | Purpose |
|---|---|
| `index(row, col, parent)` | Creates a `QModelIndex` for the child at `row` under `parent` using `createIndex(row, col, node)` |
| `parent(index)` | Returns the `QModelIndex` of `index`'s parent node; returns `QModelIndex()` for root-level items |
| `rowCount(parent)` | Returns the number of children under `parent` |
| `columnCount(parent)` | Returns `1` (single-column tree) |
| `data(index, role)` | Returns the node name for `DisplayRole` / `NAME_ROLE`, and the node id for `NODE_ID_ROLE` |

> `parent.column() > 0` must return `0` from `rowCount` — this is a required guard specified by the Qt documentation.

### `index()` / `parent()` contract

This is the trickiest part of `QAbstractItemModel`.  The node pointer is embedded directly in the `QModelIndex` via `createIndex(row, col, node)`.  When Qt calls `parent(index)`:

1. `index.internalPointer()` retrieves the child `TreeNode`
2. `child.parent_node` gives the parent `TreeNode`
3. If the parent is the hidden root, return `QModelIndex()` — root-level items have no valid parent index
4. Otherwise return `createIndex(parent._row, 0, parent)`

### Slots callable from QML

| Slot | Signature | Returns | Description |
|---|---|---|---|
| `addNode` | `(parentId: int, name: str)` | `int` new id or `-1` | Add child; pass `parentId = -1` for a top-level node |
| `removeNode` | `(nodeId: int)` | `bool` | Remove node and all descendants |
| `renameNode` | `(nodeId: int, name: str)` | `bool` | Rename a node; emits `dataChanged` |
| `getPath` | `(nodeId: int)` | `str` | Full path from root, e.g. `"Backend / FastAPI"` |
| `childCount` | `(nodeId: int)` | `int` | Direct child count; pass `-1` for root |
| `isLeaf` | `(nodeId: int)` | `bool` | `True` when the node has no children |

> All structural changes are wrapped in `beginInsertRows` / `endInsertRows` or `beginRemoveRows` / `endRemoveRows` so the QML `TreeView` animates updates correctly.

---

## QML — `TreeViewExplorer.qml`

### Layout

```
┌─────────────────────────────────────┬───────────────────┐
│  TreeView (scrollable, clipped)     │  Controls panel   │
│                                     │                   │
│  ▸ 🗂 Frontend                      │  Selected Node    │
│    ▾ 🗂 Backend                     │  ─────────────    │
│        ▪ Django                     │  Add Node         │
│        ▪ FastAPI                    │  Rename           │
│        ...                          │  Remove           │
│                                     │  Node Info        │
│                                     │  Expand / Collapse│
├─────────────────────────────────────┴───────────────────┤
│  Status bar                                              │
└──────────────────────────────────────────────────────────┘
```

### Delegate required properties

The `TreeView` delegate declares these as `required property`, which Qt fills in automatically:

| Property | Source | Description |
|---|---|---|
| `display` | Model (`DisplayRole`) | Node name |
| `nodeId` | Model (`NODE_ID_ROLE`) | Unique id — stored in `root.selectedNodeId` on click |
| `row` | `TreeView` | Visual row index — passed to `toggleExpanded(row)` |
| `depth` | `TreeView` | Nesting depth — drives left-margin indentation (`depth * 22 px`) |
| `hasChildren` | `TreeView` | Whether the node can be expanded |
| `expanded` | `TreeView` | Whether the node is currently expanded |
| `isTreeNode` | `TreeView` | `true` for the tree column (always true here, single-column) |

### Controls panel

| Section | Operations |
|---|---|
| Selected Node | Shows the current node's name and stable id |
| Add Node | Add child under selected node; add new top-level node |
| Rename | Rename the selected node in-place |
| Remove | Delete the selected node and all its descendants |
| Node Info | Get full path · child count · leaf check |
| View | Expand All (`expandRecursively()`) · Collapse All (`collapseRecursively()`) |

### Key QML concepts demonstrated

| Concept | Where |
|---|---|
| `TreeView` with a custom delegate | `TreeViewExplorer.qml` |
| `required property` injection (model roles + TreeView properties) | Delegate block |
| `depth` for dynamic left-margin indentation | `anchors.leftMargin: depth * 22 + 10` |
| `toggleExpanded(row)` on click | `MouseArea.onClicked` |
| `expandRecursively()` / `collapseRecursively()` (Qt 6.4+) | View section buttons |
| `ScrollBar.vertical` attached to `TreeView` | Tree scroll bar |
| Stable node id via custom role — survives rename / move | `nodeId` role + `root.selectedNodeId` |
