#include <auroraapp.h>
#include <QtQuick>
#include "audiorecorder.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.omstu"));
    application->setApplicationName(QStringLiteral("goloslov"));

    AudioRecorder recorder;

    QScopedPointer<QQuickView> view(Aurora::Application::createView());
    view->rootContext()->setContextProperty(QStringLiteral("audioRecorder"), &recorder);
    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/goloslov.qml")));
    view->show();

    return application->exec();
}
