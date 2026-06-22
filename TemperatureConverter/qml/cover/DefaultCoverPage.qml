import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    CoverPlaceholder {
        text: qsTr("Конвертер")
        icon: "/usr/share/icons/hicolor/86x86/apps/ru.auroraos.ApplicationTemplate.png"
    }

    Label {
        anchors.centerIn: parent
        width: parent.width - 2 * Theme.horizontalPageMargin
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.primaryColor
        text: {
            var p = pageStack.initialPage
            if (p && p.calculate) {
                return p.calculate() + " " + p.resultUnitLabel()
            }
            return ""
        }
    }

    CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                var p = pageStack.initialPage
                if (p) p.calculate()
            }
        }
    }
}
