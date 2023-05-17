import QtQuick 2.7
import QtQuick.Controls 2.15
import TouchBar 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Dialog {
        id: dialog
        modal: true
        title: "Dialog"
        standardButtons: Dialog.Ok | Dialog.Cancel
        width: 200
        height: 100

        TouchBar {
            visible: dialog.visible
            Row {
                spacing: 8
                width: childrenRect.width
                anchors.horizontalCenter: parent.horizontalCenter

                TouchBarButton {
                    text: "OK"
                    defaultButton: true
                    onClicked: dialog.accept()
                }
                TouchBarButton {
                    text: "Cancel"
                    onClicked: dialog.reject()
                }
            }
        }
    }

    TouchBar {
        id: touchbar
        global: true
        visible: !dialog.visible

        escapeItem: TouchBarButton {
            text: "Cancel"
            onClicked: console.log("esc")
        }

        Row {
            spacing: 8

            TouchBarButton {
                defaultButton: true
                text: "Quak"
                visible: !dialog.visible
                onClicked: dialog.open()
            }

        Rectangle {
            color: "red"
            id: redRect
            width: 120
            height: 30

            Rectangle {
                color: "yellow"
                anchors.fill: parent
                anchors.margins: 1
            }
            Text {
                visible: tbSlider.value > 5
                anchors.centerIn: parent
                text: "Test" + tbSlider.value * 40
            }
        }
        Rectangle {
            id: rect
            color: isBlue ? "blue" : "green"
            width: 30
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            property bool isBlue: true
            MouseArea {
                anchors.fill: parent
                onClicked: console.log(touchbar.width)
                onPressed: parent.isBlue = false
                onReleased: parent.isBlue = true
            }
        }

        TouchBarSlider {
            id: tbSlider
            from: 0.0
            to: 100.0
            value: 50.0
            //anchors.left: rect.right
            //anchors.horizontalCenter: touchbar.horizontalCenter
            //label: "Slider"
        }
    }
}
}
