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
    id: aboutpage
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainCol.height + Theme.paddingLarge + noteCol.height

        Column {
            id: mainCol
            spacing: Theme.paddingMedium
            anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
            PageHeader {
                title: qsTr("About")
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../images/ptl.png"
            }

            Column {
                anchors.left: parent.left; anchors.right: parent.right
                spacing: Theme.paddingSmall
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeHuge
                    text: qsTr("Paketti")
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    wrapMode: Text.WordWrap
                    text: qsTr("Version")+ " " + version
                }
                Label {
                    anchors.left: parent.left; anchors.right: parent.right
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryColor
                    wrapMode: Text.WordWrap
                    text: qsTr("Thanking:") + "
– Juhana Virkkala (original version)
– Hannu Hirvonen (Swedish translation)
– Jyri-Petteri Paloposki (update in 2020)"
                }
            }

            Label {
                wrapMode: Text.WordWrap
                anchors.left: parent.left; anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                text: qsTr("Paketti is a simple shipment tracking application for SailfishOS. You can track the Finnish postal service (Posti), Matkahuolto and MyPack (Postnord) packages.")
            }
        }

        Column {
            id: noteCol
            anchors.top: mainCol.bottom
            anchors.topMargin: Theme.paddingLarge
            anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                anchors.left: parent.left; anchors.right: parent.right
                font.pixelSize: Theme.fontSizeExtraSmall
                text: qsTr("Application author does not take any responsibility in case application will provide non-valid information. The application is not official application for couriers (Posti, Courier, MyPack / Postnord).")
                color: Theme.secondaryColor
            }
        }
/*
        Column {
            id: nappulaCol
            anchors.top: mainCol.bottom; anchors.topMargin: Theme.paddingLarge
            anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium

                Button {
                    //anchors.left: parent.left; anchors.right: parent.right
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("about_donate")
                    onClicked: Qt.openUrlExternally(donate_url)
                }
        }
*/
        VerticalScrollDecorator {}
    }
}
