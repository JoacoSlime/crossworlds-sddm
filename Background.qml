/*
    SPDX-FileCopyrightText: 2016 Boudhayan Gupta <bgupta@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15

FocusScope {
    id: sceneBackground

    //property alias sceneBackgroundGradient: sceneBackgroundGradient.source
    //property alias sceneBackgroundLines: sceneBackgroundLines.source
    //property alias sceneBackgroundRing: sceneBackgroundRing.source
    property alias sceneBackgroundScanlines: sceneBackgroundScanlines.source
    property alias sceneLogoPart1: sceneLogoPart1.source
    property alias sceneLogoPart2: sceneLogoPart2.source
    property alias sceneLogoPart3: sceneLogoPart3.source
    property alias sceneLogoPart4: sceneLogoPart4.source
    property alias sceneLogoPart5: sceneLogoPart5.source
    property alias sceneLogoFinal: sceneLogoFinal.source
    property alias sceneLogoText: sceneLogoText.source
    property alias sceneBackgroundRing: sceneBackgroundRing.source
    property alias sceneBackgroundLines: sceneBackgroundLines.source
    property alias sceneLoginLines: sceneLoginLines.source
    property real scaleFactor: Math.min(width / 568, height / 320)

    Rectangle {
        id: sceneColorBackground
        anchors.fill: parent
        color: "#000000"
    }

    Image {
        id: sceneBackgroundRing
        anchors.centerIn: parent
        width: sourceSize.width
        height: sourceSize.height
        scale: 0
        opacity: 1
        smooth: false
        SequentialAnimation {
            id: ringAnimation
            running: true
            PauseAnimation {
                duration: 2250
            }
            ParallelAnimation{
                loops: Animation.Infinite
                NumberAnimation {
                    target: sceneBackgroundRing
                    property: "scale"
                    to: sceneBackground.scaleFactor * 2
                    duration: 3000
                    easing.type: Easing.Linear
                }
                NumberAnimation {
                    target: sceneBackgroundRing
                    property: "opacity"
                    to: 0
                    duration: 3000
                }
                PauseAnimation {
                    duration: 2600
                }
            }
        }
    }

    Image {
        id: sceneBackgroundRing2
        source: sceneBackgroundRing.source
        anchors.centerIn: parent
        width: sourceSize.width
        height: sourceSize.height
        scale: 0
        opacity: 1
        smooth: false
        SequentialAnimation {
            id: ring2Animation
            running: true
            PauseAnimation {
                duration: 3550
            }
            ParallelAnimation{
                loops: Animation.Infinite
                NumberAnimation {
                    target: sceneBackgroundRing2
                    property: "scale"
                    to: sceneBackground.scaleFactor * 2
                    duration: 3000
                    easing.type: Easing.Linear
                }
                NumberAnimation {
                    target: sceneBackgroundRing2
                    property: "opacity"
                    to: 0
                    duration: 3000
                }
                PauseAnimation {
                    duration: 2600
                }
            }
        }
    }

    Image {
        id: sceneBackgroundLines
        anchors.centerIn: parent
        height: sourceSize.height
        width: sourceSize.width
        scale: sceneBackground.scaleFactor
        opacity: 0
        smooth: false

        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 2550
            }
            PropertyAction {
                target: sceneBackgroundLines
                property: "opacity"
                value: 1
            }
        }
    }

    ShaderEffect {
        id: sceneBackgroundGradient

        property var source: parent
        property var overlayTexture: ShaderEffectSource {
            id: gradientSource
            sourceItem: Image {
                id: gradientImage
                source: config.BackgroundGradient
            }
        }

        anchors.centerIn: parent
        width: gradientImage.width
        height: gradientImage.height
        visible: true
        opacity: 0
        scale: sceneBackground.scaleFactor

        fragmentShader: "lighten_blend.qsb"

        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 2550
            }
            PropertyAction {
                target: sceneBackgroundGradient
                property: "opacity"
                value: 1
            }
        }
    }

    Image {
        id: sceneLoginLines
        anchors.centerIn: parent
        smooth: false;
        width: sourceSize.width
        height: sourceSize.height

        visible: true
        opacity: 0
        scale: sceneBackground.scaleFactor

        SequentialAnimation{
            running: true
            PauseAnimation {
                duration: 3350
            }
            NumberAnimation {
                target: sceneLoginLines
                property: "opacity"
                to: 0.6
                duration: 1000
                easing.type: Easing.Linear
            }
        }
    }

    Rectangle {
        id: sceneBrightBackground
        color: "#99bfd7"
        anchors.fill: parent
        opacity: 0

        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 600
            }
            NumberAnimation {
                target: sceneBrightBackground
                property: "opacity"
                to: 1
                duration: 400
                easing.type: Easing.InOutQuad
            }
            PauseAnimation {
                duration: 1950
            }
            NumberAnimation {
                target: sceneBrightBackground
                property: "opacity"
                to: 0
                duration: 100
                easing.type: Easing.Linear
            }
        }
    }

    Image {
        id: sceneLogoPart1
        visible: true
        //Center
        anchors.centerIn: parent
        smooth: false;
        width: sourceSize.width
        height: sourceSize.height
        scale: 0
        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 800
            }
            NumberAnimation {
                target: sceneLogoPart1
                property: "scale"
                from: 0
                to: sceneBackground.scaleFactor
                duration: 400
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.31, 1.51, 0.53, 0.94, 1, 1]
            }
            PauseAnimation {
                duration: 1750
            }
            NumberAnimation {
                target: sceneLogoPart1
                property: "opacity"
                from: 1
                to: 0
                duration: 100
                easing.type: Easing.Linear
            }
        }
    }

    Image {
        id: sceneLogoPart2
        visible: true
        //Center
        anchors.centerIn: parent
        smooth: false;
        width: sourceSize.width
        height: sourceSize.height
        scale: 0
        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 950
            }
            NumberAnimation {
                target: sceneLogoPart2
                property: "scale"
                from: 0
                to: sceneBackground.scaleFactor
                duration: 400
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.31, 1.51, 0.53, 0.94, 1, 1]
            }
            PauseAnimation {
                duration: 1600
            }
            NumberAnimation {
                target: sceneLogoPart2
                property: "opacity"
                from: 1
                to: 0
                duration: 100
                easing.type: Easing.Linear
            }
        }
    }

    Image {
        id: sceneLogoPart3
        visible: true
        //Center
        anchors.centerIn: parent
        smooth: false;
        width: sourceSize.width
        height: sourceSize.height
        scale: 0
        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 1100
            }
            NumberAnimation {
                target: sceneLogoPart3
                property: "scale"
                from: 0
                to: sceneBackground.scaleFactor
                duration: 400
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.31, 1.51, 0.53, 0.94, 1, 1]
            }
            PauseAnimation {
                duration: 1450
            }
            NumberAnimation {
                target: sceneLogoPart3
                property: "opacity"
                from: 1
                to: 0
                duration: 100
                easing.type: Easing.Linear
            }
        }
    }

    Image {
        id: sceneLogoPart4
        visible: true
        //Center
        anchors.centerIn: parent
        smooth: false;
        width: sourceSize.width
        height: sourceSize.height
        scale: 0
        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 1250
            }
            NumberAnimation {
                target: sceneLogoPart4
                property: "scale"
                from: 0
                to: sceneBackground.scaleFactor
                duration: 100
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.31, 1.51, 0.53, 0.94, 1, 1]
            }
            PauseAnimation {
                duration: 1300
            }
            NumberAnimation {
                target: sceneLogoPart4
                property: "opacity"
                from: 1
                to: 0
                duration: 400
                easing.type: Easing.Linear
            }
        }
    }

    Image {
        id: sceneLogoPart5
        visible: true
        //Center
        anchors.centerIn: parent
        smooth: false;
        width: sourceSize.width
        height: sourceSize.height
        scale: 0
        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 1400
            }
            NumberAnimation {
                target: sceneLogoPart5
                property: "scale"
                from: 0
                to: sceneBackground.scaleFactor
                duration: 400
                easing.type: Easing.OutQuad
            }
            PauseAnimation {
                duration: 1150
            }
            NumberAnimation {
                target: sceneLogoPart5
                property: "opacity"
                from: 1
                to: 0
                duration: 100
                easing.type: Easing.Linear
            }
        }
    }

    Image {
        id: sceneLogoText
        visible: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 56 * sceneBackground.scaleFactor
        smooth: false;
        width: sourceSize.width
        height: 0
        scale: sceneBackground.scaleFactor
        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 1550
            }
            NumberAnimation {
                target: sceneLogoText
                property: "height"
                from: 0
                to: sceneLogoText.sourceSize.height
                duration: 400
                easing.type: Easing.OutQuad
            }
            PauseAnimation {
                duration: 1000
            }
            NumberAnimation {
                target: sceneLogoText
                property: "opacity"
                from: 1
                to: 0
                duration: 400
                easing.type: Easing.Linear
            }
        }
    }

    Image {
        id: sceneLogoFinal
        visible: true
        //Center
        anchors.centerIn: parent
        smooth: false;
        width: sourceSize.width
        height: sourceSize.height
        scale: sceneBackground.scaleFactor
        opacity: 0

        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 2550
            }
            PropertyAction {
                target: sceneLogoFinal
                property: "opacity"
                value: 1
            }
            PauseAnimation{
                duration: 400
            }
            NumberAnimation {
                target: sceneLogoFinal
                property: "anchors.verticalCenterOffset"
                to: (-24 * sceneBackground.scaleFactor)
                duration: 600
                easing.type: Easing.InOutQuad
            }
        }
    }

    ShaderEffect {
        // White background lighten
        id: whiteBackgroundLighten

        property var source: parent
        property var overlayTexture: ShaderEffectSource {
            id: whiteSource
            sourceItem: Rectangle {
                color: "white"
                width: whiteBackgroundLighten.width
                height: whiteBackgroundLighten.height
            }
        }

        anchors.fill: parent
        visible: true
        opacity: 0

        fragmentShader: "lighten_blend.qsb"

        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 2250
            }
            NumberAnimation {
                target: whiteBackgroundLighten
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.Linear
            }
            PauseAnimation {
                duration: 400
            }
            NumberAnimation {
                target: whiteBackgroundLighten
                property: "opacity"
                from: 1
                to: 0
                duration: 300
                easing.type: Easing.Linear
            }
        }
    }

    ShaderEffect {
        id: sceneBackgroundScanlines

        property var source: parent
        property var overlayTexture: ShaderEffectSource {
            id: scanlinesSource
            sourceItem: Image {
                source: config.BackgroundScanlines
                fillMode: Image.Tile
                smooth: false
            }
        }

        anchors.fill: parent
        visible: true
        opacity: 0

        fragmentShader: "lighten_blend.qsb"

        SequentialAnimation {
            running: true
            PauseAnimation {
                duration: 300
            }
            NumberAnimation {
                target: sceneBackgroundScanlines
                property: "opacity"
                from: 0
                to: 1
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }
    }
}
