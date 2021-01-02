function updatedet(index, trackid, showdet) {
    itemUpdStarted(index);
    console.log("UPD" + trackid);

    var okStr="ERR";
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var response = doc.responseText;

            try {
                var data = JSON.parse(response);
            }
            catch (e) {
                setShipmentError(index, "Failed to parse JSON.");
                return false;
            }

            if (data.response.trackingInformationResponse.shipments.length == 0) {
                setShipmentError(index, "Empty shipment information.");
                return false;
            }
            var respObj = data.response.trackingInformationResponse.shipments[0];

            var rivi=999;
            if ("shipmentId" in respObj)
                PDatabase.insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_shipid",respObj.shipmentId);
            if ("assessedNumberOfItems" in respObj)
                PDatabase.insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_numberof",respObj.assessedNumberOfItems.toString());
            if ("name" in respObj.consignor)
                PDatabase.insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_sender",respObj.consignor.name);
            if ("city" in respObj.consignor.address)
                PDatabase.insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_origin",respObj.consignor.address.city);
            if ("name" in respObj.consignee)
                PDatabase.insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_receiver",respObj.consignee.name);
            if ("city" in respObj.consignee.address)
                PDatabase.insertShipdet(trackid,"HDR","99999999999"+rivi,"destinationCity",respObj.consignee.address.city);
            if ("name" in respObj.service)
                PDatabase.insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_service",respObj.service.name);
            if ("totalWeight" in respObj)
                PDatabase.insertShipdet(trackid,"HDR","99999999999"+rivi,"weight", respObj.totalWeight.value + " " + respObj.totalWeight.unit);

            var extraServices;
            for (var i in respObj.additionalServices) {
                if (extraServices == null)
                    extraServices = "";
                else
                    extraServices = extraServices + "\n"
                extraServices = extraServices + respObj.additionalServices[i].name;
            }
            if (extraServices !== null)
                PDatabase.insertShipdet(trackid,"HDR","99999999999"+rivi,"extraServices", extraServices);

            for (var j in respObj.items[0].events) {
                var eventObj = respObj.items[0].events[j];
                var tmpDet="";
                var tmpDate="0";
                var tmpTitle="";
                if ("eventTime" in eventObj) {
                    tmpDate=Qt.formatDateTime(PHelpers.convertIsoDate(eventObj.eventTime), "yyyyMMddHHmmss");
                    okStr="HIT";
                }
                if ("eventDescription" in eventObj)
                    tmpTitle=eventObj.eventDescription;
                if ("location" in eventObj) {
                    if (eventObj["location"]["displayName"]) tmpDet=eventObj["location"]["displayName"];
                    if (eventObj["location"]["country"]) tmpDet=tmpDet+", "+eventObj["location"]["country"];
                }
                PDatabase.insertShipdet(trackid,"EVT",tmpDate,tmpTitle,tmpDet);
                okStr = "HIT";
            }

            itemUpdReady(index,okStr,showdet);
        }
    }

    doc.open("GET", pnURL(trackid));
    doc.send();
}

function pnURL(code) {
    var locale = PHelpers.getLocale(["en", "fi", "sv"]);
    return("https://www.postnord.fi/api/pnmw/shipment/" + code + "/" + locale);
}
