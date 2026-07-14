import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    Column {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: Theme.paddingLarge
            leftMargin: Theme.paddingMedium
            rightMargin: Theme.paddingMedium
        }
        spacing: Theme.paddingSmall

        Label {
            width: parent.width
            text: qsTr("goloslov")
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.highlightColor
        }

        Label {
            width: parent.width
            text: audioRecorder.isRecording ? qsTr("Идет запись...") : qsTr("Нет активных записей")
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryHighlightColor
        }
    }

    CoverActionList {
        CoverAction {
            iconSource: audioRecorder.isRecording ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-new"
            onTriggered: {
                if (audioRecorder.isRecording) {
                    audioRecorder.stopRecording();
                } else {
                    audioRecorder.startRecording();
                }
            }
        }
    }
}
