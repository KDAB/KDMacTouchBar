import QtQuick 2.0

Item {
    id: slider

    property real from: 0.0
    property real to: 1.0
    property real value: 0.0
    readonly property bool pressed: mouse.containsPress
    property bool mirrored: LayoutMirroring.enabled
    readonly property real position: (value - from) / (to - from)
    readonly property real visualPosition: mirrored ? 1.0 - position : position
    property real leftPadding: 0
    property real rightPadding: 0
    property real topPadding: 0
    property real bottomPadding: 0

    property real availableHeight: height - topPadding - bottomPadding
    property real availableWidth: width - leftPadding - rightPadding

    height: 30
    width: 150

    Rectangle {
        id: background
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: slider.availableWidth
        height: implicitHeight
        radius: 3
        color: "#737373"

        Rectangle {
            width: (handle.x - slider.leftPadding) / (slider.availableWidth - handle.width) * parent.width
            height: parent.height
            color: "#0082d7"
            radius: 3
        }
    }
    
    Rectangle {
        id: handle
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.height / 2 - height / 2

        color: "white"
        border.color: "#1e1e1e"
        border.width: 1
        implicitWidth: 30
        implicitHeight: 30
        radius: 4

	Behavior on x {
            enabled: mouse.singleClicked
            PropertyAnimation {
                id: animation
                duration: 200
            }
        }
    }

    MouseArea {
        id: mouse
        property bool singleClicked
        property real handlePressX
        acceptedButtons: Qt.LeftButton
        anchors.fill: parent
        onPressed: function(mouse) {
            mouse.accepted = true
            handlePressX = mouse.x - handle.x
            var pressedHandle = mouse.x >= handle.x && mouse.x <= handle.x + handle.width
            singleClicked = !pressedHandle
            if (!pressedHandle) {
                handlePressX = handle.width / 2
                var newVisualPosition = (mouse.x - handlePressX - slider.leftPadding) / (slider.availableWidth - handle.width)
                var newPosition = slider.mirrored ? 1.0 - newVisualPositon : newVisualPosition
                slider.value = Math.min(Math.max(newPosition * (to - from) + from, from), to)
            }
        }
        onPositionChanged: function(mouse) {
            singleClicked = false
            var newVisualPosition = (mouse.x - handlePressX - slider.leftPadding) / (slider.availableWidth - handle.width)
            var newPosition = slider.mirrored ? 1.0 - newVisualPositon : newVisualPosition
            slider.value = Math.min(Math.max(newPosition * (to - from) + from, from), to)
        }
    }
}
