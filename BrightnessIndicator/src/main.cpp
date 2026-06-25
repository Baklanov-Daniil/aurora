#include <auroraapp.h>
#include <QtQuick>

#include "imageprocessor.h"
#include "resultimageprovider.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(
        Aurora::Application::application(argc, argv));

    application->setOrganizationName(QStringLiteral("ru.template"));
    application->setApplicationName(QStringLiteral("ImageLab"));

    ResultImageProvider *provider = new ResultImageProvider;
    ImageProcessor processor(provider);

    QScopedPointer<QQuickView> view(Aurora::Application::createView());

    view->engine()->addImageProvider(QStringLiteral("result"), provider);

    view->rootContext()->setContextProperty(
        QStringLiteral("imageProcessor"), &processor);

    view->setSource(Aurora::Application::pathTo(
        QStringLiteral("qml/ImageLab.qml")));
    view->show();

    return application->exec();
}
