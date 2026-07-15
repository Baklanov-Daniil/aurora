import QtQuick 2.0
import QtMultimedia 5.6
import ru.omstu.goloslov 1.0
import "../Database.js" as Db

Page {
    id: noteViewPage
    allowedOrientations: Orientation.All

    property int noteId: -1
    property string noteTitle: ""
    property string noteDate: ""
    property string noteText: ""
    property string noteDuration: ""
    property string noteAudio: ""

    function formatTime(seconds) {
        var s = Math.floor(seconds)
        var min = Math.floor(s / 60)
        var sec = s % 60
        return (min < 10 ? "0" : "") + min + ":" + (sec < 10 ? "0" : "") + sec
    }

    function sanitizeFileName(name) {
        var clean = name.replace(/[^0-9A-Za-zА-Яа-яЁё _-]/g, "_")
        if (clean.length === 0) clean = "note"
        return clean
    }

    function exportToFile() {
        try {
            var dir = StandardPaths.documents
            var path = dir.toString().replace(/^file:\/\//, "")
            var fileName = sanitizeFileName(noteTitle) + ".txt"
            var fullPath = path + "/" + fileName
            var content = noteTitle + "\n" + noteDate + "\n\n" + noteText
            var ok = SpeechRecognizer.saveTextToFile("file://" + fullPath, content)
            if (ok) {
                bannerText = qsTr("Текст сохранён: %1").arg(fullPath)
                bannerVisible = true
            } else {
                bannerText = qsTr("Не удалось сохранить файл")
                bannerVisible = true
            }
        } catch (e) {
            bannerText = qsTr("Не удалось сохранить файл")
            bannerVisible = true
        }
        dismissTimer.start()
    }

    function copyToClipboard() {
        Clipboard.text = noteText
        bannerText = qsTr("Текст скопирован в буфер обмена")
        bannerVisible = true
        dismissTimer.start()
    }

    Audio {
        id: audioPlayer
        source: noteAudio
        autoLoad: true
    }

    // --- Фон ---
    Rectangle {
        anchors.fill: parent
        color: "#121212"
    }

    // --- Заголовок с кнопками действий ---
    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: Theme.itemSizeLarge + Theme.paddingLarge
        color: "#1E1E1E"
        z: 10

        Row {
            anchors { fill: parent; margins: Theme.paddingMedium }
            spacing: Theme.paddingMedium

            IconButton {
                icon.source: "image://theme/icon-m-back"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: pageStack.pop()
            }

            Label {
                text: qsTr("Заметка")
                color: "white"
                font.pixelSize: Theme.fontSizeMedium
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 4 * Theme.iconSizeMedium - 3 * Theme.paddingMedium
                elide: Text.ElideRight
            }

            IconButton {
                icon.source: "image://theme/icon-m-share"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: exportToFile()
            }

            IconButton {
                icon.source: "image://theme/icon-m-copy"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: copyToClipboard()
            }

            IconButton {
                icon.source: "image://theme/icon-m-delete"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    remorse.execute(qsTr("Удаление заметки"), function() {
                        if (noteId >= 0) Db.deleteNote(noteId)
                        pageStack.pop()
                    })
                }
            }
        }
    }

    // --- Контент ---
    SilicaFlickable {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium
            padding: Theme.paddingMedium

            // Заголовок
            Label {
                width: parent.width - 2 * Theme.paddingMedium
                x: Theme.paddingMedium
                text: noteTitle
                color: "white"
                font.pixelSize: Theme.fontSizeExtraLarge
                font.bold: true
                wrapMode: Text.WordWrap
            }

            // Дата и длительность
            Row {
                x: Theme.paddingMedium
                width: parent.width - 2 * Theme.paddingMedium
                spacing: Theme.paddingMedium
                Label { text: noteDate; color: "#888"; font.pixelSize: Theme.fontSizeSmall }
                Label { text: noteDuration; color: "#888"; font.pixelSize: Theme.fontSizeSmall }
            }

            // Аудиоплеер (если есть)
            Item {
                width: parent.width - 2 * Theme.paddingMedium
                x: Theme.paddingMedium
                height: noteAudio !== "" ? playerBackground.height : 0
                visible: noteAudio !== ""

                Rectangle {
                    id: playerBackground
                    width: parent.width
                    height: playerControls.height + Theme.paddingMedium * 2
                    color: "#1E1E1E"
                    radius: 8
                    Row {
                        id: playerControls
                        anchors { fill: parent; margins: Theme.paddingMedium }
                        spacing: Theme.paddingMedium
                        IconButton {
                            icon.source: audioPlayer.playbackState === Audio.PlayingState
                                          ? "image://theme/icon-m-pause"
                                          : "image://theme/icon-m-play"
                            icon.color: "white"
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: {
                                if (audioPlayer.playbackState === Audio.PlayingState)
                                    audioPlayer.pause()
                                else
                                    audioPlayer.play()
                            }
                        }
                        Item {
                            width: parent.width - playButton.width - timeLabel.width - 2 * Theme.paddingMedium
                            height: Theme.itemSizeSmall
                            anchors.verticalCenter: parent.verticalCenter
                            Slider {
                                id: playbackSlider
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                minimumValue: 0
                                maximumValue: audioPlayer.duration > 0 ? audioPlayer.duration : 1
                                stepSize: 1
                                enabled: audioPlayer.seekable
                                onDownChanged: {
                                    if (!down) audioPlayer.seek(value)
                                }
                            }
                            Binding {
                                target: playbackSlider
                                property: "value"
                                value: audioPlayer.position
                                when: !playbackSlider.down
                            }
                        }
                        Label {
                            id: timeLabel
                            anchors.verticalCenter: parent.verticalCenter
                            text: formatTime(audioPlayer.position / 1000)
                            color: "#888"
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }
            }

            // Текст расшифровки
            Label {
                width: parent.width - 2 * Theme.paddingMedium
                x: Theme.paddingMedium
                text: noteText
                color: "#DDD"
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.WordWrap
                visible: noteText !== ""
            }
        }

        VerticalScrollDecorator {}
    }

    // --- Баннер уведомлений ---
    Rectangle {
        id: banner
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: Theme.itemSizeMedium
        color: "#FF6B6B"
        visible: false
        z: 100

        Label {
            id: bannerLabel
            anchors.centerIn: parent
            text: bannerText
            color: "white"
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    property string bannerText: ""
    property bool bannerVisible: false
    Timer {
        id: dismissTimer
        interval: 3000
        onTriggered: banner.visible = false
    }

    onBannerVisibleChanged: {
        banner.visible = bannerVisible
    }

    RemorsePopup { id: remorse }

    Component.onDestruction: audioPlayer.stop()
}