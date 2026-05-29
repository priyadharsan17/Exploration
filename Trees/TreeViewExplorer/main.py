import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

from tree_backend import TreeModel


def main():
    QQuickStyle.setStyle("Basic")
    app = QGuiApplication(sys.argv)
    app.setApplicationName("TreeView Explorer")
    app.setOrganizationName("Exploration")

    model = TreeModel()

    # ── Seed data: Technology Stack ───────────────────────────────────
    seed = {
        "Frontend":  ["React", "Vue", "Angular", "Svelte"],
        "Backend":   ["Django", "FastAPI", "Flask", "Express"],
        "Database":  ["PostgreSQL", "MongoDB", "Redis", "SQLite"],
        "DevOps":    ["Docker", "Kubernetes", "GitHub Actions", "Terraform"],
        "Mobile":    ["React Native", "Flutter", "Swift UI", "Jetpack Compose"],
    }

    for category, items in seed.items():
        cat_node = model.add_root_child(category)
        for item in items:
            model.add_child_to(cat_node, item)

    # ── Load QML ──────────────────────────────────────────────────────
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("treeModel", model)

    qml_file = Path(__file__).parent / "TreeViewExplorer.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
