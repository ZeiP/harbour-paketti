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
                PAPIData.setShipmentError(index, trackid, showdet, "Bring reported not found.");
                return false;
            }

            if (!data.consignmentSet.length || !data.consignmentSet[0].packageSet.length || !data.consignmentSet[0].packageSet[0].eventSet.length) {
                PAPIData.setShipmentError(index, trackid, showdet, "Empty tracking events data");
                return;
            }
            var setData = data.consignmentSet[0];
            var packageData = setData.packageSet[0];

            var additionalServices = '';
            var firstAddtService = true;
            for (var i in packageData.additionalServiceSet) {
                var adtService = packageData.additionalServiceSet[i];
                additionalServices = additionalServices + adtService.description
                if (!firstAddtService) {
                    additionalServices = additionalServices + "\n";
                }
                firstAddtService = false;
            }

            PDatabase.insertShipdet(trackid, "HDR", "99999999999999", "hdr_shipid", packageData.packageNumber);
            PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "hdr_service", packageData.productName);
            PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "hdr_sender", setData.senderName);
            PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "destinationCity", setData.recipientAddress.city);
            PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "hdr_origin", setData.senderAddress.city);
            PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "hdr_numberof", setData.packageSet.length.toString());
            PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "estimatedDeliveryTime", packageData.dateOfEstimatedDelivery);
            PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "extraServices", additionalServices);
            PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "weight", setData.totalWeightInKgs + " kg");
            PDatabase.insertShipdet(trackid, "HDR", "99999999999998", "size", qsTr("%1 × %2 × %3 cm").arg(packageData.lengthInCm).arg(packageData.widthInCm).arg(packageData.heightInCm));

            var lastDate = '';
            for (var j in packageData.eventSet) {
                var ev = packageData.eventSet[j];
                var date = new Date(ev.dateIso);
                while (date.toString() == lastDate.toString()) {
                    date.setSeconds(date.getSeconds() + 1);
                }

                PDatabase.insertShipdet(trackid, "EVT", Qt.formatDateTime(date, "yyyyMMddHHmmss"), ev.description, ev.city);
                lastDate = date;
            }

            PAPIData.itemUpdReady(index, "HIT", showdet);
        }
    }
    doc.open("GET", mhURL(trackid));
    doc.send();
}

function mhURL(code) {
    var locale = PHelpers.getLocale("'");
    return("https://tracking.bring.com/tracking/api/fetch/" + code + "?lang=" + locale);
}
