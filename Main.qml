/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator
import org.kde.kirigami 2.20 as Kirigami
import QtMultimedia

import "components"
import "components/animation"


Item {
    id: root
    property real scaleFactor: Math.min(width / 568, height / 320) // Dirty hack to fix asset scaling issues
    anchors.fill: parent

    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    //Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.inherit: false

    width: 1600
    height: 900

    property string notificationMessage

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    FontLoader {
        id: hallfetica
        source: config.Font
    }


    KeyboardIndicator.KeyState {
        id: capsLockState
        key: Qt.Key_CapsLock
    }

    Item {
        id: wallpaper
        anchors.fill: parent
        Repeater {
            model: screenModel

            Background {
                x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
                sceneBackgroundScanlines: config.BackgroundScanlines
                sceneLogoPart1: config.LogoPart1
                sceneLogoPart2: config.LogoPart2
                sceneLogoPart3: config.LogoPart3
                sceneLogoPart4: config.LogoPart4
                sceneLogoPart5: config.LogoPart5
                sceneLogoText: config.LogoText
                sceneLogoFinal: config.LogoFinal
                sceneBackgroundRing: config.BackgroundRing
                sceneBackgroundLines: config.BackgroundLines
                sceneLoginLines: config.LoginLines
            }
        }
    }

    RejectPasswordAnimation {
        id: rejectPasswordAnimation
        target: mainStack
    }

    Item {
        id: front
        anchors.fill: parent
        Repeater {
            model: screenModel

            Foreground {
                x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
                sceneForegroundAmbient: config.ForegroundAmbient
                sceneForegroundHelmet: config.ForegroundGear
                sceneForegroundDisplays: config.ForegroundDisplays
                enableCinematicBars: config.CinematicBars === "true"
            }
        }
    }
    MouseArea {
        id: loginScreenRoot
        anchors.fill: parent

        property bool uiVisible: true
        property bool blockUI: mainStack.depth > 1 || userListComponent.mainPasswordBox.text.length > 0 || inputPanel.keyboardActive || config.type !== "image"

        hoverEnabled: true
        drag.filterChildren: true
        onPressed: uiVisible = true;
        onPositionChanged: uiVisible = true;
        onUiVisibleChanged: {
            if (blockUI) {
                fadeoutTimer.running = false;
            } else if (uiVisible) {
                fadeoutTimer.restart();
            }
        }
        onBlockUIChanged: {
            if (blockUI) {
                fadeoutTimer.running = false;
                uiVisible = true;
            } else {
                fadeoutTimer.restart();
            }
        }

        Keys.onPressed: event => {
            uiVisible = true;
            event.accepted = false;
        }

        //takes one full minute for the ui to disappear
        Timer {
            id: fadeoutTimer
            running: true
            interval: 60000
            onTriggered: {
                if (!loginScreenRoot.blockUI) {
                    userListComponent.mainPasswordBox.showPassword = false;
                    loginScreenRoot.uiVisible = false;
                }
            }
        }

        QQC2.StackView {
            id: mainStack
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }


            // If true (depends on the style and environment variables), hover events are always accepted
            // and propagation stopped. This means the parent MouseArea won't get them and the UI won't be shown.
            // Disable capturing those events while the UI is hidden to avoid that, while still passing events otherwise.
            // One issue is that while the UI is visible, mouse activity won't keep resetting the timer, but when it
            // finally expires, the next event should immediately set uiVisible = true again.
            hoverEnabled: loginScreenRoot.uiVisible ? undefined : false

            focus: true //StackView is an implicit focus scope, so we need to give this focus so the item inside will have it

            Timer {
                //SDDM has a bug in 0.13 where even though we set the focus on the right item within the window, the window doesn't have focus
                //it is fixed in 6d5b36b28907b16280ff78995fef764bb0c573db which will be 0.14
                //we need to call "window->activate()" *After* it's been shown. We can't control that in QML so we use a shoddy timer
                //it's been this way for all Plasma 5.x without a huge problem
                running: true
                repeat: false
                interval: 200
                onTriggered: mainStack.forceActiveFocus()
            }

            initialItem: Login {
                loginFields: config.LoginFields
                id: userListComponent
                fontFamily: hallfetica
                userListModel: userModel
                loginScreenUiVisible: loginScreenRoot.uiVisible
                userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                lastUserName: userModel.lastUser
                loginSound: loginSound
                userSwitchSound: itemToggleSound
                showUserList: {
                    if (!userListModel.hasOwnProperty("count")
                        || !userListModel.hasOwnProperty("disableAvatarsThreshold")) {
                        return false
                    }

                    if (userListModel.count === 0 ) {
                        return false
                    }

                    if (userListModel.hasOwnProperty("containsAllUsers") && !userListModel.containsAllUsers) {
                        return false
                    }

                    return userListModel.count <= userListModel.disableAvatarsThreshold
                }

                notificationMessage: {
                    const parts = [];
                    if (capsLockState.locked) {
                        parts.push(i18nd("plasma-desktop-sddm-theme", "Caps Lock is on"));
                    }
                    if (root.notificationMessage) {
                        parts.push(root.notificationMessage);
                    }
                    return parts.join(" • ");
                }

                actionItemsVisible: !inputPanel.keyboardActive
                actionItems: [
                    ActionButton {
                        icon.name: "system-suspend"
                        icon.color: "white"
                        text: i18ndc("plasma-desktop-sddm-theme", "Suspend to RAM", "Sleep")
                        onClicked: sddm.suspend()
                        enabled: sddm.canSuspend
                        font.family: hallfetica.font.family
                    },
                    ActionButton {
                        icon.name: "system-reboot"
                        icon.color: "white"
                        text: i18nd("plasma-desktop-sddm-theme", "Restart")
                        onClicked: sddm.reboot()
                        enabled: sddm.canReboot
                        font.family: hallfetica.font.family
                    },
                    ActionButton {
                        icon.name: "system-shutdown"
                        icon.color: "white"
                        text: i18nd("plasma-desktop-sddm-theme", "Shut Down")
                        onClicked: sddm.powerOff()
                        enabled: sddm.canPowerOff
                        font.family: hallfetica.font.family
                    },
                    ActionButton {
                        icon.name: "system-user-prompt"
                        icon.color: "white"
                        text: i18ndc("plasma-desktop-sddm-theme", "For switching to a username and password prompt", "Other…")
                        onClicked: mainStack.push(userPromptComponent)
                        visible: !userListComponent.showUsernamePrompt
                        font.family: hallfetica.font.family
                    }]

                onLoginRequest: {
                    root.notificationMessage = ""
                    sddm.login(username, password, sessionButton.currentIndex)
                }
            }

            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                }
            }

            readonly property real zoomFactor: 1.5

            popEnter: Transition {
                ScaleAnimator {
                    from: mainStack.zoomFactor
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }

            popExit: Transition {
                ScaleAnimator {
                    from: 1
                    to: 1 / mainStack.zoomFactor
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }

            pushEnter: Transition {
                ScaleAnimator {
                    from: 1 / mainStack.zoomFactor
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }

            pushExit: Transition {
                ScaleAnimator {
                    from: 1
                    to: mainStack.zoomFactor
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.veryLongDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        VirtualKeyboardLoader {
            id: inputPanel

            z: 1

            screenRoot: root
            mainStack: mainStack
            mainBlock: userListComponent
            passwordField: userListComponent.mainPasswordBox
        }


        // Note: Containment masks stretch clickable area of their buttons to
        // the screen edges, essentially making them adhere to Fitts's law.
        // Due to virtual keyboard button having an icon, buttons may have
        // different heights, so fillHeight is required.
        //
        // Note for contributors: Keep this in sync with LockScreenUi.qml footer.
        RowLayout {
            id: footer
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.smallSpacing

            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                }
            }

            PlasmaComponents3.ToolButton {
                id: virtualKeyboardButton

                Kirigami.Theme.colorSet: Kirigami.Theme.Button
                Kirigami.Theme.inherit: false
                Kirigami.Theme.textColor: "#FFFFFF"
                Kirigami.Theme.backgroundColor: "transparent"

                text: i18ndc("plasma-desktop-sddm-theme", "Button to show/hide virtual keyboard", "Virtual Keyboard")
                icon.name: inputPanel.keyboardActive ? "input-keyboard-virtual-on" : "input-keyboard-virtual-off"
                icon.color: Kirigami.Theme.textColor

                onClicked: {
                    // Otherwise the password field loses focus and virtual keyboard
                    // keystrokes get eaten
                    userListComponent.mainPasswordBox.forceActiveFocus();
                    inputPanel.showHide()
                }
                visible: inputPanel.status === Loader.Ready
                transform: Scale {
                    id: virtualScaleTransform
                    origin.x: virtualKeyboardButton.width / 2;
                    origin.y: virtualKeyboardButton.height / 2;
                    xScale: 1;
                    yScale: 0;
                }

                Layout.fillHeight: true
                containmentMask: Item {
                    parent: virtualKeyboardButton
                    anchors.fill: parent
                    anchors.leftMargin: -footer.anchors.margins
                    anchors.bottomMargin: -footer.anchors.margins
                }
                SequentialAnimation {
                    running: true
                    PauseAnimation {
                        duration: 3150
                    }
                    NumberAnimation {
                        target: virtualScaleTransform
                        property: "yScale"
                        to: 1
                        duration: 400
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.31, 1.51, 0.53, 0.94, 1, 1]
                    }
                }
            }

            KeyboardButton {
                id: keyboardButton

                onKeyboardLayoutChanged: {
                    // Otherwise the password field loses focus and virtual keyboard
                    // keystrokes get eaten
                    userListComponent.mainPasswordBox.forceActiveFocus();
                }

                Layout.fillHeight: true
                containmentMask: Item {
                    parent: keyboardButton
                    anchors.fill: parent
                    anchors.leftMargin: virtualKeyboardButton.visible ? 0 : -footer.anchors.margins
                    anchors.bottomMargin: -footer.anchors.margins
                }
            }

            SessionButton {
                id: sessionButton

                onSessionChanged: {
                    // Otherwise the password field loses focus and virtual keyboard
                    // keystrokes get eaten
                    userListComponent.mainPasswordBox.forceActiveFocus();
                }

                Layout.fillHeight: true
                containmentMask: Item {
                    parent: sessionButton
                    anchors.fill: parent
                    anchors.leftMargin: virtualKeyboardButton.visible || keyboardButton.visible
                        ? 0 : -footer.anchors.margins
                    anchors.bottomMargin: -footer.anchors.margins
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Battery {}
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            notificationMessage = i18nd("plasma-desktop-sddm-theme", "Login Failed")
            footer.enabled = true
            mainStack.enabled = true
            userListComponent.userList.opacity = 1
            rejectPasswordAnimation.start()
        }
        function onLoginSucceeded() {
            //note SDDM will kill the greeter at some random point after this
            //there is no certainty any transition will finish, it depends on the time it
            //takes to complete the init
            mainStack.opacity = 0
            footer.opacity = 0
        }
    }

    onNotificationMessageChanged: {
        if (notificationMessage) {
            notificationResetTimer.start();
        }
    }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: notificationMessage = ""
    }

    MediaPlayer {
        id: sceneSoundHelmet
        audioOutput: AudioOutput {
            id: audioHelmet
            volume: config.SoundHelmetVolume
        }
        source: config.SoundHelmet
    }

    MediaPlayer {
        id: sceneSoundAlarm
        audioOutput: AudioOutput {
            id: audioAlarm
            volume: config.SoundAlarmVolume
        }
        source: config.SoundAlarm
    }

    Timer {
        id: timerAlarm
        interval: 300
        onTriggered: {
            sceneSoundAlarm.play()
        }
    }

    MediaPlayer {
        id: sceneSoundLogo
        audioOutput: AudioOutput {
            id: audioLogo
            volume: config.SoundLogoVolume
        }
        source: config.SoundLogo
    }

    Timer {
        id: timerLogo
        interval: 800
        onTriggered: {
            sceneSoundLogo.play()
        }
    }

    MediaPlayer {
        id: sceneSoundStart
        audioOutput: AudioOutput {
            id: audioStart
            volume: config.SoundStartVolume
        }
        source: config.SoundStart
    }

    Timer {
        id: timerStart
        interval: 2250
        onTriggered: {
            sceneSoundStart.play()
        }
    }

    MediaPlayer {
        id: sceneSoundAppear
        audioOutput: AudioOutput {
            id: audioAppear
            volume: config.SoundAppearVolume
        }
        source: config.SoundAppear
    }

    MediaPlayer {
        id: sceneSoundAppear2
        audioOutput: AudioOutput {
            id: audioAppear2
            volume: config.SoundAppearVolume
        }
        source: config.SoundAppear
    }

    Timer {
        id: timerAppear
        interval: 3150
        onTriggered: {
            sceneSoundAppear.play()
        }
    }

    Timer {
        id: timerAppear2
        interval: 3550
        onTriggered: {
            sceneSoundAppear2.play()
        }
    }

    MediaPlayer {
        id: loginSound
        audioOutput: AudioOutput {
            id: confirmOutput
            volume: config.SoundConfirmVolume
        }
        source: config.SoundConfirm
    }

    MediaPlayer {
        id: itemToggleSound
        audioOutput: AudioOutput {
            id: itemToggleOutput
            volume: config.SoundItemToggleVolume
        }
        source: config.SoundItemToggle
    }

    function setSounds() {
        if (sceneSoundHelmet.mediaStatus==MediaPlayer.EndOfMedia) {
            sceneSoundHelmet.source = config.SoundHelmet
            sceneSoundHelmet.position = 0;
        }
        if (sceneSoundAlarm.mediaStatus==MediaPlayer.EndOfMedia) {
            sceneSoundAlarm.source = config.SoundAlarm
            sceneSoundAlarm.position = 0;
        }
        if (sceneSoundLogo.mediaStatus==MediaPlayer.EndOfMedia) {
            sceneSoundLogo.source = config.SoundLogo
            sceneSoundLogo.position = 0;
        }
        if (sceneSoundStart.mediaStatus==MediaPlayer.EndOfMedia) {
            sceneSoundStart.source = config.SoundStart
            sceneSoundStart.position = 0;
        }
        if (sceneSoundAppear.mediaStatus==MediaPlayer.EndOfMedia) {
            sceneSoundAppear.source = config.SoundAppear
            sceneSoundAppear.position = 0;
        }
        if (sceneSoundAppear2.mediaStatus==MediaPlayer.EndOfMedia) {
            sceneSoundAppear2.source = config.SoundAppear2
            sceneSoundAppear2.position = 0;
        }
    }

    Component.onCompleted: {
        setSounds()
        sceneSoundHelmet.play()
        timerAlarm.start()
        timerLogo.start()
        timerStart.start()
        timerAppear.start()
        timerAppear2.start()
    }
}
