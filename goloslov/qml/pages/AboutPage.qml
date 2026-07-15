import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    allowedOrientations: Orientation.All

    Rectangle {
        anchors.fill: parent
        color: "#121212"
    }

    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: Theme.itemSizeLarge + Theme.paddingLarge
        color: "#1E1E1E"
        z: 10

        Row {
            anchors { fill: parent; margins: Theme.paddingMedium }
            spacing: Theme.paddingSmall

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
                color: "#FFB300"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: 1; height: 1; }
        }
    }

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
            color: "#FFB300"
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
            color: "#FFB300"
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
