function updatedet(index,trackid,showdet) {
    itemUpdStarted(index);
    console.log("UPD" + trackid);

    var db = dbConnection();
    var doc = new XMLHttpRequest();

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var data = JSON.parse(doc.responseText);

            insertShipdet(trackid, "HDR", "99999999999998", "hdr_service", data.productCategory);

            for (var i in data.trackingEvents) {
                var ev = data.trackingEvents[i];
                var dateString = ev.date.match(/^(\d{2})\.(\d{2})\.(\d{4})$/);
                var timeString = ev.time.match(/^(\d{2}):(\d{2})$/);
                var date = Qt.formatDateTime(new Date(dateString[3], dateString[2]-1, dateString[1], timeString[1], timeString[2]), "yyyyMMddHHmmss");
                insertShipdet(trackid, "EVT", date, ev.description, ev.place);
            }
            insertShipdet(trackid, "HDR", "99999999999999", "hdr_shipid", data.parcelNumber);

            itemUpdReady(index, "HIT", showdet);
        }
    }
    doc.open("GET", mhURL(trackid));
    doc.send();
}
