import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/database.js" as PDatabase

Dialog {
    property string description
    property string trackid

    SilicaFlickable {
        anchors.fill: parent
        Column {
            anchors.fill: parent
            DialogHeader {
                acceptText: qsTr("Save")
            }
            Label {
                text: qsTr("Enter short description of item %1").arg(trackid)
                wrapMode: Text.WordWrap
                width: parent.width - (Theme.paddingLarge*2)
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                anchors.horizontalCenter: parent.horizontalCenter
                height: contentHeight+40
            }
            TextField {
                width: parent.width
                id: descField
                text: description
                anchors.left: parent.left
                placeholderText: qsTr("Enter description");
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.highlighted: true
            }
        }
    }
    Component.onCompleted: {
        descField.forceActiveFocus();
    }
    onDone: {
        if (result == DialogResult.Accepted) {
            description = descField.text
            PDatabase.addDesc(trackid, descField.text);
        }
    }
}
