import QtQuick 2.0
import QtQuick.Controls 1.4  // для ScrollView (можно заменить)
import ru.omstu.goloslov 1.0
import "../Database.js" as Db

Page {
    id: mainPage
    allowedOrientations: Orientation.All

    property bool modelLoaded: false
    property bool isRecording: false
    property string sortField: "date"
    property string sortDir: "desc"

    // --- Мультивыбор ---
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
        // использование RemorsePopup из Silica, но можно заменить на свой
        remorseDelete.execute(notesListView, qsTr("Удаление заметок"), function() {
            Db.deleteNotes(selectedIds)
            exitSelectionMode()
            reloadNotes()
        })
    }

    function renameSelected() {
        if (selectedIds.length !== 1) return
        var noteId = selectedIds[0]
        for (var j = 0; j < notesModel.count; j++) {
            var note = notesModel.get(j)
            if (note.noteId === noteId) {
                var dlg = renameDialogComponent.createObject(mainPage, { "noteId": noteId })
                dlg.nameField.text = note.title
                dlg.open()
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
        Db.loadNotes(notesModel, sortField, sortDir)
        filterNotes(searchField.text)
    }

    function applySort(field) {
        if (sortField === field) {
            sortDir = sortDir === "asc" ? "desc" : "asc"
        } else {
            sortField = field
            sortDir = "desc"
        }
        reloadNotes()
    }

    // --- Диалог переименования ---
    Component {
        id: renameDialogComponent
        Dialog {
            property int noteId: -1
            property alias nameField: nameField
            allowedOrientations: Orientation.All
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

    // --- Фон ---
    Rectangle {
        anchors.fill: parent
        color: "#121212"
    }

    // --- Верхний заголовок ---
    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: Theme.itemSizeLarge + Theme.paddingLarge
        color: "#1E1E1E"
        z: 10

        Row {
            anchors { fill: parent; leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium }
            spacing: Theme.paddingMedium

            Label {
                id: appTitle
                text: qsTr("Голослов")
                color: "#FFFFFF"
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: 1; height: 1; Layout.fillWidth: true }

            // Поиск
            IconButton {
                id: searchButton
                icon.source: "image://theme/icon-m-search"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: searchField.visible = !searchField.visible
            }

            // Сортировка
            IconButton {
                id: sortButton
                icon.source: "image://theme/icon-m-down"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: sortMenu.visible = !sortMenu.visible
            }

            // О программе
            IconButton {
                icon.source: "image://theme/icon-m-about"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }
    }

    // --- Поле поиска (выпадающее) ---
    Rectangle {
        id: searchContainer
        anchors { top: header.bottom; left: parent.left; right: parent.right }
        height: searchField.visible ? Theme.itemSizeMedium + Theme.paddingSmall : 0
        color: "#1E1E1E"
        clip: true
        Behavior on height { NumberAnimation { duration: 200 } }

        TextField {
            id: searchField
            anchors { fill: parent; margins: Theme.paddingSmall }
            placeholderText: qsTr("Поиск по записям...")
            color: "white"
            font.pixelSize: Theme.fontSizeSmall
            visible: true
            onTextChanged: filterNotes(text)
        }
    }

    // --- Список заметок ---
    SilicaFlickable {
        anchors {
            top: searchContainer.bottom
            left: parent.left
            right: parent.right
            bottom: bottomBar.visible ? bottomBar.top : parent.bottom
        }
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            // Индикатор загрузки модели
            Item {
                width: parent.width
                height: modelLoaded ? 0 : busyIndicator.height + Theme.paddingSmall
                visible: !modelLoaded
                clip: true
                Behavior on height { NumberAnimation { duration: 300 } }
                BusyIndicator {
                    id: busyIndicator
                    anchors.centerIn: parent
                    running: !modelLoaded
                    size: BusyIndicatorSize.Small
                }
            }

            // Список (с карточками)
            Repeater {
                model: filteredModel
                delegate: noteDelegate
            }

            // Заглушка при пустом списке
            Item {
                width: parent.width
                height: filteredModel.count === 0 ? parent.height * 0.6 : 0
                visible: filteredModel.count === 0
                Label {
                    anchors.centerIn: parent
                    text: searchField.text.length > 0 ? qsTr("Ничего не найдено") : qsTr("Нет заметок")
                    color: "#888"
                    font.pixelSize: Theme.fontSizeMedium
                }
            }
        }

        VerticalScrollDecorator {}
    }

    // --- Нижняя панель (только в режиме выбора) ---
    Rectangle {
        id: bottomBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: selectionMode ? Theme.itemSizeLarge : 0
        color: "#1E1E1E"
        visible: selectionMode
        z: 10
        Behavior on height { NumberAnimation { duration: 200 } }

        Row {
            anchors { fill: parent; margins: Theme.paddingSmall }
            spacing: Theme.paddingLarge
            IconButton {
                icon.source: "image://theme/icon-m-edit"
                enabled: selectedIds.length === 1
                opacity: enabled ? 1.0 : 0.4
                onClicked: renameSelected()
            }
            IconButton {
                icon.source: "image://theme/icon-m-delete"
                enabled: selectedIds.length > 0
                opacity: enabled ? 1.0 : 0.4
                onClicked: deleteSelected()
            }
            Item { width: 1; height: 1; Layout.fillWidth: true }
            IconButton {
                icon.source: "image://theme/icon-m-close"
                onClicked: exitSelectionMode()
            }
        }
    }

    // --- Кнопка записи (плавающая) ---
    Rectangle {
        id: recordFab
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: Theme.paddingLarge
            bottomMargin: Theme.paddingLarge + (bottomBar.visible ? bottomBar.height : 0)
        }
        width: Theme.itemSizeLarge
        height: Theme.itemSizeLarge
        radius: width / 2
        color: "#FF6B6B"
        visible: !selectionMode

        IconButton {
            anchors.centerIn: parent
            icon.source: "image://theme/icon-m-mic"
            icon.color: "white"
            width: parent.width
            height: parent.height
            onClicked: pageStack.push(Qt.resolvedUrl("RecordingPage.qml"))
        }

        // Тень
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: "#000"
            border.width: 0
            opacity: 0.2
        }
    }

    // --- Контекстное меню сортировки ---
    Rectangle {
        id: sortMenu
        visible: false
        z: 101
        width: Theme.itemSizeLarge * 3
        height: sortColumn.height + Theme.paddingMedium
        color: "#2A2A2A"
        radius: 8
        anchors {
            top: header.bottom
            right: parent.right
            rightMargin: Theme.paddingMedium
        }

        Column {
            id: sortColumn
            width: parent.width
            spacing: Theme.paddingSmall

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                onClicked: { applySort("date"); sortMenu.visible = false }
                Label {
                    anchors { left: parent.left; leftMargin: Theme.paddingLarge; verticalCenter: parent.verticalCenter }
                    text: qsTr("По дате")
                    color: sortField === "date" ? "#FF6B6B" : "white"
                }
            }
            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                onClicked: { applySort("title"); sortMenu.visible = false }
                Label {
                    anchors { left: parent.left; leftMargin: Theme.paddingLarge; verticalCenter: parent.verticalCenter }
                    text: qsTr("По названию")
                    color: sortField === "title" ? "#FF6B6B" : "white"
                }
            }
            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                onClicked: { applySort("duration"); sortMenu.visible = false }
                Label {
                    anchors { left: parent.left; leftMargin: Theme.paddingLarge; verticalCenter: parent.verticalCenter }
                    text: qsTr("По длительности")
                    color: sortField === "duration" ? "#FF6B6B" : "white"
                }
            }
        }
    }

    // --- Делегат заметки (карточка) ---
    Component {
        id: noteDelegate
        Rectangle {
            id: card
            width: parent.width - 2 * Theme.paddingMedium
            anchors.horizontalCenter: parent.horizontalCenter
            height: cardColumn.height + Theme.paddingMedium * 2
            color: "#1E1E1E"
            radius: 8
            border.color: "#333"
            border.width: 1
            clip: true

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (selectionMode) {
                        toggleSelection(noteId)
                    } else {
                        pageStack.push(Qt.resolvedUrl("NoteViewPage.qml"), {
                            noteId: noteId, noteTitle: title, noteDate: date,
                            noteText: text, noteDuration: duration, noteAudio: audio
                        })
                    }
                }
                onPressAndHold: {
                    if (!selectionMode) enterSelectionMode(noteId)
                }
            }

            Column {
                id: cardColumn
                anchors { fill: parent; margins: Theme.paddingMedium }
                spacing: Theme.paddingSmall

                Row {
                    width: parent.width
                    spacing: Theme.paddingSmall
                    Label {
                        width: parent.width - (selectionMode ? Theme.iconSizeMedium + Theme.paddingSmall : 0)
                        text: title
                        color: "white"
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold: true
                        wrapMode: Text.WordWrap
                    }
                    // Чекбокс для выбора
                    Rectangle {
                        width: selectionMode ? Theme.iconSizeMedium : 0
                        height: Theme.iconSizeMedium
                        color: "transparent"
                        visible: selectionMode
                        border.color: isSelected(noteId) ? "#FF6B6B" : "#666"
                        border.width: 2
                        radius: 4
                        Image {
                            anchors.centerIn: parent
                            source: "image://theme/icon-m-acknowledge"
                            visible: isSelected(noteId)
                            width: parent.width * 0.6
                            height: parent.height * 0.6
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: toggleSelection(noteId)
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: Theme.paddingMedium
                    Label { text: date; color: "#888"; font.pixelSize: Theme.fontSizeExtraSmall }
                    Label { text: duration; color: "#888"; font.pixelSize: Theme.fontSizeExtraSmall }
                }

                Label {
                    width: parent.width
                    text: preview
                    color: "#AAA"
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }
        }
    }

    RemorseItem { id: remorseDelete; width: parent.width; height: Theme.itemSizeMedium }

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
}