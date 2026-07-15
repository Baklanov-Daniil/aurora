import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.6
import Nemo.Notifications 1.0
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

    property bool renameVisible: false

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
                notificationPanel.previewBody = qsTr("Текст сохранён: %1").arg(fullPath)
            } else {
                notificationPanel.previewBody = qsTr("Не удалось сохранить файл")
            }
            notificationPanel.publish()
        } catch (e) {
            notificationPanel.previewBody = qsTr("Не удалось сохранить файл")
            notificationPanel.publish()
        }
    }

    function copyToClipboard() {
        Clipboard.text = noteText
        notificationPanel.previewBody = qsTr("Текст скопирован в буфер обмена")
        notificationPanel.publish()
    }

    function showRenameField() {
        renameVisible = true
        renameField.text = noteTitle
        renameField.forceActiveFocus()
    }

    function applyRename() {
        var newTitle = renameField.text.trim()
        if (newTitle.length > 0 && noteId >= 0) {
            Db.updateNoteTitle(noteId, newTitle)
            noteTitle = newTitle
            notificationPanel.previewBody = qsTr("Запись переименована")
            notificationPanel.publish()
        }
        renameVisible = false
    }

    function cancelRename() {
        renameVisible = false
    }

    Audio {
        id: audioPlayer
        source: noteAudio
        autoLoad: true
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
                text: qsTr("Заметка")
                color: "#FFB300"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: 1; height: 1; }

            // Кнопка ПЕРЕИМЕНОВАТЬ
            IconButton {
                icon.source: "image://theme/icon-m-edit"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: showRenameField()
            }

            // Кнопка КОПИРОВАТЬ
            IconButton {
                icon.source: "image://theme/icon-m-copy"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: copyToClipboard()
            }

            // Кнопка УДАЛИТЬ
            IconButton {
                icon.source: "image://theme/icon-m-delete"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    remorse.execute(qsTr("Удалить заметку"), function() {
                        if (noteId >= 0) Db.deleteNote(noteId)
                        pageStack.pop()
                    })
                }
            }
        }
    }

    // --- INLINE-поле переименования ---
    Rectangle {
        id: renameBar
        anchors { top: header.bottom; left: parent.left; right: parent.right }
        height: renameVisible ? Theme.itemSizeMedium + Theme.paddingSmall * 2 : 0
        color: "#1E1E1E"
        z: 20
        clip: true

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1
            color: "#FFB300"
            opacity: 0.5
        }

        Row {
            anchors { fill: parent; margins: Theme.paddingSmall }
            spacing: Theme.paddingSmall

            MouseArea {
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                anchors.verticalCenter: parent.verticalCenter
                onClicked: cancelRename()
                Image {
                    anchors.centerIn: parent
                    source: "image://theme/icon-m-cancel"
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                }
            }

            TextField {
                id: renameField
                width: parent.width - Theme.iconSizeMedium * 2 - Theme.paddingSmall * 3
                height: parent.height - Theme.paddingSmall * 2
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: qsTr("Новое название...")
                color: "white"
                font.pixelSize: Theme.fontSizeSmall
                background: null
                Keys.onReturnPressed: applyRename()
                Keys.onEnterPressed: applyRename()
            }

            MouseArea {
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                anchors.verticalCenter: parent.verticalCenter
                enabled: renameField.text.trim().length > 0
                opacity: enabled ? 1.0 : 0.4
                onClicked: applyRename()
                Image {
                    anchors.centerIn: parent
                    source: "image://theme/icon-m-acknowledge"
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                }
            }
        }
    }

    SilicaFlickable {
        anchors {
            top: renameBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            // Заголовок заметки (ИСПРАВЛЕНО ВЫРАВНИВАНИЕ)
            Label {
                width: parent.width - 2 * Theme.paddingMedium
                x: Theme.paddingMedium
                text: noteTitle
                color: "#FFB300"
                font.pixelSize: Theme.fontSizeExtraLarge
                font.bold: true
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter // <-- ЭТО ИСПРАВЛЯЕТ СМЕЩЕНИЕ ВВЕРХ
            }

            Row {
                x: Theme.paddingMedium
                width: parent.width - 2 * Theme.paddingMedium
                spacing: Theme.paddingMedium
                Label { text: noteDate; color: "#888"; font.pixelSize: Theme.fontSizeSmall }
                Label { text: noteDuration; color: "#888"; font.pixelSize: Theme.fontSizeSmall }
            }

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
                            id: playButton
                            icon.source: audioPlayer.playbackState === Audio.PlayingState
                                         ? "image://theme/icon-m-pause"
                                         : "image://theme/icon-m-play"
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

            Label {
                id: transcriptionText
                width: parent.width - 2 * Theme.paddingMedium
                x: Theme.paddingMedium
                text: noteText
                color: "#DDD"
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.WordWrap
                textFormat: Text.PlainText
                visible: noteText !== ""
            }

            Column {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                spacing: Theme.paddingMedium
                visible: noteText !== ""

                Button {
                    width: parent.width
                    text: qsTr("Копировать текст в буфер")
                    onClicked: copyToClipboard()
                }

                Button {
                    width: parent.width
                    text: qsTr("Сохранить текст в файл")
                    onClicked: exportToFile()
                }
            }
        }

        VerticalScrollDecorator {}
    }

    RemorsePopup { id: remorse }

    Notification {
        id: notificationPanel
    }

    Component.onDestruction: audioPlayer.stop()
}
