import FluentUI 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    Column {
        spacing: 16
        FluComboBox { id: advFirmCombo; model: chartHelper.organisations(); multiSelect: true }
        FluTextBox { id: customTitle; placeholderText: "Custom Chart Title" }
        FluListView { id: advPracticeList; model: chartHelper.practiceAreas(); checkable: true }
        FluButton {
            text: "Generate Grouped Bar Chart"
            onClicked: {
                var chartData = chartHelper.advancedChart(
                    advFirmCombo.selectedItems,
                    customTitle.text,
                    advPracticeList.checkedItems,
                    "grouped"
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
