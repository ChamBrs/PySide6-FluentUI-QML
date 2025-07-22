import FluentUI 1.0
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    Column {
        spacing: 16
        FluButton {
            text: "Load Excel"
            onClicked: {
                var fileDialog = Qt.createQmlObject('import QtQuick.Dialogs 1.2; FileDialog { }', root, "fileDialog");
                fileDialog.title = "Select Excel File";
                fileDialog.selectExisting = true;
                fileDialog.nameFilters = ["Excel Files (*.xlsx *.xls)"];
                fileDialog.onAccepted.connect(function() {
                    chartHelper.loadExcel(fileDialog.fileUrl.toString().replace("file://", ""));
                });
                fileDialog.open();
            }
        }
        FluComboBox { id: salespersonCombo; model: chartHelper.allocations() }
        FluComboBox { id: firmCombo; model: chartHelper.organisations() }
        FluComboBox { id: chartTypeCombo; model: ["Practice Area", "Location+Practice"] }
        FluListView { id: locationsList; model: chartHelper.locations(); checkable: true }
        FluListView { id: practiceList; model: chartHelper.practiceAreas(); checkable: true }
        FluButton {
            text: "Generate Chart"
            onClicked: {
                var chartData = chartHelper.standardChart(
                    salespersonCombo.currentText,
                    firmCombo.currentText,
                    locationsList.checkedItems,
                    practiceList.checkedItems,
                    chartTypeCombo.currentText
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
