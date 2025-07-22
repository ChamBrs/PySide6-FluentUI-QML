import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI 1.0

Item {
    id: chartPreview
    property var data: ({})
    width: 900
    height: 500
    Rectangle {
        anchors.fill: parent
        color: FluTheme.background
        border.color: FluTheme.primary
        border.width: 1
        radius: 8
        Column {
            anchors.centerIn: parent
            spacing: 8
            FluLabel {
                text: data.title ? data.title : "Chart Preview"
                font.pixelSize: 22
                horizontalAlignment: Text.AlignHCenter
            }
            Repeater {
                model: data.datasets ? data.datasets.length : 0
                FluLabel {
                    text: data.datasets[index].label + ": " + data.datasets[index].data.join(", ")
                    font.pixelSize: 16
                }
            }
            FluLabel {
                text: data.labels ? "Labels: " + data.labels.join(", ") : ""
                font.pixelSize: 14
            }
        }
    }
}
