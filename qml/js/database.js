function addDesc(trackid,descr) {
    var db = dbConnection();
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('UPDATE history SET detstr = ? WHERE trackid = ?;', [descr, trackid]);
        }
    );
}

function getDesc(trackid) {
    var db = dbConnection();
    var status = "NULL";
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('SELECT detstr FROM history WHERE trackid = ?;', [trackid]);
            if (rs.rows.item(0).detstr != "") {
                status = rs.rows.item(0).detstr;
            }
        }
    );
    return(status);
}

function getLatestEvt(trackid) {
    var db = dbConnection();
    var status = 1;
    var retArr = {"label": "Ei tietoja..", "value": "Null"};
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('SELECT * FROM shipdets WHERE trackid = ? AND type = "EVT" ORDER BY datetime DESC LIMIT 1;', [trackid]);
            retArr = rs.rows.item(0);
        }
    );

    return(retArr);
}

function getNewestEvt() {
    var db = dbConnection();
    var status = 1;
    var retArr = {"label": "Ei tietoja..", "value": "Null"};
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('SELECT * FROM shipdets WHERE type = "EVT" ORDER BY datetime DESC LIMIT 1;');
            retArr = rs.rows.item(0);
        }
    );

    return(retArr);
}

function getStatus(trackid) {
    var db = dbConnection();
    var status = 1;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('SELECT status FROM shipdets WHERE type = "EVT" AND trackid = ?;', [trackid]);
            for(var i = 0; i < rs.rows.length; i++) {
                if (rs.rows.item(i).status == "0") {
                    status = 0;
                }
            }
        }
    );
    return(status);
}

function storeVersion(str) {
    var db = dbConnection();
    db.transaction(
        function(tx) {
            tx.executeSql('INSERT OR REPLACE INTO version (vstr) VALUES (?);', [str]);
        }
    );
}

function setLastUpd() {
    var db = dbConnection();
    var unixtime = Math.round(Date.now()/1000);
    db.transaction(
        function(tx) {
            tx.executeSql('INSERT OR REPLACE INTO settings (id, value) VALUES ("lastupd", ?);', [unixtime]);
        }
    );
}

function showSinceLastUpd() {
    var db = dbConnection();
    var unixtime = Math.round(Date.now()/1000);
    var ret = "";
    var unixlupd = 0;
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('SELECT * FROM settings WHERE id = "lastupd"');
            if (rs.rows.length > 0) {
                unixlupd=rs.rows.item(0).value;
            }
        }
    );
    if (unixlupd > 0) {
        var tdiff = unixtime-unixlupd;
        if (tdiff < 60 ) {
            ret = qsTr("less than minute ago");
        }
        else if (tdiff < 3600) {
            ret = qsTr("%n minute(s) ago", "", Math.floor(tdiff/60));
        }
        else {
            ret = qsTr("%n hour(s) ago", "", Math.floor(tdiff/3600));
        }
    }
    return(ret);
}

function insertShipdet(trackid, sdetType, sdetDatetime, sdetArrLabel, sdetArrValue) {
    var db = dbConnection();
    var md5 = Qt.md5(trackid+sdetArrValue+sdetDatetime);
    db.transaction(
        function(tx) {
            var vals = [md5, trackid, sdetType, sdetDatetime, sdetArrLabel, sdetArrValue, 0];
            tx.executeSql('INSERT OR IGNORE INTO shipdets (uid, trackid, type, datetime, label, value, status) VALUES (?, ?, ?, ?, ?, ?, ?);', vals);
        }
    );
}

function setEventsShown(trackid) {
    var db = dbConnection();
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('UPDATE shipdets SET status = 1 WHERE trackid = ?;', [trackid]);
        }
    );
}

function setStatus(trackid, str) {
    var db = dbConnection();
    db.transaction(
        function(tx) {
            var rs = tx.executeSql('UPDATE history SET statusstr = ? WHERE trackid = ?;', [str, trackid]);
        }
    );
}
