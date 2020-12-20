#ifndef DHLAPI_H
#define DHLAPI_H
#include <QObject>

class DHLAPI : public QObject {
    Q_OBJECT
public:
    explicit DHLAPI();
    Q_INVOKABLE QString requestResponse(QString url);
private:
    QString getApiKey();
    // Authorization key for the API
    // Generate an API key at https://developer.dhl.com/
    QString apiKey = "";
};

#endif // DHLAPI_H
