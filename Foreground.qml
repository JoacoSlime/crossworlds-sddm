import QtQuick 2.15

FocusScope{
    id: foreground

    property alias sceneForegroundHelmet: sceneForegroundHelmet.source
    property alias sceneForegroundAmbient: sceneForegroundAmbient.source
    property alias sceneForegroundDisplays: sceneForegroundDisplays.source
    property alias enableCinematicBars: cinematicBars.visible
    property real scaleFactor: Math.min(width / 568, height / 320)

    Image {
        id: sceneForegroundAmbient
        visible: true
        anchors.fill: parent
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        width: parent.width
        height: parent.height
        smooth: false;
    }

    Image {
        id: sceneForegroundHelmet
        visible: true
        width: sourceSize.width * foreground.scaleFactor
        height: sourceSize.height * foreground.scaleFactor
        smooth: false;
        scale: 1.3

        SequentialAnimation{
            ParallelAnimation {
                NumberAnimation {
                    target: sceneForegroundHelmet
                    property: "y"
                    from: -30 * foreground.scaleFactor
                    to: -10 * foreground.scaleFactor
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0, 0.5, 0.58, 1, 1, 1]
                }
                NumberAnimation {
                    target: sceneForegroundHelmet
                    property: "scale"
                    from: 1.3
                    to: 1
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0, 0.5, 0.58, 1, 1, 1]
                }
                NumberAnimation {
                    target: sceneForegroundHelmet
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0, 0.5, 0.58, 1, 1, 1]
                }
                NumberAnimation {
                    target: sceneForegroundHelmet
                    property: "rotation"
                    from: 7.2
                    to: 0
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0, 0.5, 0.58, 1, 1, 1]
                }
            }
            running: true
        }

        NumberAnimation {
            id: sceneForegroundHelmetAnimation
            target: sceneForegroundHelmet
            property: "y"
            from: -10 * foreground.scaleFactor
            to: 0
            duration: 400
            easing.type: Easing.InOutQuad
        }

        Timer {
            id: sceneSoundHelmetTimer
            interval: 300
            onTriggered: sceneForegroundHelmetAnimation.running = true
            running: true
        }
    }

    Image {
        id: sceneForegroundDisplays
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        width: parent.width
        height: parent.height
        opacity: 0
        scale: 1.5
        smooth: false
        SequentialAnimation{
            running: true;
            PauseAnimation{
                duration: 3550
            }
            ParallelAnimation{
                NumberAnimation {
                    target: sceneForegroundDisplays
                    property: "opacity"
                    to: 1
                    duration: 700
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.31, 1.51, 0.53, 0.94, 1, 1]
                }
                NumberAnimation {
                    target: sceneForegroundDisplays
                    property: "scale"
                    to: 1
                    duration: 700
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.31, 1.51, 0.53, 0.94, 1, 1]
                }
            }
        }
    }

    Item{
        id: cinematicBars
        anchors.fill: parent
        Rectangle {
            color : "#000000"
            anchors.left: parent.left
            anchors.right: parent.right
            height: 21 * foreground.scaleFactor
        }

        Rectangle {
            color : "#000000"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 21 * foreground.scaleFactor
        }
    }
}
