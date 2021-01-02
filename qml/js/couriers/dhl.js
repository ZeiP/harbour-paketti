function updatedet(index, trackid, showdet) {
    PAPIData.itemUpdStarted(index);
	console.log("UPD" + trackid);

	var db = dbConnection();

    var response = dhlApi.requestResponse(dhlURL(trackid));

    try {
        var data = JSON.parse(response);
    }
    catch (e) {
        PAPIData.setShipmentError(index, trackid, showdet, "Failed to parse JSON.");
        return false;
    }

    if (PHelpers.httpStatusIsError(data.status)) {
        PAPIData.setShipmentError(index, trackid, showdet, "JSON contained an error: " + data.detail);
        return false;
    }

    if (data.shipments.length == 0) {
        PAPIData.setShipmentError(index, trackid, showdet, "Empty shipment information.");
        return false;
    }
    var respObj = data.shipments[0];
    PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "hdr_service", respObj.service);

    var dateOptions = {day: "numeric", month: "long", year: "numeric", hour: "numeric", minute: "2-digit"}

    for (var i in respObj.events) {
        var ev = respObj.events[i];
        var dateEvent = Qt.formatDateTime(new Date(ev.timestamp), "yyyyMMddHHmmss")
        var descriptionLabel = ev.description + ": " + ev.location.address.addressLocality;
        PDatabase.insertShipdet(trackid, "EVT", dateEvent, descriptionLabel, "");
    }
    PDatabase.insertShipdet(trackid, "HDR", "99999999999999", "hdr_shipid", respObj.id);
    PDatabase.insertShipdet(trackid, "HDR", "99999999999997", "nextStep", respObj.status.nextSteps);

    PAPIData.itemUpdReady(index, "HIT", showdet);
}

function dhlURL(code) {
    return("https://api-eu.dhl.com/track/shipments?trackingNumber=" + code + "&language=" + PHelpers.getLocale('*'));
}
