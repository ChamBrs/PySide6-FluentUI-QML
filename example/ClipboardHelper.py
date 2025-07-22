from PySide6.QtCore import QObject
from PySide6.QtGui import QGuiApplication, QClipboard

class ClipboardHelper(QObject):
    def copyChart(self, chart_path="chart.png"):
        clipboard = QGuiApplication.clipboard()
        clipboard.setImage(chart_path)
