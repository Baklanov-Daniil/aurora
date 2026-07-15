import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    allowedOrientations: Orientation.All

    Rectangle {
        anchors.fill: parent
        color: "#121212"
    }

    // --- Заголовок ---
    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: Theme.itemSizeLarge + Theme.paddingLarge
        color: "#1E1E1E"
        z: 10

        Row {
            anchors { fill: parent; margins: Theme.paddingMedium }
            spacing: Theme.paddingSmall

            // Кнопка назад (исправлено для Qt 5.6: MouseArea + Image вместо icon.color)
            MouseArea {
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                anchors.verticalCenter: parent.verticalCenter
                onClicked: pageStack.pop()
                Image {
                    anchors.centerIn: parent
                    source: "image://theme/icon-m-back"
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                }
            }

            Item { width: 1; height: 1; }

            Label {
                text: qsTr("О приложении")
                color: "#FFB300" // Изменено с #FF6B6B на оранжевый
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: 1; height: 1; }
        }
    }

    // --- Контент ---
    Column {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingLarge
        }
        spacing: Theme.paddingLarge

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Голослов")
            color: "#FFB300" // Изменено с white на оранжевый для акцента
            font.pixelSize: Theme.fontSizeExtraLarge
            font.bold: true
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Офлайн-диктофон с распознаванием речи")
            color: "#888"
            font.pixelSize: Theme.fontSizeMedium
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#FFB300" // Разделительная линия тоже оранжевая
            opacity: 0.5
        }

        Label {
            width: parent.width
            text: qsTr("Версия 1.0\nИспользуемые библиотеки: Qt, Vosk\nМодель распознавания: Vosk (https://alphacephei.com/vosk/)")
            color: "#AAA"
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
