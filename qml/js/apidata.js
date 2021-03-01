/*
FIXME: This should allow us to import all the plugins only once,
but apparently the plugin can't access the functions defined
in this file then.
.import "couriers/posti.js" as PlugPosti
.import "couriers/matkahuolto.js" as PlugMH
.import "couriers/postnord.js" as PlugPN
.import "couriers/herde.js" as PlugHerDe
.import "couriers/laposte.js" as PlugLaPoste
.import "couriers/dhl.js" as PlugDHL */

function itemUpdStarted(index) {
    historyModel.set(index, {"itmrun": "true"});
    historyModel.set(index, {"itmcolor": "yellow"});
    historyModel.set(index, {"status": 1});
    runningUpdates = runningUpdates + 1;
}

function itemUpdReady(index, okStr, showdet) {
    runningUpdates = runningUpdates - 1;

    var trackid = historyModel.get(index).title;
    lastActivityToList(index);
    historyModel.set(index, {"itmrun": "false"});

    switch (okStr) {
        case "HIT":
            historyModel.set(index, {"itmcolor": "green"});
            console.log("UPDWWW: " + trackid + " [OK]");
        break;
        case "ERR":
            historyModel.set(index, {"itmcolor": "red"});
            console.log("UPDWWW: " + trackid + " [Error]");
        break;
        case "OK":
            historyModel.set(index, {"itmcolor": "orange", "det": "NAN"});
            console.log("UPDWWW: " + trackid + " [no_data]");
        break;
    }

    if (showdet == 1) {
        pageStack.push("../pages/Details.qml", {"code": trackid});
    }
    else {
        historyModel.set(index, {"status": PDatabase.getStatus(historyModel.get(index).title)});
    }
    saveitem(index);
}

function deleteitm(trackid) {
    var db = dbConnection();
    db.transaction(
        function(tx) {
            tx.executeSql('DELETE FROM shipdets WHERE trackid = UPPER(?);', [trackid]);
            var rs = tx.executeSql('DELETE FROM history WHERE trackid = UPPER(?);', [trackid]);
            if (rs.rowsAffected > 0) {
                console.log("Deleted: " + trackid + " [OK]")
                if (historyModel.count == 1) {
                    historyvisible = false;
                }
            } else {
                console.error("ERROR: Failed to delete : " + trackid );
            }
        }
    );
}

function updateData() {
    for (var i = 1; i < historyModel.count; i++) {
        if (historyModel.get(i).title != "") {
            var courierData = couriers.getCourierByIdentifier(historyModel.get(i).type)
            historyModel.set(i, {"typec" : courierData.brandColour});

            var trackid = historyModel.get(i).title;
            PAPIData.updateitem(i, trackid, 0, historyModel.get(i).type);
        }
        PDatabase.setLastUpd();
    }
}

function updateitem(index, trackid, showdet, type) {
    switch (type) {
        case 'FI':
            PlugPosti.updatedet(index, trackid, showdet);
            break;
        case 'MH':
            PlugMH.updatedet(index, trackid, showdet);
            break;
        case 'PN':
            PlugPN.updatedet(index, trackid, showdet);
            break;
        case 'HERDE':
            PlugHerDe.updatedet(index, trackid, showdet);
            break;
        case 'DHL':
            PlugDHL.updatedet(index, trackid, showdet);
            break;
        case 'LAPOSTE':
            PlugLaPoste.updatedet(index, trackid, showdet);
            break;
        case 'BRING':
            PlugBring.updatedet(index, trackid, showdet);
            break;
    }
}

function addTrackable(type, trackid) {
    if (trackid != "") {
        var index = 999;
        historyvisible = true;
        trackid = trackid.toUpperCase();

        // Check if item is already on historylist, if not add and save to db
        for (var i = 0; i < historyModel.count; i++) {
            var item = historyModel.get(i);
            if (item.title.toUpperCase() == trackid.toUpperCase() && item.type.toUpperCase() == type.toUpperCase()) {
                index = i;
            }
        }

        if (index == 999) {
            index = 1;
            var tmpdate = Qt.formatDateTime(new Date(), "yyyyMMddHHmmss");
            historyModel.insert(index, {"type": type, "title": trackid, "det": "NAN", "statusstr": "", "datetime": tmpdate, "itemdesc": ""});
            saveitem(index);
        }
        updateitem(index, trackid, 1, type);
    }
}

function reloadhistory(upd) {
    var db = dbConnection();
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('SELECT * FROM history ORDER BY timestamp DESC;');
            for (var i = 0; i < rs.rows.length; i++) {
                historyModel.set(i+1, {"type": rs.rows.item(i).type, "det": "NAN", "title": rs.rows.item(i).trackid, "datetime": rs.rows.item(i).timestamp, "itemdesc": rs.rows.item(i).detstr});
                var courierData = couriers.getCourierByIdentifier(rs.rows.item(i).type)
                historyModel.set(i+1, {"typec" : courierData.brandColour});

                historyModel.set(i+1, {"status": PDatabase.getStatus(rs.rows.item(i).trackid)});
                lastActivityToList(i+1);
            }
            if (rs.rows.length != 0) {
                historyvisible = true;
            }
            else {
                historyvisible = false;
            }
        }
    );
    if (upd == true) {
        updateData();
    }
}

function setShipmentError(index, trackid, showdet, errormsg) {
    console.error(errormsg);
    PDatabase.setStatus(trackid, errormsg);
    itemUpdReady(index, "ERR", showdet);
}

function lastActivityToList(index) {
    var trackid = historyModel.get(index).title;
    var db = dbConnection();
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('SELECT * FROM shipdets WHERE trackid = ? AND type = \"EVT\" ORDER BY datetime DESC LIMIT 1;', [trackid]);
            var det;
            if (rs.rows.length > 0) {
                det = rs.rows.item(0).label;
                if (rs.rows.item(0).value !== null && rs.rows.item(0).value !== "") {
                    det = det + " " + rs.rows.item(0).value;
                }
            }
            else {
                var rs = tx.executeSql('SELECT statusstr FROM history WHERE trackid = ?;', [trackid]);
                if (rs.rows.length > 0) {
                    det = rs.rows.item(0).statusstr;
                }
            }

            historyModel.set(index, {"det": det, "datetime": rs.rows.item(0).datetime});
        }
    );
}

function saveitem(index) {
    var type = historyModel.get(index).type;
    var trackid = historyModel.get(index).title;
    var timestamp = historyModel.get(index).datetime;
    var itemdescr = historyModel.get(index).itemdescr;
    var db = dbConnection();
    db.transaction(
        function(tx) {
            var rz = tx.executeSql('INSERT OR IGNORE INTO history (trackid) VALUES (?);', [trackid]);
            var rs = tx.executeSql('UPDATE history SET type = ?, timestamp = ? WHERE trackid = ?;', [type, timestamp, trackid]);

            //var rs = tx.executeSql('INSERT OR REPLACE INTO history (type, trackid, timestamp, detstr) VALUES (?,UPPER(?),?,?);', [type, trackid, timestamp, itemdescr]);
            //var rs = tx.executeSql('INSERT INTO history (type, trackid, timestamp) VALUES (?,UPPER(?),?) ON DUPLICATE KEY UPDATE type=?,timestamp=?;', [type, trackid, timestamp,type,timestamp]);

            if (rs.rowsAffected > 0) {
                console.log("saved: " + trackid + " [OK]")
            } else {
                console.error("ERROR: Failed to save : " + trackid );
            }
        }
    );
}
