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

    property var koodi: koodi

    Component.onCompleted: {
        extramenu.text = "";
        extramenu.url = "";
        resultModel.clear();
        setEventsShown(koodi);
        getdetails(koodi);
    }

    function getdetails(koodi) {
        var db = dbVerConnection();
        db.transaction(
            function(tx) {
                // Fetch the history table data and print out the courier.
                var history = tx.executeSql('SELECT * FROM history WHERE trackid = ?', [koodi]);
                history = history.rows.item(0);
                resultModel.append({"type": "HDR", "label": qsTr("Courier"), "value": qsTr(couriers.getCourierByIdentifier(history.type).name), "datetime": new Date()});

                // Fetch the actual headers and events and print them out.
                var rs = tx.executeSql('SELECT * FROM shipdets WHERE trackid = ? ORDER BY datetime DESC', [koodi]);
                //uid,trackid, type, datetime, label, value, status
                for (var i = 0; i < rs.rows.length; i++) {
                    resultModel.append({"type": rs.rows.item(i).type, "label": getHeader(rs.rows.item(i).label), "value": rs.rows.item(i).value, "datetime": convertDateBack(rs.rows.item(i).datetime)});
                }
                if (i == 0) {
                    resultModel.append({"type": "ERR", "label": qsTr("No items were found with the item code you provided"), "value" : qsTr("This may be due to one of the following reasons:
– Check the item code you entered. Make sure it is entered without spaces.
– The item has not yet been handed in for delivery.
– The item has not yet been entered in the system.
– The item was posted long time ago and has been already removed from couriers system
– There is a problem with the system or the item") });
                }
            }
        );
    }

    function getHeader(label) {
        switch (label) {
            case "hdr_shipid":
                return qsTr("Shipping ID");
                break;
            case "hdr_service":
                return qsTr("Service");
                break;
            case "hdr_numberof":
                return qsTr("Number of items");
                break;
            case "hdr_sender":
                return qsTr("Sender");
                break;
            case "extraServices":
                return qsTr("Extra services");
                break;
            case "destinationCity":
                return qsTr("Destination");
                break;
            case "size":
                return qsTr("Size");
                break;
            case "weight":
                return qsTr("Weight");
                break;
            case "codAmount":
                return qsTr("CoD amount");
                break;
            case "estimatedDeliveryTime":
                return qsTr("Estimated delivery");
                break;
            case "nextStep":
                return qsTr("Next step");
                break;
            default:
                return label;
        }
    }

    SilicaListView {
        id: lista
        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Shipment details")
        }
        PullDownMenu {
            MenuItem  {
                property string url : ""
                property string textAbove : ""
                visible: extramenu.text!="" && url!=""
                id: extramenu
                text: ""
                onClicked: {
                    Qt.openUrlExternally(url);
                }
                Text {
                    font.pixelSize: Theme.fontSizeSmall
                    anchors.verticalCenter: parent.top;
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryColor;
                    text: extramenu.textAbove
                }
            }
            MenuItem  {
                text: qsTr("Show barcode")
                onClicked: {
                    var props = {
                        "koodi": koodi
                    };
                    pageStack.push("BarCodePage.qml", props);
                }
            }
        }

        model: ListModel {
            id: resultModel
            ListElement {
                type: ""
                label: ""
                value: ""
                datetime: ""
            }
        }

        delegate: ListItem {
            id: listItem
            height: type=="HDR" ? hdrRect.height : eventRect.height
            contentHeight: height
            width: parent.width
            enabled: false

            Rectangle {
                width: parent.width-Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                visible: type=="ERR"
                Label {
                    id: errLabel
                    text: label
                    font.pixelSize: Theme.fontSizeLarge
                    wrapMode: Text.WordWrap
                    color: Theme.primaryColor
                    width: parent.width
                    height: contentHeight + 40
                }
                Label {
                    text: value
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                    color: Theme.secondaryColor
                    width: parent.width
                    anchors.top: errLabel.bottom
                }
            }

            Rectangle {
                id: hdrRect
                height: hdValue.contentHeight
                color: "transparent"
                visible: type == "HDR"
                width: parent.width-Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: hdLabel
                    text: label + ": "
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                }
                Text {
                    id: hdValue
                    text: value
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.primaryColor
                    anchors.left: hdLabel.right
                    wrapMode: Text.WordWrap
                    width: parent.width - hdLabel.width
                }
            }

            Rectangle {
                id: eventRect
                height: erotin.height + spaceri.height
                color: "transparent"
                visible: type == "EVT"
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    id: spaceri
                    width: parent.width
                    height: 10
                    color: "transparent"
                }
                Rectangle {
                    id: erotin
                    width: parent.width
                    color: Theme.highlightColor
                    opacity: 0.2
                    height: evValue.height + evLabel.contentHeight + erotinText.contentHeight
                    anchors.top: spaceri.bottom
                }
                Text {
                    id: erotinText
                    text: datetime ? datetime : ""
                    //anchors.verticalCenter: erotin.verticalCenter
                    width: parent.width-Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.secondaryColor
                    anchors.top: spaceri.bottom
                    font.pixelSize: Theme.fontSizeSmall
                }
                Text {
                    id: evLabel
                    text: label
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.primaryColor
                    wrapMode: Text.WordWrap
                    anchors.top: erotinText.bottom
                    width: parent.width-Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    id: evValue
                    text: value
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.primaryColor
                    anchors.top: evLabel.bottom
                    wrapMode: Text.WordWrap
                    width: parent.width-Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: text.length>1 ? contentHeight : 0
                }
            }
        }
    }
}
