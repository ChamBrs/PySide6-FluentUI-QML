import pandas as pd
from PySide6.QtCore import QObject, Signal, Property

class ExcelLoader(QObject):
    dataChanged = Signal()

    def __init__(self):
        super().__init__()
        self.df = None
        self._salespersons = []
        self._firms = []
        self._locations = []
        self._practice_areas = []

    def loadExcel(self, file_path):
        raw_df = pd.read_excel(file_path, header=None)
        expected_columns = ['organisation', 'fy26 allocations', 'location', 'practice area', 'subsection type', 'volume of feedback (x market average)']
        # ...detect header, normalize columns, handle missing columns...
        # For demo, assume columns are correct
        self.df = raw_df
        self._salespersons = sorted(self.df['fy26 allocations'].dropna().unique())
        self._firms = sorted(self.df['organisation'].dropna().unique())
        self._locations = sorted(self.df['location'].dropna().unique())
        self._practice_areas = sorted(self.df['practice area'].dropna().unique())
        self.dataChanged.emit()

    def getSalespersons(self):
        return self._salespersons
    salespersons = Property(list, getSalespersons, notify=dataChanged)

    def getFirms(self):
        return self._firms
    firms = Property(list, getFirms, notify=dataChanged)

    def getLocations(self):
        return self._locations
    locations = Property(list, getLocations, notify=dataChanged)

    def getPracticeAreas(self):
        return self._practice_areas
    practiceAreas = Property(list, getPracticeAreas, notify=dataChanged)
