#ifndef COURIERAPI_H
#define COURIERAPI_H

#include <QObject>

class CourierAPI : public QObject {
    Q_OBJECT
public:
    explicit CourierAPI();
    Q_INVOKABLE QString get_laposte_key();
private:
    // Authorization key for LaPoste API
    // Generate a production (or a test) one at : https://developer.laposte.fr/products/suivi/latest
    QString laposte_xokapikey = "";
};

#endif // COURIERAPI_H
