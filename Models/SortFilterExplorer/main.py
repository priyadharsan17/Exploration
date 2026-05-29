import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

from backend import ItemModel, FilterProxy


def main():
    QQuickStyle.setStyle("Basic")
    app = QGuiApplication(sys.argv)
    app.setApplicationName("SortFilter Explorer")
    app.setOrganizationName("Exploration")

    source = ItemModel()

    # ── Seed data: tech ecosystem items ──────────────────────────────
    #   name,              category,   score, active
    seed = [
        ("React",           "Frontend",  95, True),
        ("Vue",             "Frontend",  82, True),
        ("Angular",         "Frontend",  78, True),
        ("Svelte",          "Frontend",  71, True),
        ("Django",          "Backend",   88, True),
        ("FastAPI",         "Backend",   85, True),
        ("Flask",           "Backend",   76, True),
        ("Express",         "Backend",   80, True),
        ("Rails",           "Backend",   62, False),
        ("PostgreSQL",      "Database",  90, True),
        ("MongoDB",         "Database",  83, True),
        ("Redis",           "Database",  86, True),
        ("SQLite",          "Database",  70, True),
        ("CouchDB",         "Database",  44, False),
        ("Docker",          "DevOps",    93, True),
        ("Kubernetes",      "DevOps",    89, True),
        ("GitHub Actions",  "DevOps",    84, True),
        ("Terraform",       "DevOps",    81, True),
        ("Jenkins",         "DevOps",    55, False),
        ("React Native",    "Mobile",    79, True),
        ("Flutter",         "Mobile",    87, True),
        ("Swift UI",        "Mobile",    75, True),
        ("Xamarin",         "Mobile",    38, False),
    ]

    for name, category, score, active in seed:
        source.append(name, category, score, active)

    proxy = FilterProxy(source)
    proxy.sort(0)   # initial sort: name ascending

    # ── Load QML ─────────────────────────────────────────────────────
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("proxyModel", proxy)

    qml_file = Path(__file__).parent / "SortFilterExplorer.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
