import QtQuick 2.6
import Sailfish.Silica 1.0

ApplicationWindow {
    id: appWindow
    initialPage: Qt.resolvedUrl("pages/MainPage.qml")
    cover: Qt.resolvedUrl("cover/DefaultCoverPage.qml")
    allowedOrientations: Orientation.All
}
