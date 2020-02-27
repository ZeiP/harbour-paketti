/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
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

Dialog {
    SilicaFlickable {
        anchors.fill: parent

        Column {
            anchors.fill: parent
            spacing: Theme.paddingMedium
            DialogHeader {
                acceptText: qsTr("Continue")
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../images/ptl.png"
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeHuge
                text: "Paketti"
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("Version %1").arg(version)
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                //anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                //anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                text: qsTr("Application updated")
                color: Theme.highlightColor
                font.bold: true
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeMedium
            }
            Label {
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                text: qsTr("Changelog version 0.6:
- Posti and Matkahuolto package tracking fixed and some other minor changes.
– The PostNord tracking couldn't be tested due to lack of tracking code, if you can help add an issue to GitHub.
– The source code for the application is now available in https://github.com/ZeiP/harbour-paketti.

Thanks for the release to Jyri-Petteri ”ZeiP” Paloposki!")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
            }
            /*
            Label {
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                //: A message for asking for donations.
                //% "Please consider a donation to help improving Friends."
                text: qsTr("ws_please_donate")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
            }
            */

            /*
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("ws_donatebutton")
                onClicked: Qt.openUrlExternally(donate_url)
            }*/

        }

    }


}
