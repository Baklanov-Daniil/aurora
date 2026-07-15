import QtQuick 2.0
import Sailfish.Silica 1.0
import ru.omstu.goloslov 1.0
import "../Database.js" as Db

Page {
    id: recordingPage
    objectName: "recordingPage"
    allowedOrientations: Orientation.All

    property int recordDuration: 0

    function formatTime(seconds) {
        var s = Math.floor(seconds)
        var min = Math.floor(s / 60)
        var sec = s % 60
        return (min < 10 ? "0" : "") + min + ":" + (sec < 10 ? "0" : "") + sec
    }

    Rectangle {
        id: customBanner
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: Theme.itemSizeSmall
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FFB300" }
            GradientStop { position: 1.0; color: "#FF8F00" }
        }
        opacity: 0
        visible: false
        z: 100

        Label {
            id: bannerLabel
            anchors.centerIn: parent
            text: ""
            color: "white"
            font.pixelSize: Theme.fontSizeSmall
        }

        Behavior on opacity { NumberAnimation { duration: 300 } }

        function show(text, duration) {
            bannerLabel.text = text
            visible = true
            opacity = 1
            if (bannerTimer.running) bannerTimer.stop()
            bannerTimer.interval = duration || 3000
            bannerTimer.start()
        }

        Timer {
            id: bannerTimer
            onTriggered: {
                customBanner.opacity = 0
                customBanner.visible = false
            }
        }
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
            customBanner.show(message)
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: SpeechRecognizer.recording ? qsTr("Запись") :
                       SpeechRecognizer.finalizing ? qsTr("Расшифровка") :
                       SpeechRecognizer.loading ? qsTr("Загрузка модели") :
                       qsTr("Готов к записи")
            }

            // Уровень сигнала (жёлто-оранжевый)
            Item {
                width: parent.width
                height: Theme.itemSizeExtraLarge * 2
                visible: SpeechRecognizer.recording

                Rectangle {
                    anchors.centerIn: parent
                    width: Theme.itemSizeExtraLarge * 1.5
                    height: Theme.itemSizeExtraLarge * 1.5
                    radius: width / 2
                    color: Qt.rgba(1, 0.7, 0, 0.1)
                    border.color: "#FFB300"
                    border.width: 2
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: Theme.itemSizeMedium + SpeechRecognizer.level * Theme.itemSizeLarge
                    height: Theme.itemSizeMedium + SpeechRecognizer.level * Theme.itemSizeLarge
                    radius: width / 2
                    color: SpeechRecognizer.level < 0.7 ? "#FFB300" : "#FF8F00"
                    opacity: 0.3 + SpeechRecognizer.level * 0.5
                }

                Label {
                    anchors.centerIn: parent
                    text: qsTr("MIC")
                    color: "#FFB300"
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.Bold
                }
            }

            // Длительность
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: formatTime(SpeechRecognizer.durationSec)
                color: SpeechRecognizer.recording ? "#FFB300" : Theme.primaryColor
                font.pixelSize: Theme.fontSizeExtraLarge
                font.weight: Font.Light
                visible: SpeechRecognizer.recording
            }

            Item { width: 1; height: Theme.paddingLarge }

            // Кнопки управления (жёлто-оранжевые)
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge

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
                        icon.color: "white"
                        width: parent.width
                        height: parent.height
                        onClicked: SpeechRecognizer.cancel()
                    }
                }

                Rectangle {
                    width: Theme.itemSizeExtraLarge * 1.2
                    height: Theme.itemSizeExtraLarge * 1.2
                    radius: width / 2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#FFB300" }
                        GradientStop { position: 1.0; color: "#FF8F00" }
                    }
                    opacity: (SpeechRecognizer.recording && !SpeechRecognizer.finalizing) ? 0.8 : 0.3
                    visible: SpeechRecognizer.recording

                    IconButton {
                        anchors.centerIn: parent
                        icon.source: SpeechRecognizer.paused ? "image://theme/icon-m-play"
                                                             : "image://theme/icon-m-pause"
                        icon.width: Theme.iconSizeLarge
                        icon.height: Theme.iconSizeLarge
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

                Component {
                    id: recordingGradient
                    Gradient {
                        GradientStop { position: 0.0; color: "#FF5722" }
                        GradientStop { position: 1.0; color: "#E64A19" }
                    }
                }

                Component {
                    id: readyGradient
                    Gradient {
                        GradientStop { position: 0.0; color: "#FFB300" }
                        GradientStop { position: 1.0; color: "#FF8F00" }
                    }
                }

                // В самом Rectangle используйте привязку через Loader или просто меняйте gradient
                Rectangle {
                    width: Theme.itemSizeExtraLarge * 1.2
                    height: Theme.itemSizeExtraLarge * 1.2
                    radius: width / 2

                    // Привязываем gradient к нужному компоненту
                    gradient: SpeechRecognizer.recording ? recordingGradient.createObject(parent)
                                                         : readyGradient.createObject(parent)

                    opacity: (SpeechRecognizer.modelReady && !SpeechRecognizer.finalizing) ? 1.0 : 0.4
                    visible: !SpeechRecognizer.finalizing

                    IconButton {
                        anchors.centerIn: parent
                        icon.source: SpeechRecognizer.recording ? "image://theme/icon-m-stop"
                                                               : "image://theme/icon-m-mic"
                        icon.width: Theme.iconSizeLarge
                        icon.height: Theme.iconSizeLarge
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

            // Индикатор загрузки модели
            Item {
                width: parent.width
                height: Theme.itemSizeExtraLarge
                visible: SpeechRecognizer.loading

                BusyIndicator {
                    anchors.centerIn: parent
                    running: SpeechRecognizer.loading
                    size: BusyIndicatorSize.Medium
                    color: "#FFB300"
                }
            }

            Item { width: 1; height: Theme.paddingLarge }

            // Живая расшифровка
            Item {
                width: parent.width - 2 * Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                height: liveColumn.height
                visible: SpeechRecognizer.recording || SpeechRecognizer.finalizing

                Column {
                    id: liveColumn
                    width: parent.width

                    Label {
                        width: parent.width
                        text: SpeechRecognizer.finalizing ? qsTr("Завершаем расшифровку...")
                                                    : qsTr("Распознавание речи...")
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item { width: 1; height: Theme.paddingSmall }

                    ProgressBar {
                        width: parent.width
                        indeterminate: true
                        visible: SpeechRecognizer.finalizing
                    }

                    Item { width: 1; height: Theme.paddingSmall }

                    Label {
                        width: parent.width
                        text: {
                            var acc = SpeechRecognizer.fullText
                            var part = SpeechRecognizer.partialText
                            if (part.length > 0)
                                return (acc.length > 0 ? acc + " " : "") + part
                            return acc
                        }
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        visible: text.length > 0
                    }
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: {
                    if (SpeechRecognizer.loading) return qsTr("Загрузка модели распознавания...")
                    if (!SpeechRecognizer.modelReady) return qsTr("Модель распознавания недоступна")
                    if (SpeechRecognizer.finalizing) return qsTr("Ожидайте завершения расшифровки")
                    return qsTr("Нажмите на микрофон, чтобы начать запись")
                }
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                visible: !SpeechRecognizer.recording
            }
        }

        VerticalScrollDecorator {}
    }
}