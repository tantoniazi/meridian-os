import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kirigami
import QtQuick.Controls.Material
import QtQuick.Controls.Universal

// Lock Screen Overlay - Windows 10 Mobile Style
Kirigami.OverlaySheet {
    id: root
    
    property SettingsModel settingsModel
    
    width: parent.width
    height: parent.height
    modal: true
    closePolicy: Kirigami.OverlaySheet.EscapeKey
    
    // Lock state
    property bool unlocked: false
    property string pinCode: ""
    property int attempts: 0
    property int maxAttempts: 5
    
    // Background
    Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
        
        // Background image
        Image {
            anchors.fill: parent
            source: settingsModel.lockScreenBackground || ""
            fillMode: Image.PreserveAspectCrop
            visible: settingsModel.lockScreenBackground !== ""
            
            // Dark overlay for readability
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.4
                visible: settingsModel.lockScreenBackground !== ""
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            
            // Time and Date
            Item {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.topMargin: 80
                
                ColumnLayout {
                    spacing: 4
                    
                    // Time
                    Label {
                        id: timeLabel
                        text: Qt.formatTime(new Date(), "hh:mm")
                        font.pixelSize: 72
                        font.bold: true
                        color: "white"
                        horizontalAlignment: Qt.AlignHCenter
                    }
                    
                    // Date
                    Label {
                        text: Qt.formatDate(new Date(), "dddd, MMMM d")
                        font.pixelSize: 20
                        color: "white"
                        opacity: 0.8
                        horizontalAlignment: Qt.AlignHCenter
                    }
                }
            }
            
            // Notifications preview
            Rectangle {
                Layout.fillWidth: true
                Layout.bottomMargin: 20
                
                ColumnLayout {
                    spacing: 8
                    Layout.fillWidth: true
                    Layout.margins: 24
                    
                    // Notification items (placeholder)
                    Repeater {
                        model: 3
                        delegate: Kirigami.Card {
                            Layout.fillWidth: true
                            Layout.minimumHeight: 72
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 4
                                
                                RowLayout {
                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: 20
                                        color: Kirigami.Theme.highlightColor
                                        
                                        Image {
                                            anchors.centerIn: parent
                                            source: "icon.png"
                                            width: 24
                                            height: 24
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }
                                    
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        
                                        Label {
                                            text: "App Name"
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: Kirigami.Theme.textColor
                                        }
                                        
                                        Label {
                                            text: "Notification message preview..."
                                            color: Kirigami.Theme.textColor
                                            opacity: 0.7
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // PIN Entry Area
            Rectangle {
                Layout.fillWidth: true
                Layout.bottomMargin: 40
                
                ColumnLayout {
                    spacing: 16
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                    Layout.bottomMargin: 40
                    
                    // PIN display
                    RowLayout {
                        spacing: 16
                        Layout.alignment: Qt.AlignHCenter
                        
                        Repeater {
                            model: 4
                            delegate: Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: index < root.pinCode.length ? Kirigami.Theme.accentColor : Kirigami.Theme.highlightColor
                                border.color: Kirigami.Theme.highlightColor
                                border.width: 2
                            }
                        }
                    }
                    
                    // Keypad
                    GridLayout {
                        columns: 3
                        rowSpacing: 12
                        columnSpacing: 12
                        Layout.fillWidth: true
                        Layout.margins: 32
                        
                        Repeater {
                            model: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "backspace"]
                            
                            delegate: Kirigami.Button {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 64
                                Layout.minimumWidth: 64
                                
                                text: modelData === "backspace" ? "⌫" : modelData
                                font.pixelSize: 28
                                font.bold: true
                                color: Kirigami.Theme.textColor
                                background: Kirigami.Theme.backgroundColor
                                border.color: Kirigami.Theme.highlightColor
                                border.width: 1
                                radius: 32
                                
                                onClicked: {
                                    if (modelData === "backspace") {
                                        if (root.pinCode.length > 0) {
                                            root.pinCode = root.pinCode.slice(0, -1)
                                        }
                                    } else if (modelData !== "" && root.pinCode.length < 4) {
                                        root.pinCode += modelData
                                        
                                        // Check PIN when complete
                                        if (root.pinCode.length === 4) {
                                            checkPin()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Emergency call button
                    Kirigami.Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 24
                        text: qsTr("Emergency call")
                        font.pixelSize: 16
                        color: Kirigami.Theme.textColor
                        background: "transparent"
                        onClicked: {
                            // Emergency call
                        }
                    }
                }
            }
        }
    }
    
    function checkPin() {
        // Simple PIN check (in real app, use secure storage)
        if (pinCode === "1234") {
            root.unlocked = true
            root.close()
        } else {
            root.attempts++
            root.pinCode = ""
            
            // Show error
            // Shake animation
            
            if (root.attempts >= root.maxAttempts) {
                // Lock for 30 seconds
                // Disable keypad
            }
        }
    }