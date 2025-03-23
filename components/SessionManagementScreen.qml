/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15

import QtQuick.Layouts 1.15

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami 2.20 as Kirigami

import QtMultimedia

FocusScope {
    id: root
    property real scaleFactor: Math.min(width / 568, height / 320)
    property FontLoader fontFamily
    property MediaPlayer userSwitchSound

    transform: Scale { // Normal y, 0 x
        id: rootScaleTransform
        origin.x: root.width / 2;
        origin.y: root.height / 2;
        xScale: 0;
        yScale: 1;
    }

    /*
     * Any message to be displayed to the user, visible above the text fields
     */
    property alias notificationMessage: notificationsLabel.text

    /*
     * A list of Items (typically ActionButtons) to be shown in a Row beneath the prompts
     */
    property alias actionItems: actionItemsLayout.children

    /*
     * Whether to show or hide the list of action items as a whole.
     */
    property alias actionItemsVisible: actionItemsLayout.visible

    /*
     * A model with a list of users to show in the view.
     * There are different implementations in sddm greeter (UserModel) and
     * KScreenLocker (SessionsModel), so some roles will be missing.
     *
     * type: {
     *  name: string,
     *  realName: string,
     *  homeDir: string,
     *  icon: string,
     *  iconName?: string,
     *  needsPassword?: bool,
     *  displayNumber?: string,
     *  vtNumber?: int,
     *  session?: string
     *  isTty?: bool,
     * }
     */
    property alias userListModel: userListView.model

    /*
     * Self explanatory
     */
    property alias userListCurrentIndex: userListView.currentIndex
    property alias userListCurrentItem: userListView.currentItem
    property alias loginFields: loginFields.source
    property bool showUserList: true

    property alias userList: userListView

    property real fontSize: Kirigami.Theme.defaultFont.pointSize + 2

    default property alias _children: innerLayout.children

    signal userSelected()

    function playHighlightAnimation() {
        bounceAnimation.start();
    }

    PlasmaComponents3.Label {
        id: notificationsLabel
        font.pointSize: root.fontSize
        anchors {
            bottom: parent.verticalCenter
            left: parent.left
            right: parent.right
        }
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        font.italic: true
        font.family: root.fontFamily.font.family

        SequentialAnimation {
            id: bounceAnimation
            loops: 1
            PropertyAnimation {
                target: notificationsLabel
                properties: "scale"
                from: 1.0
                to: 1.1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutQuad
            }
            PropertyAnimation {
                target: notificationsLabel
                properties: "scale"
                from: 1.1
                to: 1.0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InQuad
            }
        }
    }

    //goal is to show the prompts, in ~16 grid units high, then the action buttons
    //but collapse the space between the prompts and actions if there's no room
    //ui is constrained to 16 grid units wide, or the screen
    Image {
        id: loginFields
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 66 * root.scaleFactor
        smooth: false;
        width: sourceSize.width + 1
        height: sourceSize.height + 1
        scale: root.scaleFactor
    }
    ColumnLayout {
        id: prompts
        anchors.top: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 0
        UserList {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            id: userListView
            scaleFactor: root.scaleFactor
            visible: root.showUserList
            Layout.fillWidth: true
            Layout.preferredHeight: 27.5 * root.scaleFactor
            Layout.maximumWidth: 142 * root.scaleFactor
            Layout.topMargin: 37 * root.scaleFactor
            fontSize: root.fontSize * root.scaleFactor
            fontFamily: root.fontFamily
            userSwitchSound: root.userSwitchSound
            // bubble up the signal
            onUserSelected: root.userSelected()
        }
        ColumnLayout {
            id: innerLayout
            Layout.preferredHeight: 29 * root.scaleFactor
            Layout.maximumWidth: 142 * root.scaleFactor
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.topMargin: 4.25 * root.scaleFactor
            Layout.leftMargin: 0.3 * root.scaleFactor
            spacing: 0
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        Item {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.bottomMargin: 21 * root.scaleFactor
            implicitHeight: actionItemsLayout.implicitHeight
            implicitWidth: actionItemsLayout.implicitWidth

            Row { //deliberately not rowlayout as I'm not trying to resize child items
                id: actionItemsLayout
                anchors.verticalCenter: parent.verticalCenter
                spacing: Kirigami.Units.largeSpacing
            }
        }
    }
    SequentialAnimation {
        running: true
        PauseAnimation {
            duration: 3150
        }
        NumberAnimation {
            target: rootScaleTransform
            property: "xScale"
            to: 1
            duration: 400
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.31, 1.51, 0.53, 0.94, 1, 1]
        }
    }
}
