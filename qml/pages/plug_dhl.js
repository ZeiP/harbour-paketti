function updatedet(index, trackid, showdet) {
	itemUpdStarted(index);
	console.log("UPD" + trackid);

	var db = dbConnection();

    var response = dhlApi.requestResponse(dhlURL(trackid));
    var data = JSON.parse(response);
    if (data.error != null) {
        console.log("Cannot parse JSON");
        itemUpdReady(index,"ERR", 0);
        return false;
    }

    if (data.shipments.length == 0) {
        console.log("Empty shipment information.");
        itemUpdReady(index,"ERR", 0);
        return false;
    }
    var respObj = data.shipments[0];
    insertShipdet(trackid, "HDR", "99999999999998", "hdr_service", respObj.service);

    var dateOptions = {day: "numeric", month: "long", year: "numeric", hour: "numeric", minute: "2-digit"}

    for (var i in respObj.events) {
        var ev = respObj.events[i];
        var dateEvent = Qt.formatDateTime(new Date(ev.timestamp), "yyyyMMddHHmmss")
        var descriptionLabel = ev.description + ": " + ev.location.address.addressLocality;
        insertShipdet(trackid, "EVT", dateEvent, descriptionLabel, "");
    }
    insertShipdet(trackid, "HDR", "99999999999999", "hdr_shipid", respObj.id);
    insertShipdet(trackid, "HDR", "99999999999997", "nextStep", respObj.status.nextSteps);

    itemUpdReady(index, "HIT", showdet);
}

function dhlURL(code) {
    return("https://api-eu.dhl.com/track/shipments?trackingNumber=" + code + "&language=" + getLocale(["en"]));
}
