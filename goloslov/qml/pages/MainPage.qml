import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import ru.omstu.goloslov 1.0
import "../Database.js" as Db

Page {
    id: mainPage
    allowedOrientations: Orientation.All

    property bool modelLoaded: false
    property string sortField: "date"
    property string sortDir: "desc"
    property string searchQuery: ""
    property bool searchVisible: false

    property bool selectionMode: false
    property var selectedIds: []
    property bool allSelected: false

    function isSelected(noteId) { return selectedIds.indexOf(noteId) >= 0 }

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
        remorseDelete.execute(notesListView, qsTr("Удалить"), function() {
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
                renameDialog.noteId = noteId
                renameDialog.nameField.text = note.title
                renameDialog.open()
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
        filterNotes(searchQuery)
    }

    function applySort(field) {
        if (sortField === field) {
            sortDir = sortDir === "asc" ? "desc" : "asc"
        } else {
            sortField = field
            sortDir = "desc"
        }
        reloadNotes()
        sortPopup.visible = false // Закрываем окошко после выбора
    }

    function toggleSearch() {
        searchVisible = !searchVisible
        if (!searchVisible) {
            searchQuery = ""
            searchField.text = ""
            searchField.focus = false
            filterNotes("")
        } else {
            searchField.forceActiveFocus()
        }
    }

    function clearSearch() {
        searchQuery = ""
        searchField.text = ""
        searchField.focus = false
        searchVisible = false
        filterNotes("")
    }

    // --- Диалог переименования ---
    Dialog {
        id: renameDialog
        property int noteId: -1
        property alias nameField: nameField
        allowedOrientations: Orientation.All
        Column {
            width: parent.width
            spacing: Theme.paddingMedium
            DialogHeader { title: qsTr("Новое имя") }
            TextField {
                id: nameField
                width: parent.width
                placeholderText: qsTr("Введите название")
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

    // --- Основной фон ---
    Rectangle {
        anchors.fill: parent
        color: "#121212"
    }

    // --- Заголовок ---
    Rectangle {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: Theme.itemSizeLarge + Theme.paddingLarge
        color: "#1E1E1E"
        z: 10

        Label {
            text: qsTr("Голослов")
            color: "#FFB300"
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
            anchors { left: parent.left; leftMargin: Theme.paddingMedium; verticalCenter: parent.verticalCenter }
        }
    }

    // --- Полоска поиска ---
    Rectangle {
        id: searchBar
        anchors { top: header.bottom; left: parent.left; right: parent.right }
        height: searchVisible ? Theme.itemSizeMedium : 0
        color: "#1E1E1E"
        z: 9
        clip: true

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1
            color: "#FFB300"
            opacity: 0.3
        }

        Row {
            anchors { fill: parent; margins: Theme.paddingSmall }
            spacing: Theme.paddingSmall

            MouseArea {
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                anchors.verticalCenter: parent.verticalCenter
                enabled: searchField.text.length > 0
                opacity: enabled ? 1.0 : 0.5
                onClicked: clearSearch()

                Image {
                    anchors.centerIn: parent
                    source: searchField.text.length > 0 ? "image://theme/icon-m-clear" : "image://theme/icon-m-search"
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                }
            }

            TextField {
                id: searchField
                width: parent.width - Theme.iconSizeMedium - Theme.paddingSmall * 2
                height: parent.height - Theme.paddingSmall * 2
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: qsTr("Поиск по записям...")
                color: "white"
                font.pixelSize: Theme.fontSizeSmall
                background: null
                onTextChanged: {
                    searchQuery = text
                    filterNotes(text)
                }
                Keys.onEscapePressed: clearSearch()
            }
        }
    }

    // --- Список заметок ---
    SilicaListView {
        id: notesListView
        anchors {
            top: searchBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        model: filteredModel
        delegate: noteDelegate
        spacing: Theme.paddingSmall

        // 1. ИСПРАВЛЕННЫЙ ПОРЯДОК ПУНКТОВ МЕНЮ
        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                text: qsTr("О приложении")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTr("Сортировка")
                onClicked: sortPopup.visible = true // Открываем маленькое окошко
            }

            MenuItem {
                text: searchVisible
                      ? qsTr("Скрыть поиск")
                      : (searchQuery.length > 0 ? qsTr("Поиск: \"%1\"").arg(searchQuery) : qsTr("Показать поиск"))
                onClicked: toggleSearch()
            }

            MenuItem {
                text: qsTr("Очистить поиск")
                visible: searchQuery.length > 0
                onClicked: clearSearch()
            }
        }

        ViewPlaceholder {
            enabled: filteredModel.count === 0
            text: searchQuery.length > 0 ? qsTr("Ничего не найдено") : qsTr("Нет заметок")
            hintText: searchQuery.length > 0 ? "" : qsTr("Нажмите на микрофон, чтобы начать запись")
        }

        footer: Item {
            width: parent.width
            height: Theme.itemSizeLarge + Theme.paddingLarge * 2
        }
    }

    // 2. МАЛЕНЬКОЕ ОКОШКО СОРТИРОВКИ С ОБОДКОМ (вместо Dialog)

    // Затемнение фона для закрытия по клику вне окна
    MouseArea {
        anchors.fill: parent
        visible: sortPopup.visible
        z: 50
        onClicked: sortPopup.visible = false
    }

    // Само окошко сортировки
    Rectangle {
        id: sortPopup
        visible: false
        z: 51
        width: parent.width * 0.75 // Не на весь экран, а компактное
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: header.bottom
        anchors.topMargin: Theme.paddingMedium
        height: sortColumn.height + Theme.paddingMedium * 2
        color: "#1E1E1E"
        radius: 12
        border.color: "#FFB300" // Оранжевый ободок
        border.width: 2

        Column {
            id: sortColumn
            width: parent.width
            anchors.centerIn: parent
            spacing: Theme.paddingSmall

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                onClicked: { applySort("date"); sortPopup.visible = false }
                Label {
                    anchors { left: parent.left; leftMargin: Theme.paddingLarge; verticalCenter: parent.verticalCenter }
                    text: qsTr("По дате") + (sortField === "date" ? (sortDir === "asc" ? " ▲" : " ▼") : "")
                    color: sortField === "date" ? "#FFB300" : "white"
                }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                onClicked: { applySort("title"); sortPopup.visible = false }
                Label {
                    anchors { left: parent.left; leftMargin: Theme.paddingLarge; verticalCenter: parent.verticalCenter }
                    text: qsTr("По названию") + (sortField === "title" ? (sortDir === "asc" ? " ▲" : " ▼") : "")
                    color: sortField === "title" ? "#FFB300" : "white"
                }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                onClicked: { applySort("duration"); sortPopup.visible = false }
                Label {
                    anchors { left: parent.left; leftMargin: Theme.paddingLarge; verticalCenter: parent.verticalCenter }
                    text: qsTr("По длительности") + (sortField === "duration" ? (sortDir === "asc" ? " ▲" : " ▼") : "")
                    color: sortField === "duration" ? "#FFB300" : "white"
                }
            }

            BackgroundItem {
                width: parent.width
                height: Theme.itemSizeSmall
                onClicked: { applySort("size"); sortPopup.visible = false }
                Label {
                    anchors { left: parent.left; leftMargin: Theme.paddingLarge; verticalCenter: parent.verticalCenter }
                    text: qsTr("По размеру файла") + (sortField === "size" ? (sortDir === "asc" ? " ▲" : " ▼") : "")
                    color: sortField === "size" ? "#FFB300" : "white"
                }
            }
        }
    }

    // --- Делегат заметки ---
    Component {
        id: noteDelegate
        BackgroundItem {
            id: delegateItem
            width: parent.width
            height: noteColumn.height + 2 * Theme.paddingMedium

            Column {
                id: noteColumn
                x: Theme.horizontalPageMargin
                y: Theme.paddingMedium
                width: parent.width - 2 * Theme.horizontalPageMargin

                Row {
                    width: parent.width
                    spacing: Theme.paddingSmall

                    Rectangle {
                        width: selectionMode ? Theme.iconSizeMedium : 0
                        height: Theme.iconSizeMedium
                        color: "transparent"
                        visible: selectionMode
                        border.color: isSelected(noteId) ? "#FFB300" : "#666"
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

                    Label {
                        width: parent.width - (selectionMode ? Theme.iconSizeMedium + Theme.paddingSmall : 0)
                        text: title
                        color: delegateItem.highlighted ? "#FFB300" : "white"
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold: true
                        truncationMode: TruncationMode.Fade
                    }
                }

                Item { width: 1; height: Theme.paddingSmall }

                Row {
                    width: parent.width
                    spacing: Theme.paddingMedium
                    Label { text: date; color: "#888"; font.pixelSize: Theme.fontSizeExtraSmall }
                    Label { text: duration; color: "#888"; font.pixelSize: Theme.fontSizeExtraSmall }
                    Label {
                        text: fileSize
                        color: "#888"
                        font.pixelSize: Theme.fontSizeExtraSmall
                        visible: fileSize !== undefined && fileSize !== ""
                    }
                }

                Item { width: 1; height: Theme.paddingSmall }

                Label {
                    width: parent.width
                    text: preview
                    color: "#AAA"
                    font.pixelSize: Theme.fontSizeSmall
                    maximumLineCount: 2
                    truncationMode: TruncationMode.Elide
                    wrapMode: Text.WordWrap
                }
            }

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

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: "#333"
                opacity: 0.3
            }
        }
    }

    RemorseItem { id: remorseDelete }

    // --- Плавающая кнопка записи по центру ---
    Rectangle {
        id: recordButton
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }
        width: Theme.itemSizeLarge
        height: Theme.itemSizeLarge
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FFB300" }
            GradientStop { position: 1.0; color: "#FF8F00" }
        }
        z: 100
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

    // --- Нижняя панель для режима выбора ---
    Rectangle {
        id: bottomBar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: selectionMode ? Theme.itemSizeMedium : 0
        color: "#1E1E1E"
        visible: selectionMode
        z: 10
        clip: true

        Behavior on height { NumberAnimation { duration: 200 } }

        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 1
            color: "#FFB300"
            opacity: 0.3
        }

        Row {
            anchors { fill: parent; leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium }
            spacing: Theme.paddingMedium

            IconButton {
                id: cancelButton
                anchors.verticalCenter: parent.verticalCenter
                icon.source: "image://theme/icon-m-cancel"
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                onClicked: exitSelectionMode()
            }

            Item { width: 1; height: 1 }

            IconButton {
                id: deleteButton
                anchors.verticalCenter: parent.verticalCenter
                icon.source: "image://theme/icon-m-delete"
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                enabled: selectedIds.length > 0
                opacity: enabled ? 1.0 : 0.4
                onClicked: deleteSelected()
            }

            Item { width: 1; height: 1 }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Выбрано: %1").arg(selectedIds.length)
                color: "#FFB300"
                font.pixelSize: Theme.fontSizeSmall
            }

            Item { width: 1; height: 1 }

            IconButton {
                id: selectAllButton
                anchors.verticalCenter: parent.verticalCenter
                icon.source: allSelected ? "image://theme/icon-m-clear" : "image://theme/icon-m-add"
                width: Theme.iconSizeMedium
                height: Theme.iconSizeMedium
                onClicked: selectAll()
            }
        }
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
}
