import "components"

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami

import QtMultimedia

SessionManagementScreen {
    id: root
    property Item mainPasswordBox: passwordBox
    property bool showUsernamePrompt: !showUserList
    property MediaPlayer loginSound

    property string lastUserName
    property bool loginScreenUiVisible: false

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + Kirigami.Units.smallSpacing

    property real fontSize: Kirigami.Theme.defaultFont.pointSize

    property real scaleFactor: Math.min(width / 568, height / 320)

    signal loginRequest(string username, string password)

    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    onUserSelected: {
        // Don't startLogin() here, because the signal is connected to the
        // Escape key as well, for which it wouldn't make sense to trigger
        // login.
        focusFirstVisibleFormControl();
    }

    QQC2.StackView.onActivating: {
        // Controls are not visible yet.
        Qt.callLater(focusFirstVisibleFormControl);
    }

    function focusFirstVisibleFormControl() {
        const nextControl = (userNameInput.visible
            ? userNameInput
            : (passwordBox.visible
                ? passwordBox
                : loginButton));
        // Using TabFocusReason, so that the loginButton gets the visual highlight.
        nextControl.forceActiveFocus(Qt.TabFocusReason);
    }

    /*
     * Login has been requested with the following username and password
     * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
     */
    function startLogin() {
        loginSound.play()
        //while (loginSound.mediaStatus != MediaStatus.EndOfMedia) {
            // Wait for the sound to finish playing
        //}
        const username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        const password = passwordBox.text

        footer.enabled = false
        mainStack.enabled = false
        userListComponent.userList.opacity = 0.5

        // This is partly because it looks nicer, but more importantly it
        // works round a Qt bug that can trigger if the app is closed with a
        // TextField focused.
        //
        // See https://bugreports.qt.io/browse/QTBUG-55460
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    PlasmaComponents3.TextField {
        id: userNameInput
        font.pointSize: root.fontSize + 1
        Layout.fillWidth: true

        text: lastUserName
        font.family: root.fontFamily.font.family
        visible: showUsernamePrompt
        focus: showUsernamePrompt && !lastUserName //if there's a username prompt it gets focus first, otherwise password does
        placeholderText: i18nd("plasma-desktop-sddm-theme", "Username")

        onAccepted: {
            if (root.loginScreenUiVisible) {
                passwordBox.forceActiveFocus()
            }
        }
        SequentialAnimation {
            running: true
            PropertyAction {
                target: userNameInput
                property: "height"
                value: 0
            }
            PauseAnimation {
                duration: 3150
            }
            NumberAnimation {
                target: userNameInput
                property: "height"
                to: userNameInput.height
                duration: 400
                easing.type: Easing.OutQuad
            }
        }
    }

    RowLayout {
        id: loginButtonLayout
        Layout.fillWidth: true
        spacing: 7 * root.scaleFactor

        PlasmaExtras.PasswordField {
            id: passwordBox
            font.pointSize: root.fontSize* root.scaleFactor + 1
            font.family: root.fontFamily.font.family
            Layout.fillWidth: true
            Layout.preferredHeight: 23 * root.scaleFactor
            background: Item{}
            color: "white"

            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter

            placeholderText: ""
            focus: !showUsernamePrompt || lastUserName

            // Disable reveal password action because SDDM does not have the breeze icon set loaded
            rightActions: []

            onAccepted: {
                if (root.loginScreenUiVisible) {
                    startLogin();
                }
            }

            visible: root.showUsernamePrompt || userList.currentItem.needsPassword

            Keys.onEscapePressed: {
                mainStack.currentItem.forceActiveFocus();
            }

            //if empty and left or right is pressed change selection in user switch
            //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex();
                    event.accepted = true
                }
                if (event.key === Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex();
                    event.accepted = true
                }
            }

            Connections {
                target: sddm
                function onLoginFailed() {
                    passwordBox.selectAll()
                    passwordBox.forceActiveFocus()
                }
            }
        }

        PlasmaComponents3.Button {
            id: loginButton
            font.family: root.fontFamily.font.family
            Accessible.name: i18nd("plasma-desktop-sddm-theme", "Log In")
            Layout.preferredHeight: 23 * root.scaleFactor - 2 * root.scaleFactor
            Layout.preferredWidth: text.length === 0 ? (15 * root.scaleFactor - 2 * root.scaleFactor) : -1
            Layout.rightMargin: 1 * root.scaleFactor

            display: PlasmaComponents3.Button.IconOnly

            onClicked: startLogin()
            Keys.onEnterPressed: clicked()
            Keys.onReturnPressed: clicked()
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            Kirigami.Theme.inherit: false
            Kirigami.Theme.textColor: "#FFFFFF"
            Kirigami.Theme.backgroundColor: "#FFFFFF"
            Kirigami.Theme.alternateBackgroundColor: "#FFFFFF"

            contentItem: Kirigami.Icon {
                source: loginButton.text.length === 0 ? (root.LayoutMirroring.enabled ? "go-previous" : "go-next") : ""
                color: Kirigami.Theme.textColor
                isMask: true
            }

            background: Item {
                height: width
                anchors.verticalCenter: parent.verticalCenter
                opacity: loginButton.hovered ? 0.5 : 0

                Rectangle {
                    id: buttonBackground
                    color: Kirigami.Theme.backgroundColor
                    anchors.fill: parent
                    radius: width / 2
                }
            }
        }
    }
}
