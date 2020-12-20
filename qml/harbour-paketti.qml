/*
Copyright (C) 2014 Juhana Virkkala <juhana.virkkala@toimii.fi>
Changes copyright (C) 2020 Jyri-Petteri Paloposki <jyri-petteri.paloposki@iki.fi>

  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import QtQuick.LocalStorage 2.0 as Ls

ApplicationWindow {
    id: paketti

    property string version: "0.7"
    property string dbName: "pakettidb"
    property string dbDescription: dbName
    property string dbVersion: "1.0"

    ListModel {
        id: couriers

        ListElement {
            name: QT_TR_NOOP("Posti (Finland)")
            identifier: "FI"
        }
        ListElement {
            name: QT_TR_NOOP("Matkahuolto (Finland)")
            identifier: "MH"
        }
        ListElement {
            name: QT_TR_NOOP("PostNord (Nordics)")
            identifier: "PN"
        }
        ListElement {
            name: QT_TR_NOOP("Hermes (Germany)")
            identifier: "HERDE"
        }
        ListElement {
            name: QT_TR_NOOP("La Poste/Colissimo/Chronopost (France)")
            identifier: "LAPOSTE"
        }
        ListElement {
            name: QT_TR_NOOP("DHL")
            identifier: "DHL"
        }

        function getCourierByIdentifier(identifier) {
            for (var i = 0; i < couriers.count; i++) {
                var value = couriers.get(i);
                if (identifier === value.identifier) {
                    return value;
                }
            }
        }
    }

    function getLocale(allowedLocales) {
        var i = 0;
        var qtLocale = Qt.locale().name.substring(0, 2);
        // Array.includes() would be cleaner, but didn't work for me.
        while (i < allowedLocales.length){
            if (allowedLocales[i++] == qtLocale) {
                return qtLocale;
            }
        }
        return allowedLocales[0];
    }

    function dbConnection() {
        var db = Ls.LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription);
        db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS history (type, trackid, statusstr, detstr, timestamp, PRIMARY KEY(trackid))');
                tx.executeSql('CREATE TABLE IF NOT EXISTS shipdets (uid NOT NULL UNIQUE, trackid, type, datetime, label, value, status)');
                tx.executeSql('CREATE TABLE IF NOT EXISTS settings (id NOT NULL UNIQUE, value)');
            }
        );
        return db;
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

    function dbVerConnection() {
        var db = Ls.LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription);
        db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS version (vstr, date, PRIMARY KEY(vstr))');
            }
        );
        return db;
    }

    function chkNewVersion(str) {
        var db = dbVerConnection();
        var tmphit = false;
        var tothit = 0;
        db.transaction(
            function(tx) {
                var rs = tx.executeSql('SELECT * FROM version ORDER BY vstr');
                tothit = rs.rows.length;
                for (var i = 0; i < rs.rows.length; i++) {
                    if (rs.rows.item(i).vstr == str) {
                        tmphit = true;
                    }
                }
            }
        );
        if (tmphit == false && tothit > 0) {
            return true;
        }
        else {
            return false;
        }
    }

    function storeVersion(str) {
        var db = dbVerConnection();
        db.transaction(
            function(tx) {
                tx.executeSql('INSERT OR REPLACE INTO version (vstr) VALUES (?);', [str]);
            }
        );
    }

    function convertDate(inputdate) {
        inputdate = inputdate.replace(/[a-z]/gmi," ");
        inputdate = inputdate.replace(/,/gmi,"");
        inputdate = inputdate.replace(/[\ ]{2,100}/gm," ");
        inputdate = inputdate.replace(/\ /gm,".");
        inputdate = inputdate.replace(/:/gm,".");
        var biitit = inputdate.split(".");
        var tmpdate = new Date();
        if (biitit.length > 4) {
            tmpdate.setFullYear(biitit[2]);
            tmpdate.setMonth(biitit[1]-1);
            tmpdate.setDate(biitit[0]);
            tmpdate.setHours(biitit[3]);
            tmpdate.setMinutes(biitit[4]);
            tmpdate.setSeconds(0);
        } else {
            tmpdate.setFullYear("1970"); // If date fetch fails use year 1970 :)
        }
        return(tmpdate);
    }

    function convertIsoDate(inputdate) {
        // 2013-10-04T12:04:00 , Date.parse is not working as that stores time as UTC
        inputdate = inputdate.replace(/T/gm,".");
        inputdate = inputdate.replace(/-/gm,".");
        inputdate = inputdate.replace(/:/gm,".");
        var biitit = inputdate.split(".");
        var tmpdate = new Date(Date.parse(inputdate));
        if (biitit.length > 4) {
            tmpdate.setFullYear(biitit[0]);
            tmpdate.setMonth(biitit[1]-1);
            tmpdate.setDate(biitit[2]);
            tmpdate.setHours(biitit[3]);
            tmpdate.setMinutes(biitit[4]);
            tmpdate.setSeconds(biitit[5]);
        } else {
            tmpdate.setFullYear("1970"); // If date fetch fails use year 1970 :)
        }
        return(tmpdate);
    }

    function convertDateBack(inputdate) {
        var tmpdate = new Date();
        tmpdate.setFullYear(inputdate.substring(0, 4));
        tmpdate.setMonth(inputdate.substring(4, 6)-1);
        tmpdate.setDate(inputdate.substring(6, 8));
        tmpdate.setHours(inputdate.substring(8, 10));
        tmpdate.setMinutes(inputdate.substring(10, 12));
        tmpdate.setSeconds(inputdate.substring(12, 14));
        var outputdate = Qt.formatDateTime(tmpdate, "dd.MM.yyyy  HH:mm");
        return(outputdate);
    }

    initialPage: Component { MainPage { } }

    Component.onCompleted: {
        if (chkNewVersion(version)) {
            pageStack.push("pages/UpdatedPage.qml");
        }
        storeVersion(version);
    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
}
