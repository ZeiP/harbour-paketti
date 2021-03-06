function updatedet(index, trackid, showdet) {
    PAPIData.itemUpdStarted(index);
    console.log("UPD" + trackid);

    var db = dbConnection();
    var doc = new XMLHttpRequest();

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            if (doc.status == 204) {
                // 204 No Content means not found /expired
                PAPIData.setShipmentError(index, trackid, showdet, "Not found / expired");
                return false;
            }

            var response = doc.responseText;
            try {
                var data = JSON.parse(response);
            }
            catch (e) {
                PAPIData.setShipmentError(index, trackid, showdet, "Failed to parse JSON.");
                return false;
            }

            if (data.message != null) {
                PAPIData.setShipmentError(index, trackid, showdet, "JSON contained a message: " + data.message);
                return false;
            }

            data = data[0];

            for (var i in data.statusHistory) {
                var ev = data.statusHistory[i];
                var explodedDT = ev.dateTime.split(' ');
                var dateString = explodedDT[0].match(/^(\d{2})\.(\d{2})\.(\d{4})$/);
                var timeString = explodedDT[1].match(/^(\d{2}):(\d{2})$/);
                var date = Qt.formatDateTime(new Date(dateString[3], dateString[2]-1, dateString[1], timeString[1], timeString[2]), "yyyyMMddHHmmss");
                PDatabase.insertShipdet(trackid, "EVT", date, ev.description, "");
            }
            PDatabase.insertShipdet(trackid, "HDR", "99999999999999", "hdr_shipid", data.shipmentID);

            PAPIData.itemUpdReady(index, "HIT", showdet);
        }
    }
    doc.open("GET", hermesDeURL(trackid));
    doc.send();
}

function hermesDeURL(code) {
    return("https://www.myhermes.de/services/tracking/shipments?search=" + code);
}
