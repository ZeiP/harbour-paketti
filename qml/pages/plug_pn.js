function updatedet(index,trackid,showdet) {

    itemUpdStarted(index);
    console.log("UPD" + trackid);

    var okStr="ERR";
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var jsonObj = JSON.parse(doc.responseText);
                if (jsonObj.error != null) {
                    console.log("Cannot parse JSON");
                }


                var respObj = jsonObj["TrackingInformationResponse"]["shipments"][0];
                var rivi=999;
                for(var p in respObj) {
                    if (p=="shipmentId") {
                        insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_shipid",respObj[p]);
                        okStr="OK";
                    }
                    if (p=="assessedNumberOfItems") insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_numberof",respObj[p]+" ");
                    if (p=="consignor") {
                        if (respObj[p]["name"])insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_sender",respObj[p]["name"]);
                        if (respObj[p]["address"]["city"])insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_origin",respObj[p]["address"]["city"]);
                    }
                    if (p=="consignee") {
                        if (respObj[p]["name"]) insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_receiver",respObj[p]["name"]);
                        if (respObj[p]["address"]["city"])insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_destination",respObj[p]["address"]["city"]);
                    }
                    if (p=="service" && respObj[p]["name"]) insertShipdet(trackid,"HDR","99999999999"+rivi,"hdr_service",respObj[p]["name"]);
                    if (p=="items" && respObj[p][0]["events"]) {
                        for (var c in respObj[p][0]["events"]) {

                            var tmpDet="";
                            var tmpDate="0";
                            var tmpTitle="";
                            var eventObj=respObj[p][0]["events"][c];
                            if (eventObj["eventTime"]) {
                                tmpDate=Qt.formatDateTime(convertIsoDate(eventObj["eventTime"]), "yyyyMMddHHmmss");
                                okStr="HIT";
                            }
                            if (eventObj["eventDescription"]) tmpTitle=eventObj["eventDescription"];
                            if (eventObj["location"]) {
                                if (eventObj["location"]["displayName"]) tmpDet=eventObj["location"]["displayName"];
                                if (eventObj["location"]["country"]) tmpDet=tmpDet+", "+eventObj["location"]["country"];
                            }
                            insertShipdet(trackid,"EVT",tmpDate,tmpTitle,tmpDet);
                        }
                    }

                    rivi--;
                }
                itemUpdReady(index,okStr,showdet);

            }


    }

    doc.open("GET", pnURL(trackid));
    doc.send();
}
