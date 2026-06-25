import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    Column {
        anchors.centerIn: parent
        width: parent.width
        spacing: Theme.paddingSmall

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("ImageLab")
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: imageProcessor.busy
                  ? qsTr("Обработка...")
                  : (imageProcessor.elapsedMs > 0
                     ? qsTr("Яркость: %1").arg(
                           imageProcessor.meanBrightness.toFixed(1))
                     : qsTr("Выберите фото"))
            color: Theme.secondaryHighlightColor
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
