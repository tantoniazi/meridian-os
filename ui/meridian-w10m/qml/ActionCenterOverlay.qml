import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kirigami
import QtQuick.Controls.Material
import QtQuick.Controls.Universal

// Action Center Overlay - Windows 10 Mobile Style
Kirigami.OverlaySheet {
    id: root
    
    property SettingsModel settingsModel
    
    width: parent.width
    height: parent.height * 0.6
    modal: true
    closePolicy: Kirigami.OverlaySheet.ClickOutside | Kirigami.OverlaySheet.EscapeKey
    
    // Animation
    enter: Transition {
        NumberAnimation { property: "y"; from: parent.height; to: parent.height - root.height; duration: 300; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "y"; from: parent.height - root.height; to: parent.height; duration: 200; easing.type: Easing.InCubic }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.highlightColor
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                Layout.margins: 16
                
                Label {
                    text: qsTr("Action Center")
                    font.pixelSize: 20
                    font.bold: true
                    color: Kirigami.Theme.textColor
                }
                
                Layout.fillWidth: true
                
                Kirigami.ActionToolBarButton {
                    iconName: "window-close"
                    onClicked: root.close()
                }
            }
        }
        
        // Quick Actions Grid
        Kirigami.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            GridLayout {
                id: quickActionsGrid
                columns: 4
                rows: 2
                spacing: 12
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 16
                
                // Quick Action Buttons
                Repeater {
                    model: [
                        { id: "wifi", name: qsTr("WiFi"), icon: "network-wireless", checkable: true, checked: true },
                        { id: "bluetooth", name: qsTr("Bluetooth"), icon: "bluetooth", checkable: true, checked: true },
                        { id: "rotation", name: qsTr("Rotation"), icon: "screen-rotation", checkable: true, checked: false },
                        { id: "location", name: qsTr("Location"), icon: "location", checkable: true, checked: true },
                        { id: "airplane", name: qsTr("Airplane"), icon: "airplane", checkable: true, checked: false },
                        { id: "vpn", name: qsTr("VPN"), icon: "network-vpn", checkable: true, checked: false },
                        { id: "hotspot", name: qsTr("Hotspot"), icon: "network-hotspot", checkable: true, checked: false },
                        { id: "flashlight", name: qsTr("Flashlight"), icon: "flashlight", checkable: true, checked: false }
                    ]
                    
                    delegate: Kirigami.ActionToolBarButton {
                        text: model.name
                        iconName: model.icon
                        checkable: model.checkable
                        checked: model.checked
                        onClicked: {
                            model.checked = !model.checked
                            // Toggle actual setting
                        }
                    }
                }
            }
        }
        
        // Brightness Slider
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "transparent"
            Layout.margins: 16
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 8
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Label {
                        text: qsTr("Brightness")
                        font.pixelSize: 16
                        color: Kirigami.Theme.textColor
                    }
                    
                    Layout.fillWidth: true
                    
                    Label {
                        text: Math.round(brightness * 100) + "%"
                        color: Kirigami.Theme.textColor
                        opacity: 0.7
                    }
                }
                
                Slider {
                    id: brightnessSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: 0.7
                    stepSize: 0.05
                }
            }
        }
        
        // Quick Settings Buttons
        GridLayout {
            columns: 4
            spacing: 8
            Layout.fillWidth: true
            Layout.margins: 16
            
            Repeater {
                model: [
                    { id: "rotation", name: qsTr("Rotation"), icon: "screen-rotation", checkable: true },
                    { id: "location", name: qsTr("Location"), icon: "location", checkable: true },
                    { id: "airplane", name: qsTr("Airplane"), icon: "airplane", checkable: true },
                    { id: "hotspot", name: qsTr("Hotspot"), icon: "network-hotspot", checkable: true }
                ]
                
                delegate: Kirigami.ActionToolBarButton {
                    text: model.name
                    iconName: model.icon
                    checkable: model.checkable
                    checked: model.checked
                    onClicked: model.checked = !model.checked
                }
            }
        }
        
        // Notifications Section
        Rectangle {
            Layout.fillWidth: true
            color: "transparent"
            Layout.margins: 16
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 8
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Label {
                        text: qsTr("Notifications")
                        font.pixelSize: 18
                        font.bold: true
                        color: Kirigami.Theme.textColor
                    }
                    
                    Layout.fillWidth: true
                    
                    Kirigami.ActionToolBarButton {
                        iconName: "clear-all"
                        text: qsTr("Clear all")
                        onClicked: {
                            // Clear all notifications
                        }
                    }
                }
                
                // Notifications list
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    clip: true
                    
                    model: 5 // placeholder
                    delegate: Kirigami.Card {
                        Layout.fillWidth: true
                        Layout.minHeight: 80
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4
                            
                            RowLayout {
                                Layout.fillWidth: true
                                
                                Rectangle {
                                    width: 48
                                    height: 48
                                    radius: 24
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
                        
                        onClicked: {
                            // Open notification
                        }
                    }
                }
            }
        }
    }
}