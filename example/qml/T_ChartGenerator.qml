import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import QtQuick.Dialogs 1.3

FluScrollablePage {
    id: root
    title: qsTr("Chart Generator")

    FileDialog {
        id: fileDlg
        nameFilters: ["Excel Files (*.xlsx *.xls)"]
        onAccepted: ChartGeneratorHelper.loadExcel(fileDlg.fileUrls[0])
    }

    RowLayout {
        spacing: 10
        FluFilledButton {
            text: qsTr("Open Excel")
            onClicked: fileDlg.open()
        }
    }

    Connections {
        target: ChartGeneratorHelper
        function onDataLoaded() {
            salesBox.model = ChartGeneratorHelper.allocations()
            firmBox.model = ChartGeneratorHelper.organisations()
            locationList.model = ChartGeneratorHelper.locations()
            practiceList.model = ChartGeneratorHelper.practiceAreas()
            firmList.model = ChartGeneratorHelper.organisations()
            advPractice.model = ChartGeneratorHelper.practiceAreas()
            mainFirm.model = ChartGeneratorHelper.organisations()
            comps.model = ChartGeneratorHelper.organisations()
            compPractice.model = ChartGeneratorHelper.practiceAreas()
        }
    }

    FluTabView {
        id: tabs
        Layout.fillWidth: true
        Layout.fillHeight: true

        FluTabItem {
            title: qsTr("Standard")
            ColumnLayout {
                spacing: 8
                width: parent.width

                FluComboBox {
                    id: salesBox
                    width: 200
                    editable: false
                    model: ChartGeneratorHelper.allocations()
                    placeholderText: qsTr("Salesperson")
                }
                FluComboBox {
                    id: firmBox
                    width: 200
                    editable: false
                    model: ChartGeneratorHelper.organisations()
                    placeholderText: qsTr("Firm")
                }
                FluListWidget {
                    id: locationList
                    Layout.fillWidth: true
                    height: 80
                    model: ChartGeneratorHelper.locations()
                    multiple: true
                }
                FluListWidget {
                    id: practiceList
                    Layout.fillWidth: true
                    height: 80
                    model: ChartGeneratorHelper.practiceAreas()
                    multiple: true
                }
                FluComboBox {
                    id: typeBox
                    width: 200
                    model: ["practice", "location+practice"]
                    currentIndex: 0
                }
                FluButton {
                    text: qsTr("Generate")
                    onClicked: {
                        chartItem.chartData = ChartGeneratorHelper.standardChart(
                                salesBox.currentText,
                                firmBox.currentText,
                                locationList.currentValues,
                                practiceList.currentValues,
                                typeBox.currentText)
                    }
                }
                FluChart {
                    id: chartItem
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    chartType: 'bar'
                }
                RowLayout {
                    spacing: 10
                    FluFilledButton {
                        text: qsTr("Copy")
                        onClicked: chartItem.grabToImage(function(result){
                                result.saveToClipboard();
                            })
                    }
                    FluFilledButton {
                        text: qsTr("Export")
                        onClicked: ChartGeneratorHelper.exportFiltered("export.xlsx")
                    }
                }
            }
        }

        FluTabItem {
            title: qsTr("Advanced")
            ColumnLayout {
                spacing: 8
                width: parent.width

                FluListWidget {
                    id: firmList
                    Layout.fillWidth: true
                    height: 80
                    multiple: true
                    model: ChartGeneratorHelper.organisations()
                }
                FluTextBox {
                    id: titleEdit
                    placeholderText: qsTr("Chart Title")
                }
                FluListWidget {
                    id: advPractice
                    Layout.fillWidth: true
                    height: 80
                    multiple: true
                    model: ChartGeneratorHelper.practiceAreas()
                }
                FluButton {
                    text: qsTr("Generate")
                    onClicked: {
                        chartItem2.chartData = ChartGeneratorHelper.advancedChart(
                                firmList.currentValues,
                                titleEdit.text,
                                advPractice.currentValues,
                                'bar')
                    }
                }
                FluChart {
                    id: chartItem2
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    chartType: 'bar'
                }
            }
        }

        FluTabItem {
            title: qsTr("Competitor")
            ColumnLayout {
                spacing: 8
                width: parent.width

                FluComboBox {
                    id: mainFirm
                    width: 200
                    model: ChartGeneratorHelper.organisations()
                }
                FluListWidget {
                    id: comps
                    Layout.fillWidth: true
                    height: 80
                    multiple: true
                    model: ChartGeneratorHelper.organisations()
                }
                FluListWidget {
                    id: compPractice
                    Layout.fillWidth: true
                    height: 80
                    multiple: true
                    model: ChartGeneratorHelper.practiceAreas()
                }
                FluButton {
                    text: qsTr("Generate")
                    onClicked: {
                        chartItem3.chartData = ChartGeneratorHelper.competitorChart(
                                mainFirm.currentText,
                                comps.currentValues,
                                compPractice.currentValues)
                    }
                }
                FluChart {
                    id: chartItem3
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300
                    chartType: 'bar'
                }
            }
        }
    }
}
