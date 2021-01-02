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
    id: bcpage
    property var code: code
    property bool inverted: false

    FontLoader {
        id: bcFont;
        source: "../fonts/free3of9.ttf"
    }

    Rectangle {
        id: barcodeCanvas
        rotation: 90
        width: bcpage.height
        height: bcpage.width
        anchors.horizontalCenter:  bcpage.horizontalCenter
        anchors.verticalCenter: bcpage.verticalCenter

        Text {
            text: qsTr("Read the barcode by keeping barcode scanner perpendicular to the viewing screen, about 15–20 cm away from your phone. If you can not read code try to change distance.")
            color: "#565656"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingMedium
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            id: code1
            text: "*" + code + "*"
            font.family: bcFont.name
            color: "black"
            font.pixelSize: 120 //Was 92
            //scale:
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.verticalCenter
            height: contentHeight-1
        }
        Component.onCompleted: {
            var fontSize = 120;
            if (code1.paintedWidth > (barcodeCanvas.width - 50)) {
                fontSize = 120 * ((barcodeCanvas.width - 50) / code1.paintedWidth);
            }
            code1.font.pixelSize = fontSize;
            code2.font.pixelSize = fontSize;
        }
        Text {
            id: code2
            text: "*" + code + "*"
            font.family: bcFont.name
            color: "black"
            font.pixelSize: 120 //Was 92
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: code1.bottom
        }
        Text {
            id: codeText
            text: code
            color: "black"
            font.pixelSize: 50
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: code2.bottom
        }
    }
}
