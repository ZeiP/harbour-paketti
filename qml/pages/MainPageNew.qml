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
    SilicaListView {
        id: listView
        model: 20
        anchors.fill: parent
        header: PageHeader {
            id: phead
            title: "Nested Page"
        }
        PullDownMenu {
            MenuItem {
                text: "Ekasivu"
                onClicked: pageStack.push("FirstPage.qml");
            }
        }

        delegate: ListItem {
            property bool menuOpen: contextMenu != null && contextMenu.parent === delegate
            contentHeight: menuOpen ? contextMenu.height + labeli.height : labeli.height
            id: delegate

            Rectangle {
                id: hrect
                visible: index==0
                color: "transparent"
                height: courier.height + teksti.height + koodiInput.height
                width: parent.width
                onHeightChanged: {
                    if (index==0) delegate.height=hrect.height
                }
                ComboBox {
                    id: courier
                    width: page.width
                    label: "Courier"
                    currentIndex: 0
                    menu: ContextMenu {
                        id: cmenu
                        MenuItem { text: "Select" ; visible: false }
                        MenuItem { text: "Itella" }
                        MenuItem { text: "Matkahuolto" }
                    }

                }
                SearchField {
                    id: koodiInput
                    width: parent.width
                    anchors.top: courier.bottom
                    inputMethodHints: Qt.ImhNoPredictiveText // Qt.ImhPreferUppercase | Qt.ImhNoAutoUppercase
                    label: qsTr("tracking_code")
                    placeholderText: qsTr("enter_code")
                    validator: RegExpValidator { regExp: /^[0-9a-z]{5,100}$/i }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                SectionHeader {
                    id: teksti
                    anchors.top: koodiInput.bottom
                    text: qsTr("history");
                }
            }

                Label {
                    id: labeli
                    visible: index!=0
                    x: Theme.paddingLarge
                    text: "Item " + index
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.primaryColor
                }

                menu: contextMenu
                onClicked: console.log("Clicked " + index)
                Component {
                id: contextMenu
                    ContextMenu {
                        MenuItem {
                            text: "Testijuttu"
                            onClicked: Clipboard.text = "yks"
                        }
                        MenuItem {
                            text: "Testijuttu2"
                            onClicked: Clipboard.text = "kaks"
                        }
                        MenuItem {
                            text: "Testijuttu3"
                            onClicked: Clipboard.text = "kolome"
                        }
                    }
                }

        }
        VerticalScrollDecorator {}
    }
}





