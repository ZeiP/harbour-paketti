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

            if (!data.shipments.length) {
                PAPIData.setShipmentError(index, trackid, showdet, "Empty shipment data");
                return;
            }

            var locale = PHelpers.getLocale(["en", "fi", "sv", "lt", "lv"]);

            var ds = data.shipments[0];

            var codAmnt;
            var extraServices;
            for (var i in data.shipments[0].extraServices) {
                if (data.shipments[0].extraServices[i]["name"] == null) {
                    continue;
                }
                if (extraServices == null) {
                    extraServices = data.shipments[0].extraServices[i]["name"][locale];
                }
                else {
                    extraServices=extraServices + "\n" + data.shipments[0].extraServices[i]["name"][locale];
                }
            }

            for (var rd in data.shipments[0]) {
                if (rd=="product" && ds.product.name !== null) PDatabase.insertShipdet(trackid,"HDR","99999999999998","hdr_service", ds.product.name[locale]);
                if (typeof ds[rd] === 'string') {
                    if (rd=="estimatedDeliveryTime") PDatabase.insertShipdet(trackid,"HDR","99999999999" + headrivi,"estimatedDeliveryTime",Qt.formatDateTime(new Date(ds.estimatedDeliveryTime)),"yyyyMMddHHmmss");
                    if (rd=="codAmount") PDatabase.insertShipdet(trackid,"HDR","99999999999" + headrivi,"codAmount", ds.codAmount + " " + ds.codCurrency);
                    if (rd=="weight") PDatabase.insertShipdet(trackid,"HDR","99999999999" + headrivi,"weight", ds.weight + " kg");
                    if (rd=="height") PDatabase.insertShipdet(trackid,"HDR","99999999999" + headrivi,"size", ds.width + " x " + ds.depth + " x " + ds.height + " cm");
                    if (rd=="destinationPostcode") PDatabase.insertShipdet(trackid,"HDR","99999999999" + headrivi,"destinationCity", ds.destinationPostcode + " " + ds.destinationCity + " " + ds.destinationCountry);
               }

               headrivi--;
            }

            if (extraServices!=null) {
                PDatabase.insertShipdet(trackid,"HDR","99999999999" + headrivi,"extraServices", extraServices);
            }

            for (var i in data.shipments[0].events) {
                var ev = data.shipments[0].events[i];
                var locline = ""
                if (ev.locationCode !== null && ev.locationCode !== "null") {
                    locline = ev.locationCode + " "
                }
                if (ev.locationName !== null && ev.locationName !== "null") {
                    locline = locline + ev.locationName
                }
                if (ev.description !== null && ev.description !== "null") {
                    PDatabase.insertShipdet(trackid,"EVT",Qt.formatDateTime(new Date(ev.timestamp), "yyyyMMddHHmmss"),ev.description[locale], locline);
                }
            }
            PDatabase.insertShipdet(trackid,"HDR","99999999999999", "hdr_shipid", data.shipments[0].trackingCode);

            PAPIData.itemUpdReady(index,"HIT",showdet);
        }
    }

    doc.open("GET", postiURL(trackid));
    doc.send();
}

function postiURL(code) {
    return("https://www.posti.fi/henkiloasiakkaat/seuranta/api/shipments/" + code);
}
