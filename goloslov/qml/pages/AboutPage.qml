import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: aboutPage
    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("О приложении")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr(
                    "Голослов — офлайн-диктофон с распознаванием речи\n\n" +
                    "Версия 1.0"
                )
            }

            SectionHeader {
                text: qsTr("Лицензия")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr(
                    "Используемые библиотеки находятся в открытом доступе: Qt, Vosk"
                )
            }

            SectionHeader {
                text: qsTr("Благодарности")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.WordWrap
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr(
                    "Модель распознавания речи: Vosk (https://alphacephei.com/vosk/)\n" +
                    "Выражаем благодарность разработчикам за отличные инструменты."
                )
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }
        }
    }
}
