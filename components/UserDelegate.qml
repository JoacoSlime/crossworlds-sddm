/*
    SPDX-FileCopyrightText: 2014 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Window 2.15

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: wrapper

    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    property bool isCurrentItem: false
    property bool isLeft: false
    property bool isRight: false

    property string name
    property string displayedText: ""
    property int currentIndex: 0 // Index of the current character being displayed
    property int typingSpeed: 50 // Speed of typing in milliseconds
    property string userName
    property bool needsPassword
    property var vtNumber
    property bool constrainText: true
    property alias nameFontSize: usernameDelegate.font.pointSize
    property real maxWidth
    property real scaleFactor
    property real fontSize: Kirigami.Theme.defaultFont.pointSize
    property FontLoader fontFamily
    signal clicked()
    onIsCurrentItemChanged: {
        console.log("UserDelegate isCurrentItem changed to: " + isCurrentItem);
        if (isCurrentItem) {
            // Reset the typing animation
            currentIndex = 0;
            displayedText = ""; // Clear the displayed text
            typingTimer.start(); // Start the typing effect
        }
    }

    // Timer to control the typing effect
    Timer {
        id: typingTimer
        interval: parent.typingSpeed
        repeat: true
        running: false
        onTriggered: {
            if (parent.currentIndex < parent.name.length) {
                parent.displayedText += parent.name[parent.currentIndex]; // Add the next character
                parent.currentIndex++; // Move to the next character
            } else {
                typingTimer.stop(); // Stop the timer when done
            }
        }
    }

    property real faceSize: Kirigami.Units.gridUnit * 7
    width: maxWidth

    visible: (isLeft || isRight || isCurrentItem)

    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration
        }
    }

    PlasmaComponents3.Label {
        id: usernameDelegate

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:parent.verticalCenter

        // Make it bigger than other fonts to match the scale of the avatar better
        font.pointSize: wrapper.fontSize
        font.family: wrapper.fontFamily.font.family
        color: "white"

        visible: wrapper.isCurrentItem
        width: wrapper.constrainText && (wrapper.isLeft || wrapper.isRight) ? (parent.width * wrapper.scaleFactor) : undefined
        text: wrapper.displayedText
        textFormat: Text.PlainText
        style: Text.Outline
        styleColor: "#2d0045"
        wrapMode: Text.WordWrap
        maximumLineCount: wrapper.constrainText ? 3 : 1
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        bottomPadding: wrapper.isCurrentItem ? undefined : 2 * wrapper.scaleFactor
        //make an indication that this has active focus, this only happens when reached with keyboard navigation
        font.underline: wrapper.activeFocus

       MouseArea {
           anchors.fill: parent
           hoverEnabled: true

           onClicked: wrapper.clicked()
       }
    }

    PlasmaComponents3.Button {
        id: usernamePlaceholderButton

        visible: !wrapper.isCurrentItem
        width: 15 * wrapper.scaleFactor - 2 * wrapper.scaleFactor
        height: width
        anchors.left: parent.isRight ? parent.left : undefined
        anchors.right: parent.isLeft ? parent.right : undefined
        anchors.leftMargin: parent.isRight ? wrapper.scaleFactor : undefined
        anchors.rightMargin: parent.isLeft ? wrapper.scaleFactor : undefined
        anchors.verticalCenter: parent.verticalCenter
        font.family: wrapper.fontFamily.font.family
        Kirigami.Theme.colorSet: Kirigami.Theme.Button
        Kirigami.Theme.inherit: false
        Kirigami.Theme.textColor: "#FFFFFF"
        Kirigami.Theme.backgroundColor: "#FFFFFF"

        contentItem: Kirigami.Icon {
            source: usernamePlaceholderButton.text.length === 0 ? (wrapper.isLeft ? "go-previous" : "go-next") : ""
            color: Kirigami.Theme.textColor
            isMask: true
        }

        background: Item {
            anchors.centerIn: parent
            opacity: usernamePlaceholderButton.hovered ? 0.5 : 0
            width: height

            Rectangle {
                id: buttonBackground
                color: "#FFFFFF"
                anchors.fill: parent
                radius: width / 2
            }
        }

       MouseArea {
           anchors.fill: parent
           hoverEnabled: true

           onClicked: wrapper.clicked()
       }
    }

    Keys.onSpacePressed: wrapper.clicked()

    Accessible.name: name
    Accessible.role: Accessible.Button
    function accessiblePressAction() { wrapper.clicked() }
}
