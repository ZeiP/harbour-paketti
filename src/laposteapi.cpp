#include "laposteapi.h"
#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDebug>
#include <QEventLoop>

LaPosteAPI::LaPosteAPI() {}

QString LaPosteAPI::requestResponse(QString url)
{
    QUrl urlObject(url);
    QNetworkRequest request;
    request.setUrl(urlObject);
    request.setRawHeader("Accept", "application/json");
    request.setRawHeader("X-Okapi-Key", this->getApiKey().toUtf8());

    QNetworkAccessManager* manager = new QNetworkAccessManager(this);

    QNetworkReply* reply = manager->get(request);

    QEventLoop loop;
    connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    // FIXME: Should use the connect properly instead of an eventloop.
//    connect(reply, &QNetworkReply::finished, [=]() {
        if(reply->error() == QNetworkReply::NoError)
        {
            QByteArray response = reply->readAll();
            return response;
        }
        else // handle error
        {
            qDebug(reply->errorString().toUtf8());
            QByteArray response = reply->readAll();
            return response;
        }
//    });
}

QString LaPosteAPI::getApiKey() {
    return apiKey;
}
