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

import "js/helpers.js" as PHelpers
import "js/database.js" as PDatabase

ApplicationWindow {
    id: paketti

    property string version: "0.8.1"
    property string dbName: "pakettidb"
    property string dbDescription: dbName
    property string dbVersion: "1.0"

    ListModel {
        id: couriers

        ListElement {
            name: QT_TR_NOOP("Posti (Finland)")
            identifier: "FI"
            brandColour: "#ff9600"
        }
        ListElement {
            name: QT_TR_NOOP("Matkahuolto (Finland)")
            identifier: "MH"
            brandColour: "#1e00ff"
        }
        ListElement {
            name: QT_TR_NOOP("PostNord (Nordics)")
            identifier: "PN"
            brandColour: "#00a9cd"
        }
        ListElement {
            name: QT_TR_NOOP("Hermes (Germany)")
            identifier: "HERDE"
            brandColour: "#0091cd"
        }
        ListElement {
            name: QT_TR_NOOP("La Poste/Colissimo/Chronopost (France)")
            identifier: "LAPOSTE"
            brandColour: "#f2e435"
        }
        ListElement {
            name: QT_TR_NOOP("DHL")
            identifier: "DHL"
            brandColour: "#D40511"
        }
        function getCourierByIdentifier(identifier) {
            for (var i = 0; i < couriers.count; i++) {
                var value = couriers.get(i);
                if (identifier === value.identifier) {
                    return value;
                }
            }
            console.error("Didn't found the courier being seeked " + identifier);
        }
    }

    function dbConnection() {
        var db = Ls.LocalStorage.openDatabaseSync(dbName, dbVersion, dbDescription);
        db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS history (type, trackid, statusstr, detstr, timestamp, PRIMARY KEY(trackid))');
                tx.executeSql('CREATE TABLE IF NOT EXISTS shipdets (uid NOT NULL UNIQUE, trackid, type, datetime, label, value, status)');
                tx.executeSql('CREATE TABLE IF NOT EXISTS settings (id NOT NULL UNIQUE, value)');
                tx.executeSql('CREATE TABLE IF NOT EXISTS version (vstr, date, PRIMARY KEY(vstr))');
            }
        );
        return db;
    }

    function chkNewVersion(str) {
        var db = dbConnection();
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

    initialPage: Component { MainPage { } }

    ListModel {
                id: historyModel
                ListElement {title: ""; itemdesc: ""; det: " " ; type: "" ; itmrun: "" ; itmcolor: "" ; typec: "" ; datetime: "fuu" ; status: 0}
            }

    property var runningUpdates: 0

    Component.onCompleted: {
        if (chkNewVersion(version)) {
            pageStack.push("pages/UpdatedPage.qml");
        }
        PDatabase.storeVersion(version);
    }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")
}
