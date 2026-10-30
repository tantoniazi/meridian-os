import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kirigami

Kirigami.Page {
    id: root
    
    property AppModel appModel
    property WidgetModel widgetModel
    property SettingsModel settingsModel
    property int currentPivot: 1
    property bool showSearch: false
    property bool showAppDrawer: false
    
    signal showSearchChanged
    signal showAppDrawerChanged
    
    // Header
    Kirigami.PageHeader {
        id: pageHeader
        title: ""
        
        actions {
            Kirigami.Action {
                iconName: "view-grid"
                text: qsTr("Apps")
                onTriggered: root.currentPivot = 1
            }
            
            Kirigami.Action {
                iconName: "search"
                text: qsTr("Search")
                onTriggered: root.showSearch = true
            }
        }
    }
    
    // Pivot tabs
    Kirigami.Pager {
        id: pager
        currentIndex: root.currentPivot
        onCurrentIndexChanged: root.currentPivot = currentIndex
        
        // Pivot 0: Events/Widgets
        Kirigami.Page {
            title: qsTr("Events")
            
            ColumnLayout {
                anchors.fill: parent
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Kirigami.Units.smallSpacing
                
                // Upcoming events placeholder
                Kirigami.Card {
                    Layout.fillWidth: true
                    Layout.margins: Kirigami.Units.largeSpacing
                    
                    ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing
                        
                        Label {
                            text: qsTr("Upcoming Events")
                            font.pixelSize: Kirigami.Units.gridUnit * 2
                            font.bold: true
                            color: Kirigami.Theme.textColor
                        }
                        
                        Label {
                            text: qsTr("No upcoming events")
                            color: Kirigami.Theme.textColor
                            opacity: 0.7
                        }
                    }
                }
                
                // Widgets section
                Kirigami.Separator {}
                
                Label {
                    text: qsTr("Widgets")
                    font.pixelSize: Kirigami.Units.gridUnit * 2
                    font.bold: true
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                }
                
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.widgetModel
                    spacing: Kirigami.Units.smallSpacing
                    Layout.margins: Kirigami.Units.mediumSpacing
                    
                    delegate: Kirigami.Card {
                        Layout.fillWidth: true
                        Layout.minHeight: Kirigami.Units.gridUnit * 10
                        
                        ColumnLayout {
                            spacing: Kirigami.Units.smallSpacing
                            Layout.fillWidth: true
                            
                            Label {
                                text: model.name
                                font.pixelSize: Kirigami.Units.gridUnit * 2
                                font.bold: true
                                color: Kirigami.Theme.textColor
                            }
                            
                            Label {
                                text: model.description
                                color: Kirigami.Theme.textColor
                                opacity: 0.7
                            }
                        }
                        
                        onClicked: {
                            // Add widget to home screen
                        }
                    }
                }
            }
        }
        
        // Pivot 1: Apps (Main)
        Kirigami.Page {
            title: qsTr("Apps")
            
            ColumnLayout {
                anchors.fill: parent
                spacing: Kirigami.Units.mediumSpacing
                
                // Search bar
                Kirigami.SearchField {
                    Layout.fillWidth: true
                    Layout.margins: Kirigami.Units.largeSpacing
                    placeholderText: qsTr("Search apps...")
                    onTextChanged: {
                        // Filter apps
                    }
                }
                
                // App grid
                AppGridView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.appModel
                    columns: root.gridColumns
                }
            }
        }
        
        // Pivot 2: Settings
        Kirigami.Page {
            title: qsTr("Settings")
            
            Kirigami.ScrollView {
                anchors.fill: parent
                
                Kirigami.FormLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Kirigami.Units.largeSpacing
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    
                    // Theme section
                    Kirigami.FormLayout.Label {
                        text: qsTr("Appearance")
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
                    
                    // Power section
                    Kirigami.FormLayout.Label {
                        text: qsTr("Power")
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
                        text: qsTr("Language")
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
                }
            }
        }
    }
}