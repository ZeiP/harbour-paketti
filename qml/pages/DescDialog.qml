import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property string description
    property string trackid

    Component.onCompleted: {
        descField.forceActiveFocus();
    }

    DialogHeader {
        id: dheader
        //acceptText: qsTr("ws_close")
    }

    Column {
        anchors.top: dheader.bottom
        width: parent.width

        Rectangle {
            height: 100
            width: parent.width
            color: "transparent"
        }

        Label {
            text: qsTr("desctip_text") + " " + trackid
            wrapMode: Text.WordWrap
            width: parent.width - (Theme.paddingLarge*2)
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeMedium
            anchors.horizontalCenter: parent.horizontalCenter
            height: contentHeight+40
        }

        TextField {
            id: descField
            text: description
            anchors.left: parent.left
            placeholderText: qsTr("desc_enter");
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.highlighted: true
        }
    }
    onDone: {
        if (result == DialogResult.Accepted) {
            description=descField.text
            addDesc(trackid,descField.text);
        }
    }
}
