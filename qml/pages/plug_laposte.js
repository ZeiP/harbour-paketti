function updatedet(index,trackid,showdet,laposteKey) {
	itemUpdStarted(index);
	console.log("UPD" + trackid);

	var db = dbConnection();
	var doc = new XMLHttpRequest();

	doc.onreadystatechange = function() {
		if (doc.readyState == XMLHttpRequest.DONE) {
			var data = JSON.parse(doc.responseText);

			insertShipdet(trackid, "HDR", "99999999999998", "hdr_service", data.shipment.product);

			var dateOptions = {day: "numeric", month: "long", year: "numeric", hour: "numeric", minute: "2-digit"}

			for (var i in data.shipment.event) {
				var ev = data.shipment.event[i];
				var dateEvent = Qt.formatDateTime(new Date(ev.date), "yyyyMMddHHmmss")
				var descriptionLabel = getTextOfCodeLaPoste(ev.code) + ": " + ev.label
				insertShipdet(trackid, "EVT", dateEvent, descriptionLabel, "");
			}
			insertShipdet(trackid, "HDR", "99999999999999", "hdr_shipid", data.shipment.idShip);

			itemUpdReady(index, "HIT", showdet);
		}
	}
	doc.open("GET", laposteURL(trackid));

	doc.setRequestHeader('Accept', 'application/json')
    doc.setRequestHeader('X-Okapi-Key', laposteKey)

	doc.send();
}

function laposteURL(koodi) {
	var locale = getLocale(["fr_FR"]);
	return("https://api.laposte.fr/suivi/v2/idships/" + koodi + "?lang=" + locale);
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
