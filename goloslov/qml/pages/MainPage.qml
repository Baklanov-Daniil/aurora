import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaListView {
        id: listView
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Записать")
                onClicked: pageStack.push(Qt.resolvedUrl("RecordPage.qml"))
            }
        }

        ViewPlaceholder {
            enabled: listView.count === 0
            text: qsTr("Заметок нет")
            hintText: qsTr("Потяните вниз, чтобы начать запись")
        }

        delegate: ListItem {
            // Заглушка для списка заметок (добавим на следующем этапе)
        }
    }
}
