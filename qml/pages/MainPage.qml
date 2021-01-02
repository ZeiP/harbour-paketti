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

import "../js/helpers.js" as PHelpers
import "../js/database.js" as PDatabase
import "../js/apidata.js" as PAPIData

import "../js/couriers/posti.js" as PlugPosti
import "../js/couriers/matkahuolto.js" as PlugMH
import "../js/couriers/postnord.js" as PlugPN
import "../js/couriers/herde.js" as PlugHerDe
import "../js/couriers/laposte.js" as PlugLaPoste
import "../js/couriers/dhl.js" as PlugDHL

import harbour.org.paketti 1.0

Page {
    id: mainpage
    property var lastupd

    Connections {
        target: paketti
        onApplicationActiveChanged: {
            if (paketti.applicationActive) {
                PAPIData.reloadhistory(false);
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            mainpage.forceActiveFocus();
            //Qt.inputMethod.hide();
            PAPIData.reloadhistory(false);
        }
    }

    Component.onCompleted: {
        PAPIData.reloadhistory(true);
    }

    property bool historyvisible: historyvisible;
    property bool cautoset: false;
    property variant currentCourier: "";

    SilicaListView {
        id: lista
        anchors.fill: parent

        PullDownMenu {
            id: pdmenu
            property bool updsel: false
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push("AboutPage.qml");
            }
            MenuItem {
                text: qsTr("Update")
                //onClicked: updateData()
                onClicked: pdmenu.updsel = true
            }
            onStateChanged: {
                if (pdmenu.state != "expanded" && updsel == true) {
                    PAPIData.updateData();
                }
                updsel = false;
            }
        }
        header: PageHeader {
            id: phead
            title: qsTr("Track item")
        }
        model: historyModel
        delegate: ListItem {
            contentHeight: index==0 ? trackForm.height : hitemrow.height+10
            id: listitem
            menu: contextMenu
            width: index==0 ? 0 : parent.width
            onClicked: {
                historyModel.set(index, {"status": 1});
                var props = {
                    "code": title
                };
                if (index != 0) {
                    pageStack.push("Details.qml", props);
                }
            }
            onPressed: {
                if (index != 0) {
                    listitem.forceActiveFocus();
                    PDatabase.setEventsShown(historyModel.get(index).title);
                    historyModel.set(index, {"status": PDatabase.getStatus(historyModel.get(index).title)});
                }
            }
            ListView.onRemove: animateRemoval(listitem)

            function remove(title) {
                remorseAction(qsTr("Deleting"), function() {
                    lista.model.remove(index);
                    PAPIData.deleteitm(title);
                }, 3000);
            }
            ProgressBar {
                width: parent.width
                //indeterminate: true
                //label: "Indeterminate"
                id: itmBusyIndicator
                indeterminate: itmrun=="true" ? true : false
                visible: itmrun=="true" ? true : false
                //onDataChanged: console.log("Changed..")
            }
            Rectangle {
                id: trackForm
                color: "transparent"
                visible: index==0
                width: lista.width
                height: courier.height + historyhead.height + codeField.height
                onHeightChanged: {
                    if (index == 0) {
                        listitem.height = trackForm.height
                    }
                }

                ComboBox {
                    anchors.bottom: codeBox.top
                    id: courier
                    width: parent.width
                    label: qsTr("Courier") + ": "
                    value: qsTr("Select")
                    description: qsTr("The courier is autoselected when entering a tracking code if possible.")

                    menu: ContextMenu {
                        Repeater {
                            model: couriers
                            MenuItem {
                                text: qsTranslate("main", model.name)
                                onClicked: {
                                    courier.setValueByIdentifier(identifier);
                                }
                            }
                        }
                        onClicked: {
                            cautoset = false;
                            courier.valueColor = Theme.highlightColor;
                            codeField.forceActiveFocus();
                        }
                    }

                    function setValueByIdentifier(identifier) {
                        var courierdata = couriers.getCourierByIdentifier(identifier);
                        courier.value = courierdata.name
                        courier.valueColor = Theme.highlightColor
                        mainpage.currentCourier = identifier
                    }

                    function setEmptyValue() {
                        courier.value = qsTr("Select")
                        mainpage.currentCourier = ""
                    }

                    function isEmpty() {
                        return (courier.value == qsTr("Select"));
                    }
                }

                Rectangle {
                    id: codeBox
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    anchors.bottom: historyhead.top
                    height: codeField.height
                    color: "transparent"
                    //color: "#000000"

                    //Search
                    TextField {
                        id: codeField
                        font.pixelSize: Theme.fontSizeLarge
                        onActiveFocusChanged: {
                            if (codeField.focus == true) {
                                Qt.inputMethod.show();
                            }
                            else {
                                Qt.inputMethod.hide();
                            }
                        }
                        width: parent.width-enterIcon.width
                        inputMethodHints: Qt.ImhNoPredictiveText // Qt.ImhPreferUppercase | Qt.ImhNoAutoUppercase
                        placeholderText: qsTr("Enter tracking code")
                        validator: RegExpValidator { regExp: /^[0-9a-z]{5,100}$/i }
                        anchors.left: parent.left
                        onTextChanged: {
                            var cauto = PHelpers.detectCourierByTrackingCode(text);
                            if (cauto && courier.isEmpty()) {
                                cautoset = true;
                                courier.setValueByIdentifier(cauto);
                            }
                            // The courier was previously auto-set, but the code no longer matches.
                            else if (!cauto && cautoset === true) {
                                cautoset = false;
                                courier.setEmptyValue();
                            }

                            // Remind the user of setting the courier.
                            if (courier.isEmpty() && text.length != 0) {
                                courier.valueColor = "red"
                            }
                            else {
                                courier.valueColor = Theme.highlightColor
                            }
                        }

                        EnterKey.enabled: !courier.isEmpty() && text.length > 4
                        EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                        EnterKey.highlighted: true
                        EnterKey.onClicked: trackForm.submitTracking()
                    }
                    IconButton {
                        id: enterIcon
                        icon.source: "image://theme/icon-m-enter-accept"
                        anchors.right: parent.right
                        onClicked: trackForm.submitTracking()
                        enabled: !courier.isEmpty() && codeField.text.length > 4
                    }
                }
                SectionHeader {
                    anchors.bottom: parent.bottom
                    id: historyhead
                    text: qsTr("History");
                    visible: historyvisible
                }
                Label {
                    id: historytip
                    width: parent.width - (Theme.paddingMedium*2)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: codeBox.bottom
                    text: "<br>" + qsTr("Start by choosing a courier and entering the tracking code in the box above. Tracked shipments will be saved automatically")
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeLarge
                    wrapMode: Text.WordWrap
                    visible: !historyvisible
                }

                function submitTracking() {
                    PAPIData.addTrackable(mainpage.currentCourier, codeField.text);
                    codeField.text = "";
                    courier.setEmptyValue();
                }
            }

            Rectangle {
                property bool menuOpen: contextMenu != null && contextMenu.parent === hitemrow
                id: hitemrow
                width: parent.width
                height: menuOpen ? hdet.height + htitle.height + descLabel.height + contextMenu.height : hdet.height + htitle.height + descLabel.height
                //height: contextMenu.active==true ? hdet.height + htitle.height + contextMenu.height : hdet.height + htitle.height
                color: "transparent"
                visible: index!=0

                Rectangle {
                    id: erotint
                    color: Theme.highlightColor
                    opacity: status == 0 ? 0.6 : 0.2
                    height: listitem.height - 10
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Rectangle {
                    id: erotin
                    color: typec == null ? Theme.highlightColor : typec
                    height: listitem.height - 10
                    width: Theme.paddingMedium
                    anchors.left: erotint.left
                }
                OpacityRampEffect {
                    id: effect
                    slope: 2
                    offset: 0.2
                    direction: OpacityRamp.LeftToRight
                    sourceItem: erotin
                }
                GlassItem {
                    id: pimpula
                    color:  itmcolor == null ? Theme.primaryColor : itmcolor
                    height: 40
                    width: height
                    cache: false
                    anchors.verticalCenter: htitle.verticalCenter
                    anchors.right: erotint.right
                    radius: 3
                    falloffRadius: 0.2
                }
                Text {
                    id: timefield
                    text: PHelpers.convertDateBack(datetime)
                    anchors.verticalCenter: htitle.verticalCenter
                    anchors.right: pimpula.left
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    visible: det != "NAN"
                }

                Label {
                    width: parent.width - (Theme.paddingMedium*2)
                    id: htitle
                    text: title
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingMedium
                    font.capitalization: Font.AllUppercase
                    //width: parent.width - (Theme.paddingMedium*2) - timefield.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: erotin.top
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                }

                OpacityRampEffect {
                    //TODO: RampEffect size shoud follow screen width/available space
                    id: titleEffect
                    slope: 20
                    offset: 0.5
                    direction: OpacityRamp.LeftToRight
                    sourceItem: htitle
                }
                Label {
                    id: descLabel
                    text: itemdesc
                    anchors.top: htitle.bottom
                    width: parent.width - (Theme.paddingMedium*2)
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.primaryColor
                    height: itemdesc == "" ? 0 : descLabel.contentHeight
                }
                Label {
                    id: hdet
                    anchors.top: descLabel.bottom
                    width: parent.width - (Theme.paddingMedium*2)
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: det == "NAN" ? "<i>" + qsTr("No information available") + "</i>" : det
                    wrapMode: Text.WordWrap
                }

                Component {
                    id: contextMenu
                    ContextMenu {
                        //ContextMenu.onEnabled: Qt.inputMethod.hide();
                        MenuItem {
                            text: itemdesc == "" ? qsTr("Add description") : qsTr("Modify description")
                            onClicked: pageStack.push("DescDialog.qml", {"trackid": title, "description": itemdesc});
                        }
                        MenuItem {
                            text: qsTr("Show barcode")
                            onClicked: pageStack.push("BarCodePage.qml", {"code": title});
                        }
                        MenuItem {
                            text: qsTr("Copy tracking number")
                            onClicked: Clipboard.text = title
                        }
                        MenuItem {
                            text: qsTr("Copy text")
                            onClicked: Clipboard.text = title + " " + timefield.text + "\n" + hdet.text
                        }
                        MenuItem {
                            text: qsTr("Remove item")
                            onClicked: remove(title)
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
