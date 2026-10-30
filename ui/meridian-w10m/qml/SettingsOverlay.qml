import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kirigami
import QtQuick.Controls.Material
import QtQuick.Controls.Universal

// Settings Overlay - Windows 10 Mobile Style
Kirigami.OverlaySheet {
    id: root
    
    property SettingsModel settingsModel
    
    width: parent.width
    height: parent.height
    modal: true
    closePolicy: Kirigami.OverlaySheet.ClickOutside | Kirigami.OverlaySheet.EscapeKey
    
    // Animation
    enter: Transition {
        NumberAnimation { property: "x"; from: parent.width; to: 0; duration: 300; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "x"; from: 0; to: parent.width; duration: 200; easing.type: Easing.InCubic }
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
                    text: qsTr("Settings")
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
        
        // Settings Content
        Kirigami.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Kirigami.FormLayout {
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.largeSpacing
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.rightMargin: Kirigami.Units.largeSpacing
                
                // Personalization section
                Kirigami.FormLayout.Label {
                    text: qsTr("Personalization")
                    Layout.fillWidth: true
                    font.bold: true
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.ComboBox {
                        model: ["dark", "light", "high-contrast"]
                        currentText: root.settingsModel.theme
                        onCurrentTextChanged: root.settingsModel.theme = currentText
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.ColorButton {
                        color: root.settingsModel.accentColor
                        onColorChanged: root.settingsModel.accentColor = color
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Switch {
                        checked: root.settingsModel.darkMode
                        onClicked: root.settingsModel.darkMode = checked
                        text: qsTr("Dark mode")
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Switch {
                        checked: root.settingsModel.highContrast
                        onClicked: root.settingsModel.highContrast = checked
                        text: qsTr("High contrast")
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Switch {
                        checked: root.settingsModel.reducedMotion
                        onClicked: root.settingsModel.reducedMotion = checked
                        text: qsTr("Reduce motion")
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Switch {
                        checked: root.settingsModel.transparentTiles
                        onClicked: root.settingsModel.transparentTiles = checked
                        text: qsTr("Transparent tiles")
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Switch {
                        checked: root.settingsModel.showMoreTiles
                        onClicked: root.settingsModel.showMoreTiles = checked
                        text: qsTr("Show more tiles")
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Button {
                        text: qsTr("Choose lock screen background")
                        Layout.fillWidth: true
                        onClicked: {
                            // Open file picker
                        }
                    }
                }
                
                // Display section
                Kirigami.FormLayout.Label {
                    text: qsTr("Display")
                    Layout.fillWidth: true
                    font.bold: true
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Slider {
                        from: 8
                        to: 32
                        value: root.settingsModel.fontSize
                        onValueChanged: root.settingsModel.fontSize = value
                        Layout.fillWidth: true
                    }
                    Kirigami.FormLayout.Label {
                        text: qsTr("Font size: %1").arg(root.settingsModel.fontSize)
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Switch {
                        checked: root.settingsModel.autoRotate
                        onClicked: root.settingsModel.autoRotate = checked
                        text: qsTr("Auto-rotate")
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Slider {
                        from: 15
                        to: 3600
                        value: root.settingsModel.screenTimeout
                        onValueChanged: root.settingsModel.screenTimeout = value
                        Layout.fillWidth: true
                    }
                    Kirigami.FormLayout.Label {
                        text: qsTr("Screen timeout: %1 sec").arg(root.settingsModel.screenTimeout)
                    }
                }
                
                // Power section
                Kirigami.FormLayout.Label {
                    text: qsTr("Battery & Power")
                    Layout.fillWidth: true
                    font.bold: true
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.ComboBox {
                        model: ["performance", "balanced", "powersave", "ultra-powersave"]
                        currentText: root.settingsModel.powerProfile
                        onCurrentTextChanged: root.settingsModel.powerProfile = currentText
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Slider {
                        from: 15
                        to: 3600
                        value: root.settingsModel.screenTimeout
                        onValueChanged: root.settingsModel.screenTimeout = value
                        Layout.fillWidth: true
                    }
                    Kirigami.FormLayout.Label {
                        text: qsTr("Screen timeout: %1 sec").arg(root.settingsModel.screenTimeout)
                    }
                }
                
                // Language section
                Kirigami.FormLayout.Label {
                    text: qsTr("Language & Region")
                    Layout.fillWidth: true
                    font.bold: true
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.ComboBox {
                        model: ["en_US", "pt_BR", "es_ES", "fr_FR", "de_DE", "zh_CN", "ja_JP"]
                        currentText: root.settingsModel.language
                        onCurrentTextChanged: root.settingsModel.language = currentText
                    }
                }
                
                // Accessibility section
                Kirigami.FormLayout.Label {
                    text: qsTr("Accessibility")
                    Layout.fillWidth: true
                    font.bold: true
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Switch {
                        checked: root.settingsModel.reducedMotion
                        onClicked: root.settingsModel.reducedMotion = checked
                        text: qsTr("Reduce motion")
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Switch {
                        checked: root.settingsModel.highContrast
                        onClicked: root.settingsModel.highContrast = checked
                        text: qsTr("High contrast")
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Switch {
                        checked: root.settingsModel.vibrationEnabled
                        onClicked: root.settingsModel.vibrationEnabled = checked
                        text: qsTr("Vibration")
                    }
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Kirigami.Switch {
                        checked: root.settingsModel.hapticFeedback
                        onClicked: root.settingsModel.hapticFeedback = checked
                        text: qsTr("Haptic feedback")
                    }
                }
                
                // About section
                Kirigami.FormLayout.Label {
                    text: qsTr("About")
                    Layout.fillWidth: true
                    font.bold: true
                }
                
                Kirigami.FormLayout.Field {
                    Layout.fillWidth: true
                    Label {
                        text: qsTr("Meridian W10M %1").arg("0.1.0")
                        color: Kirigami.Theme.textColor
                        opacity: 0.7
                    }
                }
            }
        }
    }
}