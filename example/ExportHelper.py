import pandas as pd
from PySide6.QtCore import QObject

class ExportHelper(QObject):
    def exportData(self, df, file_path="exported_data.xlsx"):
        if df is not None:
            df.to_excel(file_path, index=False)
