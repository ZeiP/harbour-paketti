// #ifdef QT_QML_DEBUG
#include <QtQuick>
// #endif

#include <sailfishapp.h>

#include "laposteapi.h"
#include "dhlapi.h"

int main(int argc, char *argv[])
{
    // Set up QML engine.
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> v(SailfishApp::createView());

    // If you wish to publish your app on the Jolla harbour, it is recommended
    // that you prefix your internal namespaces with "harbour.".
    //
    // For details see:
    // https://harbour.jolla.com/faq#1.5.0
    qmlRegisterType<LaPosteAPI>("harbour.org.paketti", 1, 0, "LaPosteAPI");
    LaPosteAPI *laPosteApi = new LaPosteAPI();
    v->rootContext()->setContextProperty("laPosteApi", laPosteApi);

    qmlRegisterType<DHLAPI>("harbour.org.paketti", 1, 0, "DHLAPI");
    DHLAPI *dhlApi = new DHLAPI();
    v->rootContext()->setContextProperty("dhlApi", dhlApi);

    // Start the application.
    v->setSource(SailfishApp::pathTo("qml/harbour-paketti.qml"));
    v->show();
    return app->exec();
}
