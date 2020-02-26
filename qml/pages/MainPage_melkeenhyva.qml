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




Page {
    id: page
    anchors.fill: parent

    onStatusChanged: {
             if (status == PageStatus.Active) {
                 koodiInput.text="";
                 courier.currentIndex=0;
                 Qt.inputMethod.hide();
             }
    }

    Component.onCompleted: {
        reloadhistory();
    }


    function updatedet(index) {

        historyModel.set(index,{"itmrun": "true" });
        historyModel.set(index,{"itmcolor": "yellow"});
        var trackid=historyModel.get(index).title;

        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {

                var active=0;
                var header="";
                var det="";
                var hdata="";
                var phactive=0;

                var rivit=doc.responseText.split("\n");
                for (var ii = 0; ii < rivit.length; ++ii) {
                    var rivi=rivit[ii];
                    var riviplain=rivi.replace(/<[^>]+>/gm,"").replace(/&nbsp;/gm,"").replace(/[\ ]{2,100}/gm," ").replace(/\t/gm,"");

                    if (rivi.match("<div class=\"placeholder\">")) phactive=1;
                    if (phactive == 1 && riviplain.length > 2) {
                        if (rivi.match("<h2>")) header=riviplain
                    }
                    if (phactive == 1 && rivi.match("<\/div>")) {
                        phactive=0;
                    }


                    if ( rivi.match("shipment-event-table-cell")) active=1;
                    if ( active == 1 ) {
                        if (rivi.match("shipment-event-table-header") && header=="") header=riviplain;
                        if (rivi.match("shipment-event-table-data") && det=="") {
                                if (!rivi.match("[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{4}")) det=riviplain;
                        }
                        if (rivi.match("<\/td>")) {
                            active=0;
                        }
                    }

                }

                if (doc.status == 200 && header!="") {
                    var str=header + " " + det
                    historyModel.set(index,{"det": str , "itmcolor": "green"});
                    saveitem(index);
                    //saveitem(index);
                } else {
                    if (historyModel.get(index).det=="") historyModel.set(index,{"det": "<i>"+qsTr("error_load")+"..</i>" });
                }

                historyModel.set(index,{"itmrun": "false" });

            }

        }

        doc.open("GET", postiURL(trackid));
        doc.send();

    }

    function updatedetMH(index) {

        historyModel.set(index,{"itmrun": "true" });
        historyModel.set(index,{"itmcolor": "yellow"});
        var trackid=historyModel.get(index).title;
        //var trackid="MH787664393FI";
        var db = dbConnection();
        console.log( mhURL(trackid));

        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {

                var header="";
                var det="";
                var phactive=0;
                var strTapahtu;
                var resultsa=0;
                var retStr;

                var rivit=doc.responseText.split("\n");
                for (var ii = 0; ii < rivit.length; ++ii) {
                    var rivi=rivit[ii];

                    if (rivi.match("<table class=\"result\">")) {
                        phactive=1;
                        resultsa=1;
                    }
                    if (phactive == 1 && rivi.length > 2) strTapahtu=strTapahtu+rivi;
                    if (phactive == 1 && rivi.match("<\/table>")) phactive=0;
                }

                if (resultsa==1) { // If results available
                    var rivit=strTapahtu.split("<\/tr>");
                    for (var ii = 0; ii < rivit.length; ++ii) {
                        var rivi=rivit[ii];
                        var palat=rivi.split("<\/td>");
                        if (palat[2]) var yksplain=palat[0].replace(/<[^>]+>/gm,"").replace(/&nbsp;/gm,"").replace(/[\ ]{2,100}/gm," ").replace(/\t/gm,"").replace(/^\s\s*/, "").replace(/\s\s*$/,"");
                        if (palat[1]) var kaksplain=palat[1].replace(/<[^>]+>/gm,"").replace(/&nbsp;/gm,"").replace(/[\ ]{2,100}/gm," ").replace(/\t/gm,"").replace(/^\s\s*/, "").replace(/\s\s*$/,"");
                        if (yksplain) if (yksplain.match(/^[0-9]{2}\.[0-9]{2}\.[0-9]{2}/)) {
                                // Aikaleima yksplain muuttujassa
                                if (retStr==undefined && kaksplain.length>2) {
                                    //console.log(yksplain+": "+kaksplain)
                                    retStr=kaksplain;
                                }
                        }
                    }
                }

                if (retStr!="") {
                    historyModel.set(index,{"det": retStr , "itmcolor": "green"});
                    saveitem(index);
                    console.log("UPDWWW: " + trackid + " [OK]");
                }
            }

            historyModel.set(index,{"itmrun": "false" });

        }

        doc.open("GET", mhURL(trackid));
        doc.send();

    }

    function deleteitm(trackid) {
        var db = dbConnection();
        db.transaction(
           function(tx) {
               var rs = tx.executeSql('DELETE FROM history WHERE trackid=UPPER(?);', [trackid]);
                    if (rs.rowsAffected > 0) {
                        console.log("Deleted: " + trackid + " [OK]")
                    } else {
                        console.error("ERROR: Failed to delete : " + trackid );
                    }
                }
          );
    }

    function populatedets() {
        for (var i=0; i < historyModel.count; i++) {
            if (historyModel.get(i).title!="") {
                //if (historyModel.get(i).type=="FI") updatedet(i);//,historyModel.get(i).title);
                //if (historyModel.get(i).type=="MH") updatedetMH(i);
                updateitem(i);
                //saveitem(i);
            }
        }
    }

    function updateitem(index) {
        if (historyModel.get(index).type=="FI") updatedet(index);//,historyModel.get(i).title);
        if (historyModel.get(index).type=="MH") updatedetMH(index);
    }

    function addTrackable(type,trackid) {
        if (trackid!="") {
            var index=999;
            historytip.visible=false;
            trackid=trackid.toUpperCase();

            // Check if item is already on historylist, if not add and save to db
            for (var i=0; i < historyModel.count; i++) {
                if (historyModel.get(i).title.toUpperCase() == trackid) index=i
            }
            if (index==999) {
                index=0;
                historyModel.insert(index, { "type": type, "title": trackid , "det": "<i>Ei tilatietoja</i>" });
                saveitem(index);
                updateitem(index);
            } else {
                console.log("Move "+index);
                historyModel.move(index,0,1)
            }

            // Open details page
            var props = { "koodi": trackid };
            pageStack.push("Details.qml", props);

            }
    }


    function reloadhistory() {
        var db = dbConnection();
        var res = [];
        db.transaction(
                function(tx) {
                    var rs = tx.executeSql('SELECT * FROM history ORDER BY timestamp DESC;');
                    for(var i = 0; i < rs.rows.length; i++) {
                        historyModel.set(i, {"type": rs.rows.item(i).type , "title": rs.rows.item(i).trackid , "det": rs.rows.item(i).statusstr });
                        if (rs.rows.item(i).type=="FI") historyModel.set(i, { "typec" : "#ff9600" });
                        if (rs.rows.item(i).type=="MH") historyModel.set(i, { "typec" : "#1e00ff" });
                    }
                    if (rs.rows.length!=0) {
                        historyhead.visible=true;
                        historytip.visible=false;
                    } else{
                        historytip.visible=true;
                        historyhead.visible=false;
                    }
                }
            );
        populatedets();
        return res;
    }

    function saveitem(index) {
        var type=historyModel.get(index).type;
        var trackid=historyModel.get(index).title;
        var statusstr=historyModel.get(index).det;
        var timestamp=Qt.formatDateTime(new Date(), "yyyyMMddHHmmss");
        var db = dbConnection();
        db.transaction(
           function(tx) {
               var rs = tx.executeSql('INSERT OR REPLACE INTO history (type, trackid, timestamp,statusstr) VALUES (?,UPPER(?),?,?);', [type, trackid, timestamp,statusstr]);
                    if (rs.rowsAffected > 0) {
                        console.log("saved: " + trackid + " [OK]")
                    } else {
                        console.error("ERROR: Failed to save : " + trackid );
                    }
                }
          );
    }

    SilicaFlickable {
        id: flicka
        anchors.fill: parent
        contentHeight: column.height// + columnh.height
        height: page.height
        //height: page.height

        PullDownMenu {
            MenuItem {
                text: qsTr("pulldown_about")
                onClicked: pageStack.push("AboutPage.qml");
            }
            MenuItem {
                text: qsTr("pulldown_update")
                onClicked: populatedets()
            }
        }

        Column {
            id: column
            width: parent.width
            //height: courier.height + koodiInput.height + historyhead.height + phead.height + lista.height + footer.height
            PageHeader {
                id: phead
                title: qsTr("track_item")
            }
            ComboBox {
                id: courier
                width: page.width
                label: "Courier"
                currentIndex: 0
                menu: ContextMenu {
                    MenuItem { text: "Select" ; visible: false }
                    MenuItem { text: "Itella" }
                    MenuItem { text: "Matkahuolto" }
                }
            }
            SearchField {
                id: koodiInput
                enabled: courier.currentIndex!=0
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText // Qt.ImhPreferUppercase | Qt.ImhNoAutoUppercase
                label: qsTr("tracking_code")
                placeholderText: qsTr("enter_code")
                validator: RegExpValidator { regExp: /^[0-9a-z]{5,100}$/i }
                anchors.horizontalCenter: parent.horizontalCenter
                //anchors.top: courier.bottom
                EnterKey.enabled: text.length > 4
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    if (courier.currentIndex==1) var cStr="FI"
                    if (courier.currentIndex==2) var cStr="MH"
                    addTrackable(cStr,koodiInput.text);
                }
            }


            Label {
                id: historytip
                width: parent.width - (Theme.paddingMedium*2)
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("first_tip")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
                wrapMode: Text.WordWrap
            }

            SectionHeader {
                id: historyhead
                text: qsTr("history");
            }

     /*   }
        Column {
            id: columnh
            anchors.top: column.bottom
            height: contentHeight
            width: page.width
*/
            Rectangle {
                id: hrect
                height: lista.contentHeight+200
                width: parent.width
                color: "transparent"


            SilicaListView {
                id: lista
                //width: parent.width
                anchors.fill: parent
                /*onContentHeightChanged: {
                    console.log(contentHeight);
                    //columnh.height=contentHeight;
                }*/
                //height: contentHeight

                //height: 900

                model: ListModel {
                    id: historyModel
                    ListElement { title: ""; det: " " ; type: "" ; itmrun: "" ; itmcolor: "" ; typec: ""}
                }
                delegate: ListItem {
                    id: listitem
                    property bool menuOpen: contextMenu != null && contextMenu.parent === listitem
                    menu: contextMenu
                    //contentHeight: (htitle.height+hdet.height) < 90 ? 90 : htitle.height + hdet.height + 10
                    contentHeight: menuOpen ? contextMenu.height + htitle.height + hdet.height + 10 : htitle.height + hdet.height + 10
                    onClicked: {
                         var props = {
                             "koodi": title
                         };
                         pageStack.push("Details.qml", props);
                    }
                    //onPressed: Qt.inputMethod.hide();
                    //ListView.onAdd: saveitem(index);

                    ListView.onRemove: animateRemoval(listitem)
                    visible: title!=""

                    function remove(title) {
                        remorseAction(qsTr("remorse_deleting"), function() {
                            lista.model.remove(index);
                            deleteitm(title);
                        },3000);
                    }

                    Rectangle {
                        id: erotint
                        color: Theme.highlightColor
                        opacity: 0.3
                        height: 40
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Rectangle {
                        id: erotin
                        color: itmcolor == undefined ? Theme.highlightColor : typec
                        //opacity: 0.3
                        //height: erotint.height
                        height: listitem.height-4
                        width: Theme.paddingMedium
                        //anchors.top: erotin.top
                        anchors.left: erotint.left
                        //anchors.horizontalCenter: parent.horizontalCenter
                    }
                    OpacityRampEffect {
                        id: effect
                        slope: 2
                        offset: 0.2
                        direction: OpacityRamp.LeftToRight
                        //direction: OpacityRamp.TopToBottom
                        sourceItem: erotin
                    }
                    GlassItem {
                        id: pimpula
                        color:  itmcolor == undefined ?  Theme.primaryColor : itmcolor
                        height: erotint.height
                        width: height
                        cache: false
                        anchors.top: erotint.top
                        anchors.right: erotint.right
                        radius: 3
                        falloffRadius: 0.2
                    }
                    Label {
                            id: htitle
                            text: title
                            font.capitalization: Font.AllUppercase
                            width: parent.width - (Theme.paddingMedium*2)
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: erotin.top
                            //anchors.left: pimpula.right
                     }
                     Label {
                            id: hdet
                            anchors.top: htitle.bottom
                            width: parent.width - (Theme.paddingMedium*2)
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            text: det
                            wrapMode: Text.WordWrap
                    }
                    BusyIndicator  {
                            id: itmBusyIndicator
                            anchors  { centerIn: parent; verticalCenterOffset: -20 }
                            running: itmrun=="true" ? true : false
                    }
                    Component {
                    id: contextMenu
                        ContextMenu {
                            MenuItem {
                                text: qsTr("context_copy")
                                onClicked: Clipboard.text = title
                            }
                            MenuItem {
                                text: qsTr("context_remove")
                                onClicked: remove(title)
                            }
                        }
                    }

               }

            }

            }




        }
        VerticalScrollDecorator { flickable: flicka }
        //VerticalScrollDecorator {}
        //HorizontalScrollDecorator {}

    }

}
