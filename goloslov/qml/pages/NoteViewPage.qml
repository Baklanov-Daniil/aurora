import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import ru.omstu.goloslov 1.0
import "../Database.js" as Db

Page {
    id: noteViewPage
    objectName: "noteViewPage"
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
                customBanner.show(qsTr("Текст сохранён: %1").arg(fullPath))
            } else {
                customBanner.show(qsTr("Не удалось сохранить файл"))
            }
        } catch (e) {
            customBanner.show(qsTr("Не удалось сохранить файл"))
        }
    }

    function copyToClipboard() {
        Clipboard.text = noteText
        customBanner.show(qsTr("Текст скопирован в буфер обмена"))
    }

    Audio {
        id: audioPlayer
        source: noteAudio
        autoLoad: true
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
            bannerTimer.interval = duration || 2500
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

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Удалить заметку")
                onClicked: {
                    remorse.execute(qsTr("Удаление заметки"), function() {
                        if (noteId >= 0) Db.deleteNote(noteId)
                        pageStack.pop()
                    })
                }
            }
            MenuItem {
                text: qsTr("Экспортировать текст в файл")
                onClicked: exportToFile()
            }
            MenuItem {
                text: qsTr("Копировать текст")
                onClicked: copyToClipboard()
            }
        }

        RemorsePopup { id: remorse }

        Column {
            id: column
            width: parent.width

            PageHeader { title: qsTr("Заметка") }

            Label {
                id: titleLabel
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: noteTitle
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
            }

            Item { width: 1; height: Theme.paddingSmall }

            Row {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Label {
                    text: noteDate
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }

                Label {
                    text: noteDuration
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeExtraSmall
                }
            }

            Item { width: 1; height: Theme.paddingMedium }

            SectionHeader { text: qsTr("Аудиозапись") }

            Item {
                width: parent.width - 2 * Theme.horizontalPageMargin
                x: Theme.horizontalPageMargin
                height: audioPlayerColumn.height

                Column {
                    id: audioPlayerColumn
                    width: parent.width

                    Row {
                        width: parent.width
                        spacing: Theme.paddingMedium

                        IconButton {
                            id: playButton
                            icon.source: audioPlayer.playbackState === Audio.PlayingState
                                          ? "image://theme/icon-m-pause"
                                          : "image://theme/icon-m-play"
                            icon.width: Theme.iconSizeMedium
                            icon.height: Theme.iconSizeMedium
                            width: Theme.itemSizeSmall
                            height: Theme.itemSizeSmall
                            icon.color: Theme.highlightColor
                            enabled: noteAudio !== ""
                            onClicked: {
                                if (audioPlayer.playbackState === Audio.PlayingState)
                                    audioPlayer.pause()
                                else
                                    audioPlayer.play()
                            }
                        }

                        Item {
                            width: parent.width - playButton.width - Theme.paddingMedium
                            height: Theme.itemSizeSmall

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
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.paddingMedium

                        Label {
                            text: formatTime(audioPlayer.position / 1000)
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }

                        Item { width: 1; height: 1 }

                        Label {
                            text: audioPlayer.duration > 0
                                  ? formatTime(audioPlayer.duration / 1000)
                                  : noteDuration
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }
            }

            Item { width: 1; height: Theme.paddingMedium }

            SectionHeader { text: qsTr("Расшифровка") }

            TextArea {
                id: transcriptionText
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                text: noteText
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                readOnly: true
            }

            Item { width: 1; height: Theme.paddingLarge }

            SectionHeader { text: qsTr("Экспорт") }

            Column {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Button {
                    width: parent.width
                    text: qsTr("Копировать текст в буфер")
                    onClicked: copyToClipboard()
                    color: Theme.highlightColor
                }

                Button {
                    width: parent.width
                    text: qsTr("Сохранить текст в файл")
                    onClicked: exportToFile()
                    color: Theme.highlightColor
                }
            }

            Item { width: 1; height: Theme.paddingLarge }
        }

        VerticalScrollDecorator {}
    }

    Component.onDestruction: audioPlayer.stop()
}