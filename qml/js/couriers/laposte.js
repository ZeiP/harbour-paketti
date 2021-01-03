function updatedet(index, trackid, showdet) {
    PAPIData.itemUpdStarted(index);
	console.log("UPD" + trackid);

	var db = dbConnection();
    var response = laPosteApi.requestResponse(laposteURL(trackid));

    try {
        var data = JSON.parse(response);
    }
    catch (e) {
        PAPIData.setShipmentError(index, trackid, showdet, "Failed to parse JSON.");
        return false;
    }

    // returnMessage should only be given when an error has occured, but as the
    // documentation isn't exactly up-to-date per the returnCode values either,
    // this may not be the case? Anyway, it's the best we've got.
    // It seems that at least authentication error doesn't have the returnMessage either,
    // so we should check by HTTP return code (maybe?) and then print out the
    // content OR returnMessage, whichever exists.
    if (data.returnMessage != null) {
        PAPIData.setShipmentError(index, trackid, showdet, "JSON contained an error: " + data.returnMessage);
        return false;
    }

    PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "hdr_service", data.shipment.product);

    var dateOptions = {day: "numeric", month: "long", year: "numeric", hour: "numeric", minute: "2-digit"}

    for (var i in data.shipment.event) {
        var ev = data.shipment.event[i];
        var dateEvent = Qt.formatDateTime(new Date(ev.date), "yyyyMMddHHmmss")
        var descriptionLabel = getTextOfCodeLaPoste(ev.code) + ": " + ev.label
        PDatabase.insertShipdet(trackid, "EVT", dateEvent, descriptionLabel, "");
    }
    PDatabase.insertShipdet(trackid, "HDR", "99999999999999", "hdr_shipid", data.shipment.idShip);

    PAPIData.itemUpdReady(index, "HIT", showdet);
}

function laposteURL(code) {
    // Despite the API documentation La Poste API returns a ”code not found error” for other
    // locales except these (the list is based on experimentation, so it may be missing some...)
    var langs = ["en_GB", "fr_FR", "de_DE", "it_IT", "nl_NL", "es_ES"];
    return("https://api.laposte.fr/suivi/v2/idships/" + code + "?lang=" + PHelpers.getLocale(langs, true));
}

function getTextOfCodeLaPoste(code) {
	switch (code) {
	case "DR1":
		return "Déclaratif réceptionné";
	case "PC1":
		return "Pris en charge";
	case "PC2":
		return "Pris en charge dans le pays d’expédition";
	case "ET1":
		return "En cours de traitement";
	case "ET2":
		return "En cours de traitement dans le pays d’expédition";
	case "ET3":
		return "En cours de traitement dans le pays de destination";
	case "ET4":
		return "En cours de traitement dans un pays de transit";
	case "EP1":
		return "En attente de présentation";
	case "DO1":
		return "Entrée en Douane";
	case "DO2":
		return "Sortie  de Douane";
	case "DO3":
		return "Retenu en Douane";
	case "PB1":
		return "Problème en cours";
	case "PB2":
		return "Problème résolu";
	case "MD2":
		return "Mis en distribution";
	case "ND1":
		return "Non distribuable";
	case "AG1":
		return "En attente d'être retiré au guichet";
	case "RE1":
		return "Retourné à l'expéditeur";
	case "DI1":
		return "Distribué";
	case "DI2":
		return "Distribué à l'expéditeur";
	default:
		return "";
	}
}
