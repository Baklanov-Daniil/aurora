import QtQuick 2.0
import QtQuick.Controls 1.4
import ru.omstu.goloslov 1.0
import "../Database.js" as Db

Page {
    id: recordingPage
    allowedOrientations: Orientation.All

    function formatTime(seconds) {
        var s = Math.floor(seconds)
        var min = Math.floor(s / 60)
        var sec = s % 60
        return (min < 10 ? "0" : "") + min + ":" + (sec < 10 ? "0" : "") + sec
    }

    // --- Фон ---
    Rectangle {
        anchors.fill: parent
        color: "#121212"
    }

    // --- Индикатор уровня сигнала (волна) ---
    Item {
        id: signalWave
        anchors { centerIn: parent; width: parent.width * 0.8; height: parent.height * 0.3 }
        visible: SpeechRecognizer.recording

        Repeater {
            model: 20
            Rectangle {
                id: bar
                width: parent.width / 25
                height: (Math.random() * 0.8 + 0.2) * signalWave.height
                anchors.bottom: parent.bottom
                x: index * (parent.width / 20) + (parent.width / 40 - width/2)
                color: SpeechRecognizer.level < 0.7 ? "#FF6B6B" : "#FF0000"
                opacity: 0.8
                Behavior on height { NumberAnimation { duration: 100 } }
            }
        }
    }

    // --- Длительность ---
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: signalWave.bottom
        anchors.topMargin: Theme.paddingLarge
        text: formatTime(SpeechRecognizer.durationSec)
        color: SpeechRecognizer.recording ? "#FF6B6B" : "white"
        font.pixelSize: Theme.fontSizeExtraLarge
        font.weight: Font.Light
        visible: SpeechRecognizer.recording
    }

    // --- Кнопки управления ---
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingLarge

        // Отмена
        Rectangle {
            width: Theme.itemSizeLarge
            height: Theme.itemSizeLarge
            radius: width / 2
            color: "#FF6B6B"
            visible: SpeechRecognizer.recording || SpeechRecognizer.finalizing
            IconButton {
                anchors.centerIn: parent
                icon.source: "image://theme/icon-m-cancel"
                icon.color: "white"
                width: parent.width
                height: parent.height
                onClicked: SpeechRecognizer.cancel()
            }
        }

        // Пауза / Возобновить
        Rectangle {
            width: Theme.itemSizeLarge
            height: Theme.itemSizeLarge
            radius: width / 2
            color: Theme.highlightColor
            opacity: (SpeechRecognizer.recording && !SpeechRecognizer.finalizing) ? 1 : 0.3
            visible: SpeechRecognizer.recording
            IconButton {
                anchors.centerIn: parent
                icon.source: SpeechRecognizer.paused ? "image://theme/icon-m-play" : "image://theme/icon-m-pause"
                icon.color: "white"
                width: parent.width
                height: parent.height
                enabled: SpeechRecognizer.recording && !SpeechRecognizer.finalizing
                onClicked: {
                    if (SpeechRecognizer.paused)
                        SpeechRecognizer.resume()
                    else
                        SpeechRecognizer.pause()
                }
            }
        }

        // Старт / Стоп
        Rectangle {
            width: Theme.itemSizeLarge
            height: Theme.itemSizeLarge
            radius: width / 2
            color: SpeechRecognizer.recording ? "#FF0000" : "#FF6B6B"
            opacity: (SpeechRecognizer.modelReady && !SpeechRecognizer.finalizing) ? 1 : 0.4
            visible: !SpeechRecognizer.finalizing
            IconButton {
                anchors.centerIn: parent
                icon.source: SpeechRecognizer.recording ? "image://theme/icon-m-stop" : "image://theme/icon-m-mic"
                icon.color: "white"
                width: parent.width
                height: parent.height
                enabled: SpeechRecognizer.modelReady && !SpeechRecognizer.finalizing
                onClicked: {
                    if (SpeechRecognizer.recording)
                        SpeechRecognizer.stop()
                    else
                        SpeechRecognizer.start()
                }
            }
        }
    }

    // --- Живая расшифровка ---
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.top; top: parent.top }
        anchors.margins: Theme.paddingLarge
        color: "#1E1E1E"
        radius: 8
        visible: SpeechRecognizer.recording || SpeechRecognizer.finalizing
        height: liveColumn.height + Theme.paddingMedium * 2

        Column {
            id: liveColumn
            anchors { fill: parent; margins: Theme.paddingMedium }
            spacing: Theme.paddingSmall
            Label {
                width: parent.width
                text: SpeechRecognizer.finalizing ? qsTr("Завершаем расшифровку...") : qsTr("Распознавание речи...")
                color: "#888"
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
            }
            ProgressBar {
                width: parent.width
                indeterminate: true
                visible: SpeechRecognizer.finalizing
                height: Theme.paddingSmall
            }
            Label {
                width: parent.width
                text: {
                    var acc = SpeechRecognizer.fullText
                    var part = SpeechRecognizer.partialText
                    if (part.length > 0)
                        return (acc.length > 0 ? acc + " " : "") + part
                    return acc
                }
                color: "white"
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                visible: text.length > 0
            }
        }
    }

    // --- Статус при ошибке ---
    Notification {
        id: statusNotification
        visible: false
        // Вместо Nemo.Notifications используем собственный баннер
        // Можно добавить Rectangle, но пока оставим заглушку
    }

    Connections {
        target: SpeechRecognizer
        onErrorOccurred: {
            // Показать ошибку (можно через баннер)
            console.log("Error: " + message)
        }
    }
}