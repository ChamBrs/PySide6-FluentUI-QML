from __future__ import annotations
from PySide6.QtCore import QObject, Slot, Signal
import pandas as pd

class ChartGeneratorHelper(QObject):
    chartUpdated = Signal(dict)
    dataLoaded = Signal()

    def __init__(self):
        super().__init__()
        self._df = pd.DataFrame()
        self._filtered = pd.DataFrame()

    @Slot(str, result=bool)
    def loadExcel(self, path: str) -> bool:
        try:
            raw_df = pd.read_excel(path, header=None)
            expected_cols = [
                'organisation',
                'fy26 allocations',
                'location',
                'practice area',
                'subsection type',
                'volume of feedback (x market average)'
            ]
            header_row = 0
            for i, row in raw_df.iterrows():
                row_lower = [str(v).strip().lower() for v in row]
                if all(any(col == cell for cell in row_lower) for col in expected_cols):
                    header_row = i
                    break
            df = pd.read_excel(path, header=header_row)
            col_map = {}
            for col in df.columns:
                key = str(col).strip().lower()
                for exp in expected_cols:
                    if key == exp:
                        col_map[exp] = col
                        break
            for exp in expected_cols:
                if exp not in col_map:
                    df[exp] = ''
            df = df.rename(columns={v: k for k, v in col_map.items()})
            self._df = df
            self._filtered = df
            self.dataLoaded.emit()
            return True
        except Exception as e:
            print(f"Failed to load excel: {e}")
            return False

    @Slot(result='QVariantList')
    def organisations(self):
        if self._df.empty:
            return []
        return list(self._df['organisation'].dropna().unique())

    @Slot(result='QVariantList')
    def locations(self):
        if self._df.empty:
            return []
        return list(self._df['location'].dropna().unique())

    @Slot(result='QVariantList')
    def practiceAreas(self):
        if self._df.empty:
            return []
        return list(self._df['practice area'].dropna().unique())

    @Slot(result='QVariantList')
    def allocations(self):
        if self._df.empty:
            return []
        return list(self._df['fy26 allocations'].dropna().unique())

    def _build_dataset(self, df: pd.DataFrame, label_col: str, value_col: str):
        labels = list(df[label_col])
        data = list(df[value_col])
        return {'labels': labels,
                'datasets': [{'label': value_col, 'data': data}]}

    @Slot(str, str, 'QVariantList', 'QVariantList', str, result='QVariantMap')
    def standardChart(self, salesperson: str, firm: str, locations, practiceAreas, chartType: str):
        if self._df.empty:
            return {}
        df = self._df
        if salesperson:
            df = df[df['fy26 allocations'] == salesperson]
        if firm:
            df = df[df['organisation'] == firm]
        if locations:
            df = df[df['location'].isin(locations)]
        if practiceAreas:
            df = df[df['practice area'].isin(practiceAreas)]
        self._filtered = df
        if chartType == 'location+practice':
            pivot = df.groupby(['location', 'practice area'])['volume of feedback (x market average)'].sum().unstack().fillna(0)
            datasets = []
            for area in pivot.columns:
                datasets.append({'label': area, 'data': list(pivot[area])})
            return {'labels': list(pivot.index), 'datasets': datasets}
        grouped = df.groupby('practice area')['volume of feedback (x market average)'].sum().reset_index()
        return self._build_dataset(grouped, 'practice area', 'volume of feedback (x market average)')

    @Slot('QVariantList', str, 'QVariantList', str, result='QVariantMap')
    def advancedChart(self, firms, title: str, practiceAreas, chartType: str):
        if self._df.empty:
            return {}
        df = self._df
        if firms:
            df = df[df['organisation'].isin(firms)]
        if practiceAreas:
            df = df[df['practice area'].isin(practiceAreas)]
        grouped = df.groupby(['organisation', 'practice area'])['volume of feedback (x market average)'].sum().unstack().fillna(0)
        datasets = []
        for firm in grouped.index:
            datasets.append({'label': firm, 'data': list(grouped.loc[firm])})
        self._filtered = df
        return {'labels': list(grouped.columns), 'datasets': datasets, 'title': title}

    @Slot(str, 'QVariantList', 'QVariantList', result='QVariantMap')
    def competitorChart(self, mainFirm: str, competitors, practiceAreas):
        if self._df.empty:
            return {}
        firms = [mainFirm] + list(filter(None, competitors))
        df = self._df[self._df['organisation'].isin(firms)]
        if practiceAreas:
            df = df[df['practice area'].isin(practiceAreas)]
        grouped = df.groupby(['organisation', 'practice area'])['volume of feedback (x market average)'].sum().unstack().fillna(0)
        datasets = []
        for firm in grouped.index:
            datasets.append({'label': firm, 'data': list(grouped.loc[firm])})
        self._filtered = df
        return {'labels': list(grouped.columns), 'datasets': datasets}

    @Slot(str)
    def exportFiltered(self, path: str):
        if self._filtered.empty:
            return
        try:
            self._filtered.to_excel(path, index=False)
        except Exception as e:
            print(f"Failed to export: {e}")
