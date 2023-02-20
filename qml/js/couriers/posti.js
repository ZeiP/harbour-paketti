function updatedet(index, trackid, showdet) {
    PAPIData.itemUpdStarted(index);
    console.log("UPD" + trackid);

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var headrivi = 997;
            var response = doc.responseText;

            try {
                var data = JSON.parse(response);
            }
            catch (e) {
                PAPIData.setShipmentError(index, trackid, showdet, "Failed to parse JSON.");
                return false;
            }

            var locale = PHelpers.getLocale(["en", "fi", "sv", "lt", "lv"]);

            data = data[0];

            PDatabase.insertShipdet(trackid, "EVT", "19700101000000", data.status.description[locale]);
            PDatabase.insertShipdet(trackid, "HDR", "99999999999999", "hdr_shipid", data.trackingNumber);

            PAPIData.itemUpdReady(index,"HIT",showdet);
        }
    }

    doc.open("GET", postiURL(trackid));
    doc.send();
}

function postiURL(code) {
    return("https://www.posti.fi/tracking-api-proxy/?q=" + code);
}
