function updatedet(index, trackid, showdet) {
    PAPIData.itemUpdStarted(index);
    console.log("UPD" + trackid);

    var db = dbConnection();
    var doc = new XMLHttpRequest();

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var response = doc.responseText;

            try {
                var data = JSON.parse(response);
            }
            catch (e) {
                PAPIData.setShipmentError(index, trackid, showdet, "Failed to parse JSON.");
                return false;
            }

            if (data.notFound == true) {
                PAPIData.setShipmentError(index, trackid, showdet, "MH reported not found.");
                return false;
            }

            if (!data.trackingEvents.length) {
                PAPIData.setShipmentError(index, trackid, showdet, "Empty tracking events data");
                return;
            }
            PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "hdr_service", data.productCategory);

            for (var i in data.trackingEvents) {
                var ev = data.trackingEvents[i];
                var dateString = ev.date.match(/^(\d{2})\.(\d{2})\.(\d{4})$/);
                var timeString = ev.time.match(/^(\d{2}):(\d{2})$/);
                var date = Qt.formatDateTime(new Date(dateString[3], dateString[2]-1, dateString[1], timeString[1], timeString[2]), "yyyyMMddHHmmss");
                PDatabase.insertShipdet(trackid, "EVT", date, ev.description, ev.place);
            }
            PDatabase.insertShipdet(trackid, "HDR", "99999999999999", "hdr_shipid", data.parcelNumber);

            PAPIData.itemUpdReady(index, "HIT", showdet);
        }
    }
    doc.open("GET", mhURL(trackid));
    doc.send();
}

function mhURL(code) {
    var locale = PHelpers.getLocale(["en", "fi", "sv"]);
    return("https://wwwservice.matkahuolto.fi/search/trackingInfo?language=" + locale + "&parcelNumber=" + code);
}
