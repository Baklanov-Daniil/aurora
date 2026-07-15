import QtQuick 2.0
import QtQuick.Controls 1.4

Page {
    id: aboutPage
    allowedOrientations: Orientation.All

    Rectangle {
        anchors.fill: parent
        color: "#121212"
    }

    Column {
        anchors.centerIn: parent
        width: parent.width * 0.8
        spacing: Theme.paddingLarge

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Голослов")
            color: "white"
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
            color: "#333"
        }

        Label {
            width: parent.width
            text: qsTr("Версия 1.0\n\nИспользуемые библиотеки: Qt, Vosk\n\nМодель распознавания: Vosk (https://alphacephei.com/vosk/)")
            color: "#AAA"
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        IconButton {
            anchors.horizontalCenter: parent.horizontalCenter
            icon.source: "image://theme/icon-m-back"
            icon.color: "white"
            onClicked: pageStack.pop()
        }
    }
}