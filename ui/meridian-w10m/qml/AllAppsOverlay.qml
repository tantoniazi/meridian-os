import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kirigami
import QtQuick.Controls.Material
import QtQuick.Controls.Universal

// All Apps Overlay - Windows 10 Mobile Style
Kirigami.OverlaySheet {
    id: root
    
    property AppModel appModel
    property SettingsModel settingsModel
    
    width: parent.width
    height: parent.height
    modal: true
    closePolicy: Kirigami.OverlaySheet.ClickOutside | Kirigami.OverlaySheet.EscapeKey
    
    // Animation
    enter: Transition {
        NumberAnimation { property: "y"; from: parent.height; to: 0; duration: 300; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "y"; from: 0; to: parent.height; duration: 200; easing.type: Easing.InCubic }
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
                    text: qsTr("All Apps")
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
        
        // Search Bar
        Rectangle {
            Layout.fillWidth: true
            height: 56
            color: Kirigami.Theme.backgroundColor
            border.color: Kirigami.Theme.highlightColor
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                Layout.margins: 16
                spacing: 12
                
                Kirigami.SearchField {
                    Layout.fillWidth: true
                    placeholderText: qsTr("Search apps...")
                    onTextChanged: {
                        // Filter apps
                        appModel.filter = text
                    }
                }
                
                Kirigami.ActionToolBarButton {
                    iconName: "microphone"
                    onClicked: {
                        // Voice search
                    }
                }
            }
        }
        
        // Apps Grid
        Kirigami.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            GridView {
                id: appsGrid
                anchors.fill: parent
                cellWidth: (width - (columns + 1) * 12) / columns
                cellHeight: 100
                model: appModel
                
                property int columns: width < 600 ? 4 : (width < 900 ? 5 : 6)
                
                delegate: AppTileDelegate {
                    required property var model
                    required property int index
                    
                    width: appsGrid.cellWidth
                    height: appsGrid.cellHeight
                }
            }
        }
        
        // Alphabetical jump list
        Rectangle {
            Layout.fillWidth: true
            height: 40
            color: "transparent"
            
            RowLayout {
                anchors.fill: parent
                spacing: 0
                
                Repeater {
                    model: ["A","B","C","D","E","F","G","H","I","J","K","L","M",
                            "N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
                    
                    delegate: Kirigami.ActionToolBarButton {
                        text: modelData
                        font.pixelSize: 12
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        onClicked: {
                            // Scroll to letter section
                            appModel.scrollToLetter(modelData)
                        }
                    }
                }
            }
        }
    }
    
    // Close action
    onClosed: {
        root.close()
    }
}