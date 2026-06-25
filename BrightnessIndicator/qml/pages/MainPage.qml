import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Page {
    id: page

    property string selectedPath: ""

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("ImageLab")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Выбрать изображение")
                onClicked: pageStack.push(imagePickerComponent)
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Обработать")
                enabled: page.selectedPath !== "" && !imageProcessor.busy
                onClicked: imageProcessor.process(page.selectedPath)
            }

            SectionHeader {
                text: qsTr("Оригинал")
                visible: page.selectedPath !== ""
            }

            Image {
                width: parent.width
                height: Math.min(sourceSize.height, 400)
                fillMode: Image.PreserveAspectFit
                visible: page.selectedPath !== ""
                source: page.selectedPath
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: imageProcessor.busy
                visible: imageProcessor.busy
                size: BusyIndicatorSize.Large
            }

            SectionHeader {
                text: qsTr("Результат")
                visible: imageProcessor.resultSource !== ""
            }

            Image {
                width: parent.width
                height: Math.min(sourceSize.height, 400)
                fillMode: Image.PreserveAspectFit
                cache: false
                visible: imageProcessor.resultSource !== ""
                source: imageProcessor.resultSource
            }

            SectionHeader {
                text: qsTr("Статистика")
                visible: imageProcessor.elapsedMs > 0
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                text: qsTr("Средняя яркость: %1").arg(
                          imageProcessor.meanBrightness.toFixed(1))
                color: Theme.primaryColor
                visible: imageProcessor.elapsedMs > 0
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * x
                text: qsTr("Время обработки: %1 мс").arg(
                          imageProcessor.elapsedMs)
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                visible: imageProcessor.elapsedMs > 0
            }
        }
    }

    Component {
        id: imagePickerComponent
        ImagePickerPage {
            onSelectedContentPropertiesChanged: {
                page.selectedPath = selectedContentProperties.filePath
            }
        }
    }
}
