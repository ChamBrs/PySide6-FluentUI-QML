import matplotlib.pyplot as plt
from PySide6.QtCore import QObject, Signal, Property

class ChartRenderer(QObject):
    chartChanged = Signal()

    def __init__(self, excel_loader):
        super().__init__()
        self.excel_loader = excel_loader
        self._chartImage = ""
        self._advChartImage = ""
        self._compChartImage = ""

    def generateStandardChart(self, firm, locations, practices, chart_type):
        df = self.excel_loader.df
        if df is None:
            return
        filtered = df[(df['organisation'].str.lower() == firm.lower()) & (df['location'].isin(locations))]
        if practices:
            filtered = filtered[filtered['practice area'].isin(practices)]
        # ...deduplicate, sort, wrap labels...
        plt.figure(figsize=(10,6))
        plt.bar(filtered['practice area'], filtered['volume of feedback (x market average)'])
        plt.title(f"{firm} Feedback by Practice Area")
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.savefig("chart.png")
        self._chartImage = "chart.png"
        self.chartChanged.emit()

    def getChartImage(self):
        return self._chartImage
    chartImage = Property(str, getChartImage, notify=chartChanged)

    def generateAdvancedChart(self, salesperson, firms, title, locations, practices):
        df = self.excel_loader.df
        if df is None:
            return
        filtered = df[(df['fy26 allocations'] == salesperson) & (df['organisation'].isin(firms))]
        if locations:
            filtered = filtered[filtered['location'].isin(locations)]
        if practices:
            filtered = filtered[filtered['practice area'].isin(practices)]
        # ...average feedback, chart rendering...
        plt.figure(figsize=(10,6))
        for firm in firms:
            firm_df = filtered[filtered['organisation'] == firm]
            plt.bar(firm, firm_df['volume of feedback (x market average)'].mean())
        plt.title(title or "Advanced Grouped Bar Chart")
        plt.tight_layout()
        plt.savefig("adv_chart.png")
        self._advChartImage = "adv_chart.png"
        self.chartChanged.emit()

    def getAdvChartImage(self):
        return self._advChartImage
    advChartImage = Property(str, getAdvChartImage, notify=chartChanged)

    def generateCompetitorChart(self, main_firm, competitors, practice_areas):
        df = self.excel_loader.df
        if df is None:
            return
        firms = [main_firm] + competitors[:3]
        colors = plt.cm.tab10.colors
        firm_colors = {firm: colors[i % len(colors)] for i, firm in enumerate(firms)}
        data = {area: [] for area in practice_areas}
        for firm in firms:
            for area in practice_areas:
                df_firm_area = df[(df['organisation'] == firm) & (df['practice area'] == area)]
                feedback = df_firm_area['volume of feedback (x market average)'].astype(float).max() if not df_firm_area.empty else 0.0
                data[area].append(feedback)
        plt.figure(figsize=(10,6))
        import numpy as np
        x = np.arange(len(practice_areas))
        width = 0.2
        for i, firm in enumerate(firms):
            plt.bar(x + i*width, [data[area][i] for area in practice_areas], width, label=firm, color=firm_colors[firm])
        plt.xticks(x + width, practice_areas, rotation=45)
        plt.legend()
        plt.title("Competitor Practice Area Comparison")
        plt.tight_layout()
        plt.savefig("comp_chart.png")
        self._compChartImage = "comp_chart.png"
        self.chartChanged.emit()

    def getCompChartImage(self):
        return self._compChartImage
    compChartImage = Property(str, getCompChartImage, notify=chartChanged)
