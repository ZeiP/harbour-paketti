/*
  Copyright (C) 2014 Juhana Virkkala <juhana.virkkala@toimii.fi>

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
import "../pages/plug_itella.js" as PlugItella
import "../pages/plug_mh.js" as PlugMH
import "../pages/plug_pn.js" as PlugPN

CoverBackground {
    id: tausta
    property var bcount: 0
    property int _lastTick: 0;

    function itemUpdStarted(index) {
        pimpula.visible = true;
        bcount = bcount + 1;
    }

    function itemUpdReady(index, okStr, showdet) {
        addLatestEvent();
        bcount = bcount-1;
        if (bcount == 0) {
            pimpula.visible = false
        }
    }

    onStatusChanged: {
        if (status == Cover.Active) {
            addLatestEvent();
            lupdText.text = showSinceLastUpd();
        }
    }

    //Component.onCompleted: {
    //    addLatestEvent();
    //}
    Component.onCompleted: {
        lupdText.text = showSinceLastUpd();
    }

    function addLatestEvent() {
        var newestEvt = getNewestEvt();
        if (newestEvt) {
            var detstr = getDesc(newestEvt.trackid);
            if (detstr != "NULL" && detstr) {
                coverlabel.text = detstr;
            }
            else {
                coverlabel.text = newestEvt.trackid;
            }
            coverElabel.text = newestEvt.label;
            if (newestEvt.value !== null) {
                coverEvalue.text=newestEvt.value;
            }
            dtime.text = convertDateBack(newestEvt.datetime);

            if (newestEvt.status == 0) {
                notifyimage.visible = true;
                coverElabel.font.bold = true;
            }
            else {
                notifyimage.visible = false;
                coverElabel.font.bold = false;
            }
        }
        else {
            coverlabel.text = "";
            coverElabel.text = "";
            coverEvalue.text = "";
            dtime.text = "";
        }
    }

    function refreshAll() {
        var db = dbConnection();
        db.transaction(
            function(tx) {
                var rs = tx.executeSql('SELECT * FROM history ORDER BY timestamp DESC;');
                for (var i = 0; i < rs.rows.length; i++) {
                    var trackid = rs.rows.item(i).trackid;
                    if (rs.rows.item(i).type == "FI") {
                        PlugItella.updatedet(0, trackid, 0);
                    }
                    else if (rs.rows.item(i).type == "MH") {
                        PlugMH.updatedet(0, trackid, 0);
                    }
                    else if (rs.rows.item(i).type == "PN") {
                        PlugPN.updatedet(0, trackid, 0);
                    }
                }
            }
        );

        addLatestEvent();
        setLastUpd();
        lupdText.text = showSinceLastUpd();
    }

    Image {
        id: notifyimage
        source: "../images/nurkka2.png"
        anchors.top: parent.top
        anchors.right: parent.right
        visible: false
    }
    Image {
        id: coverimage
        source: "../images/cover_trans.svg"
        opacity: 0.1
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: parent.height
    }
    GlassItem {
        id: pimpula
        color:  "yellow"
        height: 40
        width: height
        cache: false
        anchors.top: tausta.top
        anchors.left: tausta.left
        radius: 3
        falloffRadius: 0.2
        visible: false
    }
    Rectangle {
        id: evtTausta
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        width: parent.width - (Theme.paddingSmall*2)
        anchors.left: parent.left
        anchors.right: parent.right

        Text {
            id: coverlabel
            anchors.topMargin: 45
            font.pixelSize: Theme.fontSizeSmall
            anchors.left: evtTausta.left
            color: Theme.secondaryColor
                //Theme.highlightColor
            width: parent.width
            anchors.top: parent.top
        }
        OpacityRampEffect {
            id: titleEffect
            slope: 40
            offset: 0.95
            direction: OpacityRamp.LeftToRight
            sourceItem: coverlabel
        }
        Text {
            id: dtime
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            anchors.top: coverlabel.bottom
            font.bold: coverElabel.font.bold
        }
        Text {
            id: coverElabel
            font.pixelSize: Theme.fontSizeMedium
            //font.bold: true
            wrapMode: Text.WordWrap
            maximumLineCount: 4
            color: Theme.primaryColor
            width: parent.width
            anchors.top: dtime.bottom
        }
        Text {
            id: coverEvalue
            font.pixelSize: Theme.fontSizeTiny
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            color: Theme.highlightColor
            width: parent.width
            anchors.top: coverElabel.bottom
        }
    }
    Text {
        id: lupdText
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
        text: showSinceLastUpd()
    }
    Timer {
        id: lupdtimer
        running: (status === Cover.Active)
        repeat: true
        interval: 5000
        onTriggered: {
            lupdText.text = showSinceLastUpd();
        }
    }
    Timer {
        id: updTimer
        running: true
        interval: 5000
        repeat: true
        onTriggered: {
            var now = Math.round(Date.now()/1000);
            if (_lastTick != 0 ) {
                var seconds = now - _lastTick;
            }
            else {
                _lastTick = now;
                seconds = 0;
            }
            if (seconds > 900) {
                refreshAll();
                _lastTick = now;
            }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            id: ract
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: refreshAll()
        }
    }
}


