import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

from table_backend import TableModel


def main():
    QQuickStyle.setStyle("Basic")
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Table Explorer")
    app.setOrganizationName("Exploration")

    # ── Seed a realistic starting table ──────────────────────────────
    model = TableModel(rows=6, cols=5)

    headers = ["Name", "Department", "Level", "Salary", "Since"]
    for col, h in enumerate(headers):
        model.setColumnHeader(col, h)

    sample_data = [
        ("Alice",  "Engineering", "Senior",  "87500", "2019"),
        ("Bob",    "Marketing",   "Lead",    "72000", "2021"),
        ("Carol",  "Engineering", "Staff",   "65000", "2022"),
        ("Dave",   "HR",          "Manager", "81000", "2018"),
        ("Eve",    "Marketing",   "Senior",  "69000", "2020"),
        ("Frank",  "Engineering", "Lead",    "78500", "2017"),
    ]
    for row, values in enumerate(sample_data):
        for col, v in enumerate(values):
            model.setCell(row, col, v)

    # ── Load QML ──────────────────────────────────────────────────────
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("tblModel", model)

    qml_file = Path(__file__).parent / "TableExplorer.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
