import FluentUI 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    Column {
        spacing: 16
        FluComboBox { id: mainFirmCombo; model: chartHelper.organisations() }
        FluListView { id: competitorList; model: chartHelper.organisations(); multiSelect: true; maxSelect: 3 }
        FluListView { id: practiceAreaList; model: chartHelper.practiceAreas(); multiSelect: true; maxSelect: 4 }
        FluButton {
            text: "Generate Comparison Chart"
            onClicked: {
                var chartData = chartHelper.competitorChart(
                    mainFirmCombo.currentText,
                    competitorList.selectedItems,
                    practiceAreaList.selectedItems
                );
                chartPreview.data = chartData;
            }
        }
        FluButton {
            text: "Export Filtered Data"
            onClicked: {
                var fileDialog = Qt.createQmlObject('import QtQuick.Dialogs 1.2; FileDialog { }', root, "exportDialog");
                fileDialog.title = "Export Filtered Data";
                fileDialog.selectExisting = false;
                fileDialog.nameFilters = ["Excel Files (*.xlsx)"];
                fileDialog.onAccepted.connect(function() {
                    chartHelper.exportFiltered(fileDialog.fileUrl.toString().replace("file://", ""));
                });
                fileDialog.open();
            }
        }
        ChartPreview { id: chartPreview }
    }
}
