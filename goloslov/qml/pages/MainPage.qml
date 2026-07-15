import QtQuick 2.0
import Sailfish.Silica 1.0
import ru.omstu.goloslov 1.0
import QtGraphicalEffects 1.0
import "../Database.js" as Db

Page {
    id: mainPage
    objectName: "mainPage"
    allowedOrientations: Orientation.All

    property bool modelLoaded: false
    property bool isRecording: SpeechRecognizer.recording

    // --- Multi-selection state ---
    property bool selectionMode: false
    property var selectedIds: []
    property bool allSelected: false

    function isSelected(noteId) {
        return selectedIds.indexOf(noteId) >= 0
    }

    function toggleSelection(noteId) {
        if (isSelected(noteId)) {
            selectedIds = selectedIds.filter(function(id) { return id !== noteId })
        } else {
            selectedIds.push(noteId)
        }
        selectedIdsChanged()
        allSelected = selectedIds.length === filteredModel.count
    }

    function enterSelectionMode(noteId) {
        selectionMode = true
        selectedIds = [noteId]
        allSelected = false
        selectedIdsChanged()
    }

    function exitSelectionMode() {
        selectionMode = false
        selectedIds = []
        allSelected = false
        selectedIdsChanged()
    }

    function selectAll() {
        if (allSelected) {
            selectedIds = []
            allSelected = false
        } else {
            selectedIds = []
            for (var i = 0; i < filteredModel.count; i++) {
                selectedIds.push(filteredModel.get(i).noteId)
            }
            allSelected = true
        }
        selectedIdsChanged()
    }

    function deleteSelected() {
        if (selectedIds.length === 0) return
        remorseDelete.execute(notesListView, qsTr("Удаление записей"), function() {
            Db.deleteNotes(selectedIds)
            exitSelectionMode()
            reloadNotes()
        })
    }

    function renameSelected() {
        if (selectedIds.length !== 1) return
        var noteId = selectedIds[0]
        for (var j = 0; j < filteredModel.count; j++) {
            var note = filteredModel.get(j)
            if (note.noteId === noteId) {
                renameDialogComponent.createObject(mainPage, { "noteId": noteId }).open()
                return
            }
        }
    }

    ListModel { id: notesModel }
    ListModel { id: filteredModel }

    function filterNotes(query) {
        filteredModel.clear()
        if (query === "") {
            for (var i = 0; i < notesModel.count; i++) {
                filteredModel.append(notesModel.get(i))
            }
        } else {
            var lowerQuery = query.toLowerCase()
            for (var j = 0; j < notesModel.count; j++) {
                var note = notesModel.get(j)
                if (note.title.toLowerCase().indexOf(lowerQuery) !== -1 ||
                    note.text.toLowerCase().indexOf(lowerQuery) !== -1) {
                    filteredModel.append(note)
                }
            }
        }
    }

    function reloadNotes() {
        // Возвращаем сортировку по умолчанию, так как Database.js её ожидает
        Db.loadNotes(notesModel, "date", "desc")
        filterNotes(searchField.text)
    }

    Component.onCompleted: {
        modelLoaded = true
        reloadNotes()
        appWindow.mainPage = mainPage
    }

    onStatusChanged: {
        if (status === PageStatus.Active) reloadNotes()
    }

    Connections {
        target: SpeechRecognizer
        onFinished: reloadNotes()
    }

    // --- Rename dialog component (исправлен дубликат id) ---
    Component {
        id: renameDialogComponent
        Dialog {
            property int noteId: -1
            Column {
                width: parent.width
                spacing: Theme.paddingMedium
                DialogHeader { title: qsTr("Переименовать запись") }
                TextField {
                    id: nameField
                    width: parent.width
                    placeholderText: qsTr("Название записи")
                }
            }
            onAccepted: {
                if (nameField.text.trim().length > 0 && noteId >= 0) {
                    Db.updateNoteTitle(noteId, nameField.text.trim())
                    exitSelectionMode()
                    reloadNotes()
                }
            }
        }
    }

    // --- Заголовок с градиентом ---
    Rectangle {
        id: normalHeader
        anchors {top: parent.top; left: parent.left; right: parent.right;}
        height: Theme.itemSizeSmall
        visible: !selectionMode
        z: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FFB300" }
            GradientStop { position: 1.0; color: "#FF8F00" }
        }

        IconButton {
            objectName: "aboutButton"
            anchors { right: parent.right; rightMargin: Theme.paddingMedium; verticalCenter: parent.verticalCenter }
            icon.source: "image://theme/icon-m-about"
            // icon.color удален, используется дефолтный белый для хедера
            onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
        }
    }

    // --- Режим множественного выбора ---
    Rectangle {
        id: selectionHeader
        anchors { top: parent.top; topMargin: Theme.paddingSmall ; left: parent.left; right: parent.right }
        height: Theme.itemSizeMedium
        visible: selectionMode
        z: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FFB300" }
            GradientStop { position: 1.0; color: "#FF8F00" }
        }

        IconButton {
            id: exitSelectionButton
            anchors { left: parent.left; leftMargin: Theme.paddingMedium; verticalCenter: parent.verticalCenter }
            icon.source: "image://theme/icon-m-close"
            onClicked: exitSelectionMode()
        }

        Label {
            id: selectionLabel
            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            text: qsTr("Выбрано: %1").arg(selectedIds.length)
            color: "white"
            font.pixelSize: Theme.fontSizeSmall
        }

        Item {
            id: selectAllButton
            anchors { right: parent.right; rightMargin: Theme.paddingMedium; verticalCenter: parent.verticalCenter }
            width: Theme.iconSizeMedium
            height: Theme.iconSizeMedium

            Rectangle {
                anchors.fill: parent
                anchors.margins: 12
                radius: width / 2
                color: "transparent"
                border.color: "white"
                border.width: 3
                visible: !allSelected
            }

            Image {
                anchors.fill: parent
                source: "image://theme/icon-m-acknowledge"
                visible: allSelected
            }

            MouseArea {
                anchors.fill: parent
                onClicked: selectAll()
            }
        }
    }

    // --- Основной контент ---
    SilicaFlickable {
        id: flickable
        anchors {
            top: normalHeader.visible ? normalHeader.bottom : selectionHeader.bottom
            left: parent.left
            right: parent.right
            bottom: bottomBar.visible ? bottomBar.top : parent.bottom
        }
        clip: true
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            // Индикатор загрузки модели
            Item {
                width: parent.width
                height: modelLoaded ? 0 : modelLoadingColumn.height + Theme.paddingMedium
                visible: !modelLoaded
                clip: true
                Behavior on height { NumberAnimation { duration: 300 } }
                Column {
                    id: modelLoadingColumn
                    width: parent.width - 2 * Theme.horizontalPageMargin
                    anchors.horizontalCenter: parent.horizontalCenter
                    Item { width: 1; height: Theme.paddingSmall }
                    Label {
                        width: parent.width
                        text: qsTr("Загрузка модели распознавания речи...")
                        color: Theme.secondaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    Item { width: 1; height: Theme.paddingSmall }
                    ProgressBar {
                        id: modelProgressBar
                        width: parent.width
                        indeterminate: true
                        visible: !modelLoaded
                    }
                }
            }

            // Индикатор активной записи
            Item {
                width: parent.width
                height: isRecording ? recordingBar.height + Theme.paddingSmall : 0
                visible: isRecording
                clip: true
                Behavior on height { NumberAnimation { duration: 200 } }
                Rectangle {
                    id: recordingBar
                    width: parent.width; height: Theme.itemSizeSmall
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#FFB300" }
                        GradientStop { position: 1.0; color: "#FF8F00" }
                    }
                    Row {
                        anchors.centerIn: parent; spacing: Theme.paddingMedium
                        Rectangle {
                            id: recordingDot
                            width: Theme.paddingSmall; height: Theme.paddingSmall
                            radius: width / 2; color: "white"
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                PropertyAnimation { to: 0.3; duration: 600 }
                                PropertyAnimation { to: 1.0; duration: 600 }
                            }
                        }
                        Label {
                            text: qsTr("Идёт запись...")
                            color: "white"
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: pageStack.push(Qt.resolvedUrl("RecordingPage.qml"))
                    }
                }
            }

            // Поле поиска (замена SearchField на TextField)
            TextField {
                id: searchField
                width: parent.width
                placeholderText: qsTr("Поиск по записям...")
                visible: false
                onTextChanged: filterNotes(text)
                // Убран color: Theme.primaryColor, чтобы работала тема Silica
            }

            SilicaListView {
                id: notesListView
                width: parent.width
                height: Math.max(mainPage.height - column.y - Theme.paddingLarge, emptyLabel.height + Theme.paddingLarge)
                model: filteredModel
                delegate: noteDelegate
                spacing: 0
                header: headerComponent

                PullDownMenu {
                    MenuItem {
                        text: qsTr("О программе")
                        onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                    }
                    MenuItem {
                        text: searchField.visible ? qsTr("Скрыть поиск") : qsTr("Поиск")
                        onClicked: searchField.visible = !searchField.visible
                    }
                }
                ViewPlaceholder {
                    enabled: filteredModel.count === 0
                    text: qsTr("Нет записей")
                    hintText: qsTr("Нажмите на микрофон, чтобы начать запись")
                }
            }
        }
        VerticalScrollDecorator {}
    }

    // Нижняя панель действий
    Rectangle {
        id: bottomBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: Theme.itemSizeMedium
        color: "transparent"
        visible: selectionMode
        z: 10

        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 1
            color: Theme.secondaryColor
            opacity: 0.3
        }

        Row {
            anchors { fill: parent; leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium }
            spacing: Theme.paddingMedium

            IconButton {
                id: renameButton
                anchors.verticalCenter: parent.verticalCenter
                icon.source: "image://theme/icon-m-edit"
                enabled: selectedIds.length === 1
                opacity: enabled ? 1.0 : 0.4
                onClicked: renameSelected()
            }

            IconButton {
                id: deleteButton
                anchors.verticalCenter: parent.verticalCenter
                icon.source: "image://theme/icon-m-delete"
                enabled: selectedIds.length > 0
                opacity: enabled ? 1.0 : 0.4
                onClicked: deleteSelected()
            }

            Item { width: 1; height: 1 }
        }
    }

    RemorseItem { id: remorseDelete }

    Component {
        id: headerComponent
        Item { width: parent.width; height: Theme.paddingSmall }
    }

    Component {
        id: noteDelegate
        BackgroundItem {
            id: delegateItem
            width: parent.width
            height: noteColumn.height + 2 * Theme.paddingMedium
            RemorseItem { id: remorse }

            Item {
                id: checkBox
                anchors {
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium

                Image {
                    anchors.fill: parent
                    source: "image://theme/icon-m-play"
                    visible: !mainPage.selectionMode
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 12
                    radius: width / 2
                    color: "transparent"
                    border.color: Theme.secondaryColor
                    border.width: 3
                    visible: mainPage.selectionMode && !isSelected(noteId)
                }

                Image {
                    anchors.fill: parent
                    source: "image://theme/icon-m-acknowledge"
                    visible: mainPage.selectionMode && isSelected(noteId)
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (mainPage.selectionMode) {
                            mainPage.toggleSelection(noteId)
                        } else {
                            // Воспроизведение можно добавить позже
                        }
                    }
                }
            }

            Column {
                id: noteColumn
                x: Theme.horizontalPageMargin
                y: Theme.paddingMedium
                width: parent.width - 2 * Theme.horizontalPageMargin - Theme.iconSizeMedium - Theme.paddingMedium

                Label {
                    width: parent.width
                    text: title
                    color: delegateItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    font.pixelSize: Theme.fontSizeMedium
                    truncationMode: TruncationMode.Fade
                }
                Item { width: 1; height: Theme.paddingSmall }
                Row {
                    width: parent.width; spacing: Theme.paddingMedium
                    Label { text: date; color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall }
                    Label { text: duration; color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeExtraSmall }
                }
                Item { width: 1; height: Theme.paddingSmall }
                Label {
                    width: parent.width; text: preview
                    color: Theme.secondaryColor; font.pixelSize: Theme.fontSizeSmall
                    maximumLineCount: 2; truncationMode: TruncationMode.Elide; wrapMode: Text.WordWrap
                }
            }

            onClicked: {
                if (mainPage.selectionMode) {
                    mainPage.toggleSelection(noteId)
                } else {
                    pageStack.push(Qt.resolvedUrl("NoteViewPage.qml"), {
                        noteId: noteId, noteTitle: title, noteDate: date,
                        noteText: text, noteDuration: duration, noteAudio: audio
                    })
                }
            }

            onPressAndHold: {
                if (!mainPage.selectionMode) mainPage.enterSelectionMode(noteId)
            }
        }
    }

    Label { id: emptyLabel; visible: false }

    // Плавающая кнопка записи
    Rectangle {
        id: recordButton
        anchors {
            right: parent.right; bottom: parent.bottom
            rightMargin: Theme.paddingLarge; bottomMargin: Theme.paddingLarge
        }
        width: Theme.itemSizeLarge; height: Theme.itemSizeLarge
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FFB300" }
            GradientStop { position: 1.0; color: "#FF8F00" }
        }
        visible: !selectionMode

        // Исправление: добавлен импорт QtGraphicalEffects в начало файла
        // и корректное использование DropShadow
        layer.enabled: true
        layer.effect: DropShadow {
            color: "#80000000"
            radius: 8
            samples: 12
            horizontalOffset: 2
            verticalOffset: 4
        }

        IconButton {
            anchors.centerIn: parent
            icon.source: "image://theme/icon-m-mic"
            icon.width: Theme.iconSizeMedium
            icon.height: Theme.iconSizeMedium
            width: parent.width
            height: parent.height
            onClicked: pageStack.push(Qt.resolvedUrl("RecordingPage.qml"))
        }
    }
}