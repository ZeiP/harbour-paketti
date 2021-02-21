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
    DialogHeader {
        id: header
        acceptText: qsTr("Continue")
    }
    SilicaFlickable {
        anchors.top: header.bottom
        width: parent.width
        contentHeight: mainCol.height
        contentWidth: mainCol.width
        height: Screen.height - header.height
        clip: true

        Column {
            id: mainCol
            anchors.fill: parent
            spacing: Theme.paddingMedium
            // The padding shouldn't be necessary, but otherwise the last sentence gets missing. Fix if you figure out why.
            height: logo.height + appName.height + versionStr.height + updatedStr.height + changelogStr.height + Theme.paddingLarge + Theme.paddingLarge
            width: parent.width
            Image {
                id: logo
                anchors.horizontalCenter: parent.horizontalCenter
                source: "../images/ptl.png"
            }
            Label {
                id: appName
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeHuge
                text: "Paketti"
            }
            Label {
                id: versionStr
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("Version %1").arg(version)
            }
            Label {
                id: updatedStr
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
                id: changelogStr
                anchors.left: parent.left; anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right; anchors.rightMargin: Theme.paddingMedium
                text: qsTr("Changelog version %1:").arg("1.0") +
"\n" + qsTr("– Added new translations for:") +
"\n  " + qsTr("– Dutch – thanks to Heimen Stoffels!") +
"\n" +
"\n" + qsTr("Changelog versions %1 and %2:").arg("0.7").arg("0.8") +
"\n" + qsTr("– Fixed a bug in language selection.") +
"\n" + qsTr("– Made a bunch of fixes and changes to UI and APIs. If you encounter any errors, please open a ticket so they can be fixed for the next release!") +
"\n" + qsTr("– Added La Poste (France) package tracking. Thanks to Adel Noureddine!") +
"\n" + qsTr("– Added DHL package tracking.") +
"\n" + qsTr("– Added new translations for:") +
"\n  " + qsTr("– German – thanks to J. Lavoie!") +
"\n  " + qsTr("– French – thanks to J. Lavoie and S. Fournial!") +
"\n  " + qsTr("– Norwegian – thanks to Allan Nordhøy!") +
"\n  " + qsTr("– Polish – thanks to atlochowski!") +
"\n" + qsTr("… and of course updated existing translations, see the about page for credits.") +
"\n\n" +
qsTr("The maintainer of the application is Jyri-Petteri ”ZeiP” Paloposki.")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        VerticalScrollDecorator {}
    }
}
