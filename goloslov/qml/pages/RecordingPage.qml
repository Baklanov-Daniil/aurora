import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0
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

    Connections {
        target: SpeechRecognizer
        onFinished: {
            var clean = text ? text.trim() : ""
            pageStack.replace(Qt.resolvedUrl("NoteViewPage.qml"), {
                noteId: appWindow.lastNoteId,
                noteTitle: qsTr("Запись от %1").arg(Qt.formatDateTime(new Date(), "dd.MM.yyyy hh:mm")),
                noteDate: Qt.formatDateTime(new Date(), "dd.MM.yyyy hh:mm"),
                noteText: clean,
                noteDuration: formatTime(durationSec),
                noteAudio: audioPath
            })
        }
        onErrorOccurred: {
            statusNotification.previewBody = message
            statusNotification.publish()
        }
    }

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

            IconButton {
                icon.source: "image://theme/icon-m-back"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: pageStack.pop()
            }

            Item { width: 1; height: 1; }

            Label {
                text: qsTr("Запись")
                color: "#FFB300"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // --- ПУЛЬСИРУЮЩИЙ КРУГ (Индикатор уровня шума) ---
    Item {
        id: audioIndicator
        anchors {
            top: header.bottom
            topMargin: Theme.paddingLarge * 2
            horizontalCenter: parent.horizontalCenter
        }
        width: Theme.itemSizeExtraLarge * 2
        height: width
        visible: SpeechRecognizer.recording

        // Фоновый круг (трек)
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Qt.rgba(1, 0.7, 0, 0.1)
            border.color: "#FFB300"
            border.width: 2
        }

        // Пульсирующий круг (заполнение)
        Rectangle {
            anchors.centerIn: parent
            // Размер меняется от 30% до 80% в зависимости от уровня громкости
            width: parent.width * (0.3 + SpeechRecognizer.level * 0.5)
            height: width
            radius: width / 2
            color: SpeechRecognizer.level < 0.7 ? "#FFB300" : "#FF5722" // Оранжевый -> красноватый на пике
            opacity: 0.4 + SpeechRecognizer.level * 0.6

            // Плавная анимация изменения размера и прозрачности
            Behavior on width {
                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
            }
            Behavior on opacity {
                NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
            }
        }

        Label {
            anchors.centerIn: parent
            text: qsTr("MIC")
            color: "#FFB300"
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
        }
    }

    // --- Длительность записи ---
    Label {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: audioIndicator.bottom
            topMargin: Theme.paddingLarge
        }
        text: formatTime(SpeechRecognizer.durationSec)
        color: SpeechRecognizer.recording ? "#FFB300" : "white"
        font.pixelSize: Theme.fontSizeExtraLarge
        font.weight: Font.Light
        visible: SpeechRecognizer.recording
    }

    // --- Живая расшифровка ---
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: audioIndicator.bottom
            bottom: controlsRow.top
            margins: Theme.paddingLarge
        }
        color: "#1E1E1E"
        radius: 8
        visible: SpeechRecognizer.recording || SpeechRecognizer.finalizing

        Column {
            id: liveColumn
            anchors { fill: parent; margins: Theme.paddingMedium }
            spacing: Theme.paddingSmall

            Label {
                width: parent.width
                text: SpeechRecognizer.finalizing ? qsTr("Завершаем расшифровку...") : qsTr("Распознавание...")
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

    // --- Кнопки управления (Ваш вариант с адаптацией под оранжевую тему) ---
    Row {
        id: controlsRow
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Theme.paddingLarge

        // Отмена
        Rectangle {
            width: Theme.itemSizeExtraLarge * 1.2
            height: Theme.itemSizeExtraLarge * 1.2
            radius: width / 2
            color: Qt.rgba(0.8, 0.2, 0.2, 0.8)
            visible: SpeechRecognizer.recording || SpeechRecognizer.finalizing

            IconButton {
                anchors.centerIn: parent
                icon.source: "image://theme/icon-m-cancel"
                icon.width: Theme.iconSizeLarge
                icon.height: Theme.iconSizeLarge
                width: parent.width
                height: parent.height
                onClicked: SpeechRecognizer.cancel()
            }
        }

        // Пауза
        Rectangle {
            width: Theme.itemSizeExtraLarge * 1.2
            height: Theme.itemSizeExtraLarge * 1.2
            radius: width / 2
            color: "#FFB300"
            opacity: (SpeechRecognizer.recording && !SpeechRecognizer.finalizing) ? 1.0 : 0.3
            visible: SpeechRecognizer.recording

            IconButton {
                anchors.centerIn: parent
                icon.source: SpeechRecognizer.paused ? "image://theme/icon-m-play" : "image://theme/icon-m-pause"
                icon.width: Theme.iconSizeLarge
                icon.height: Theme.iconSizeLarge
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

        // Старт/Стоп (Ваш запрошенный шаблон)
        Rectangle {
            width: Theme.itemSizeExtraLarge * 1.2
            height: Theme.itemSizeExtraLarge * 1.2
            radius: width / 2
            color: SpeechRecognizer.recording ? "#FF5722" : "#FFB300" // Адаптировано под оранжевую тему
            opacity: (SpeechRecognizer.modelReady && !SpeechRecognizer.finalizing) ? 1.0 : 0.4
            visible: !SpeechRecognizer.finalizing

            IconButton {
                anchors.centerIn: parent
                icon.source: SpeechRecognizer.recording ? "image://theme/icon-m-stop" : "image://theme/icon-m-mic"
                icon.width: Theme.iconSizeLarge
                icon.height: Theme.iconSizeLarge
                width: parent.width
                height: parent.height
                enabled: SpeechRecognizer.modelReady && !SpeechRecognizer.finalizing
                onClicked: {
                    if (SpeechRecognizer.recording) {
                        SpeechRecognizer.stop()
                    } else {
                        SpeechRecognizer.start()
                    }
                }
            }
        }
    }

    Notification {
        id: statusNotification
    }
}
