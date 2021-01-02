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
                text: qsTr("Changelog version 0.8:
– Added new translations for:
  – Polish – thanks to atlochowski!
– Made a bunch of fixes and changes to UI and APIs. If you encounter any errors, please open a ticket so they can be fixed for the next release!

Changelog versions 0.7 and 0.7.1:
– Added La Poste (France) package tracking. Thanks to Adel Noureddine!
– Added DHL package tracking.
– Fixed some minor UI and API handling bugs.
– Added new translations for:
  – German – thanks to J. Lavoie!
  – French – thanks to J. Lavoie and S. Fournial!
  – Norwegian – thanks to Allan Nordhøy!
... and of course updated existing translations, see the about page for credits.

The maintainer of the application is Jyri-Petteri ”ZeiP” Paloposki.")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
