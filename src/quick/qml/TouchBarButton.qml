import QtQuick 2.15

TouchBarFrame {
    property alias text: label.text
    readonly property alias down: mouse.containsPress
    id: button
    property bool defaultButton: false
    width: label.implicitWidth + label.anchors.leftMargin + label.anchors.rightMargin
    height: 30
    color: defaultButton ? (down ? "#31b1f1" : "#0082d7") : (down ? "#7e7e7e" : "#444444")

    signal clicked

    Text {
        id: label
        color: "white"
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 13
            rightMargin: 13
        }
        font.pointSize: 14
    }

    MouseArea {
        id: mouse
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        onClicked: parent.clicked()
    }
}
