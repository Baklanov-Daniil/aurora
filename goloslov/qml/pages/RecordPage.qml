import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Запись")
            }

            Item {
                width: parent.width
                height: Theme.itemSizeHuge

                Label {
                    id: timerLabel
                    anchors.centerIn: parent
                    // Безопасный формат времени для Qt 5.6
                    text: {
                        var m = Math.floor(audioRecorder.duration / 60);
                        var s = audioRecorder.duration % 60;
                        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
                    }
                    font.pixelSize: Theme.fontSizeExtraLarge
                    color: audioRecorder.isRecording ? Theme.highlightColor : Theme.primaryColor
                }
            }

            Rectangle {
                width: parent.width - 2 * Theme.horizontalPageMargin
                height: Theme.paddingMedium
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryColor
                opacity: 0.3

                Rectangle {
                    width: Math.max(0, parent.width * audioRecorder.level)
                    height: parent.height
                    color: Theme.highlightColor
                    Behavior on width {
                        NumberAnimation { duration: 100 }
                    }
                }
            }

            Button {
                text: audioRecorder.isRecording ? qsTr("Остановить") : qsTr("Начать запись")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    if (audioRecorder.isRecording) {
                        audioRecorder.stopRecording();
                    } else {
                        audioRecorder.startRecording();
                    }
                }
            }
        }
    }

    Connections {
        target: audioRecorder
        onRecordingFinished: {
            console.log("Recording saved to:", filePath)
            // Пока просто возвращаемся назад. На следующем этапе здесь будет создание заметки.
            pageStack.pop();
        }
    }
}
