#include "dhlapi.h"
#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDebug>
#include <QEventLoop>

DHLAPI::DHLAPI() {}

QString DHLAPI::requestResponse(QString url)
{
    QUrl urlObject(url);
    QNetworkRequest request;
    request.setUrl(urlObject);
    request.setRawHeader("Accept", "application/json");
    request.setRawHeader("DHL-API-Key", this->getApiKey().toUtf8());

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
            return "";
        }
//    });
}

QString DHLAPI::getApiKey() {
    return apiKey;
}
