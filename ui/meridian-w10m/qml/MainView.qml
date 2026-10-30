import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kirigami
import QtQuick.Controls.Material
import QtQuick.Controls.Universal

Kirigami.Page {
    id: root
    
    property AppModel appModel
    property TileModel tileModel
    property SettingsModel settingsModel
    
    signal navigateTo(string view)
    
    // Grid columns responsive
    property int gridColumns: width < 600 ? 4 : (width < 900 ? 5 : (width < 1200 ? 6 : 8))
    
    // App bar
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
                iconName: "view-list"
                text: qsTr("All Apps")
                onTriggered: root.showAllApps = true
            }
            
            Kirigami.Action {
                iconName: "settings"
                text: qsTr("Settings")
                onTriggered: root.showSettings = true
            }
        }
    }
    
    // Pivot tabs
    Kirigami.Pager {
        id: pager
        currentIndex: root.currentPivot
        onCurrentIndexChanged: root.currentPivot = currentIndex
        
        // Pivot 0: Start Screen (Live Tiles)
        Kirigami.Page {
            title: qsTr("Start")
            
            ColumnLayout {
                anchors.fill: parent
                spacing: Kirigami.Units.smallSpacing
                
                // Header with date/time
                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: Kirigami.Units.largeSpacing
                    spacing: Kirigami.Units.smallSpacing
                    
                    ColumnLayout {
                        Label {
                            id: timeLabel
                            text: Qt.formatTime(new Date(), "hh:mm")
                            font.pixelSize: 48
                            font.bold: true
                            color: root.settingsModel.accentColor
                        }
                        
                        Label {
                            text: Qt.formatDate(new Date(), "dddd, MMMM d")
                            font.pixelSize: 16
                            color: Kirigami.Theme.textColor
                            opacity: 0.7
                        }
                    }
                    
                    Layout.fillWidth: true
                    
                    // Action center button
                    Kirigami.ActionToolBarButton {
                        iconName: "notifications"
                        onClicked: root.showActionCenter = true
                    }
                }
                
                // Live Tiles Grid
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    GridView {
                        id: tileGrid
                        anchors.fill: parent
                        cellWidth: (width - (root.gridColumns + 1) * 12) / root.gridColumns
                        cellHeight: (width - (root.gridColumns + 1) * 12) / root.gridColumns * 1.3
                        model: tileModel
                        delegate: W10MTileDelegate {
                            required property var model
                            required property int index
                            required property int gridColumns
                            
                            width: tileGrid.cellWidth
                            height: tileGrid.cellHeight
                        }
                    }
                }
            }
        }
        
        // Pivot 1: All Apps List
        Kirigami.Page {
            title: qsTr("All Apps")
            
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
                
                // App list with alphabetical grouping
                Kirigami.ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: appModel
                    spacing: 8
                    Layout.margins: Kirigami.Units.mediumSpacing
                    
                    delegate: Kirigami.AbstractListItem {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        
                        content: RowLayout {
                            anchors.fill: parent
                            spacing: 16
                            Layout.fillWidth: true
                            
                            // App icon
                            Image {
                                source: model.icon
                                width: 48
                                height: 48
                                fillMode: Image.PreserveAspectFit
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                
                                Label {
                                    text: model.name
                                    font.pixelSize: 20
                                    font.bold: true
                                    color: Kirigami.Theme.textColor
                                }
                                
                                Label {
                                    text: model.genericName
                                    color: Kirigami.Theme.textColor
                                    opacity: 0.7
                                }
                            }
                            
                            // Pin/unpin button
                            Kirigami.ActionToolBarButton {
                                iconName: model.isFavorite ? "star-filled" : "star"
                                onClicked: {
                                    if (model.isFavorite) {
                                        appModel.removeFromStart(model.id)
                                    } else {
                                        appModel.addToStart(model.id)
                                    }
                                }
                            }
                        }
                        
                        onClicked: {
                            appModel.launch(index)
                        }
                    }
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
                    
                    // Start screen section
                    Kirigami.FormLayout.Label {
                        text: qsTr("Start screen")
                        Layout.fillWidth: true
                        font.bold: true
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
                        Kirigami.Switch {
                            checked: root.settingsModel.transparentTiles
                            onClicked: root.settingsModel.transparentTiles = checked
                            text: qsTr("Transparent tiles")
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
                    
                    // Power profile quick actions
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        
                        Kirigami.Button {
                            Layout.fillWidth: true
                            text: qsTr("Performance")
                            onClicked: root.settingsModel.setPowerProfile("performance")
                            Layout.fillWidth: true
                        }
                        
                        Kirigami.Button {
                            Layout.fillWidth: true
                            text: qsTr("Balanced")
                            onClicked: root.settingsModel.setPowerProfile("balanced")
                            Layout.fillWidth: true
                        }
                        
                        Kirigami.Button {
                            Layout.fillWidth: true
                            text: qsTr("Power saver")
                            onClicked: root.settingsModel.setPowerProfile("powersave")
                            Layout.fillWidth: true
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
}