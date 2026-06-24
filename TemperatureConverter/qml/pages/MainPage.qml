import QtQuick 2.0
import Sailfish.Silica 1.0
Page {
    id: page
    allowedOrientations: Orientation.All
    property string currentUnit: "C_to_F"

    function calculate() {
        var raw = inputField.text.replace(",", ".")
        var value = parseFloat(raw)
        if (raw === "" || isNaN(value)) {
            return "—"
        }
        var result = 0
        switch (currentUnit) {
        case "C_to_F":
            result = value * 9 / 5 + 32
            break
        case "F_to_C":
            result = (value - 32) * 5 / 9
            break
        case "C_to_K":
            result = value + 273.15
            break
        }
        return result.toFixed(2)
    }

    function resultUnitLabel() {
        switch (currentUnit) {
        case "C_to_F": return "°F"
        case "F_to_C": return "°C"
        case "C_to_K": return "K"
        }
        return ""
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        PullDownMenu {
            MenuItem {
                text: qsTr("Очистить")
                onClicked: inputField.text = ""
            }
        }
        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Конвертер величин")
            }
            TextField {
                id: inputField
                width: parent.width
                label: qsTr("Введите значение")
                placeholderText: qsTr("Например, 25.5")
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }
            ComboBox {
                id: directionBox
                width: parent.width
                label: qsTr("Направление конвертации")
                currentIndex: 0
                menu: ContextMenu {
                    MenuItem { text: qsTr("°C → °F") }
                    MenuItem { text: qsTr("°F → °C") }
                    MenuItem { text: qsTr("°C → K") }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0: page.currentUnit = "C_to_F"; break
                    case 1: page.currentUnit = "F_to_C"; break
                    case 2: page.currentUnit = "C_to_K"; break
                    }
                }
            }
            Column {
                width: parent.width
                spacing: Theme.paddingSmall
                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    text: qsTr("Результат:")
                }
                Label {
                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    font.pixelSize: Theme.fontSizeExtraLarge
                    color: Theme.highlightColor
                    horizontalAlignment: Text.AlignHCenter
                    text: page.calculate() + " " + page.resultUnitLabel()
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
