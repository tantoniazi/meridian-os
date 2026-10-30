import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kirigami

// W10M Tile Delegate - Windows 10 Mobile Style Live Tile
Component {
    id: W10MTileDelegate
    
    required property var model
    required property int index
    required property int gridColumns
    required property SettingsModel settingsModel
    
    // Tile properties
    property bool flipped: false
    property bool pressed: false
    property int flipProgress: 0
    
    // Tile dimensions based on size
    property int tileWidth: Math.floor((gridView.width - (gridColumns + 1) * 12) / gridColumns)
    property int tileHeight: Math.floor(tileWidth * sizeMultiplier)
    
    property real sizeMultiplier: 
        model.size === "small" ? 1.0 :
        model.size === "medium" ? 2.0 :
        model.size === "wide" ? 2.0 :
        model.size === "large" ? 4.0 : 1.0
    
    property int rowSpan:
        model.size === "small" ? 1 :
        model.size === "medium" ? 2 :
        model.size === "wide" ? 2 :
        model.size === "large" ? 4 : 1
    
    property int colSpan:
        model.size === "small" ? 1 :
        model.size === "medium" ? 2 :
        model.size === "wide" ? 4 :
        model.size === "large" ? 4 : 1
    
    // Colors
    property color tileBackground: model.backgroundColor && model.backgroundColor !== "" ? model.backgroundColor : 
                                  (root.settingsModel.transparentTiles ? "transparent" : Kirigami.Theme.backgroundColor)
    property color tileForeground: model.foregroundColor && model.foregroundColor !== "" ? model.foregroundColor : Kirigami.Theme.textColor
    property color tileAccent: model.accentColor || root.settingsModel.accentColor
    
    // Tile size in grid units
    property int gridColumns: root.gridColumns
    
    GridLayout {
        id: tileGrid
        Layout.fillWidth: true
        Layout.fillHeight: true
        columns: root.gridColumns
        columnSpacing: 12
        rowSpacing: 12
        anchors.fill: parent
        anchors.margins: 12
        
        Repeater {
            model: tileModel
            
            TileItem {
                modelData: modelData
                index: index
                gridColumns: root.gridColumns
                settingsModel: root.settingsModel
            }
        }
    }
}

// Individual Tile Component
Component {
    id: W10MTileItem
    
    required property var modelData
    required property int index
    required property int gridColumns
    required property SettingsModel settingsModel
    
    property bool flipped: false
    property bool pressed: false
    property real flipProgress: 0
    
    // Size multiplier based on tile size
    property real sizeMultiplier: 
        modelData.size === "small" ? 1.0 :
        modelData.size === "medium" ? 2.0 :
        modelData.size === "wide" ? 2.0 :
        modelData.size === "large" ? 4.0 : 1.0
    
    property int rowSpan:
        modelData.size === "small" ? 1 :
        modelData.size === "medium" ? 2 :
        modelData.size === "wide" ? 2 :
        modelData.size === "large" ? 4 : 1
    
    property int colSpan:
        modelData.size === "small" ? 1 :
        modelData.size === "medium" ? 2 :
        modelData.size === "wide" ? 4 :
        modelData.size === "large" ? 4 : 1
    
    // Colors
    property color tileBackground: modelData.backgroundColor && modelData.backgroundColor !== "" ? modelData.backgroundColor : 
                                  (root.settingsModel.transparentTiles ? "transparent" : Kirigami.Theme.backgroundColor)
    property color tileForeground: modelData.foregroundColor && modelData.foregroundColor !== "" ? modelData.foregroundColor : Kirigami.Theme.textColor
    property color tileAccent: modelData.accentColor || root.settingsModel.accentColor
    
    GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        columnSpacing: 12
        rowSpacing: 12
        columns: 1 // Handled by GridLayout parent
        
        // Main tile
        Rectangle {
            id: tileRect
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.columnSpan: tile.colSpan
            Layout.rowSpan: tile.rowSpan
            
            property bool flipped: false
            property bool pressed: false
            
            radius: 4
            color: tileBackground
            border.color: root.settingsModel.transparentTiles ? "transparent" : Kirigami.Theme.highlightColor
            border.width: root.settingsModel.transparentTiles ? 0 : 1
            
            // Shadow
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: 4
                samples: 8
                color: Qt.rgba(0, 0, 0, 0.3)
            }
            
            // Clip for flip animation
            clip: true
            
            // Flip animation
            property real flipProgress: 0
            
            transform: [
                Rotation {
                    origin.x: width / 2
                    origin.y: height / 2
                    axis.x: tile.flipHorizontal ? 0 : 1
                    axis.y: tile.flipHorizontal ? 1 : 0
                    axis.z: 0
                    angle: tile.flipProgress * 180
                }
            ]
            
            // Flip animation
            states: [
                State {
                    name: "flipped"
                    when: flipped
                    PropertyChanges { target: tileRect; flipProgress: 1 }
                }
            ]
            
            transitions: [
                Transition {
                    from: ""
                    to: "flipped"
                    SequentialAnimation {
                        NumberAnimation { property: "flipProgress"; duration: 300; easing.type: Easing.InQuad }
                        NumberAnimation { property: "flipProgress"; duration: 300; easing.type: Easing.OutQuad }
                    }
                }
            ]
            
            // Badge
            Rectangle {
                id: badgeRect
                visible: modelData.badge && modelData.badge > 0
                anchors.right: parent.right
                anchors.top: parent.top
                width: Math.max(24, height)
                height: 20
                radius: 10
                color: Kirigami.Theme.errorColor
                anchors.margins: 8
                
                Text {
                    anchors.centerIn: parent
                    text: modelData.badge > 99 ? "99+" : modelData.badge
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
            
            // Content
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8
                alignment: Qt.AlignHCenter | Qt.AlignTop
                
                // Content area
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 0.7
                    
                    // Front content
                    Loader {
                        id: frontContent
                        sourceComponent: modelData.type === "flip" ? flipBackContent : frontContentComponent
                    }
                }
                
                // Title
                Text {
                    text: modelData.title
                    font.pixelSize: 16
                    font.bold: true
                    color: tileForeground
                    horizontalAlignment: Qt.AlignHCenter
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                // Badge count
                Rectangle {
                    visible: modelData.badge && modelData.badge > 0
                    Layout.alignment: Qt.AlignHCenter
                    height: 20
                    width: Math.max(40, implicitWidth + 12)
                    radius: 10
                    color: tileAccent
                    
                    Text {
                        anchors.centerIn: parent
                        text: modelData.badge > 99 ? "99+" : modelData.badge
                        color: "white"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
            
            // Back content (for flip tiles)
            Component {
                id: flipBackContent
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8
                    alignment: Qt.AlignCenter
                    
                    Text {
                        text: modelData.description || "Live Tile Content"
                        font.pixelSize: 16
                        color: tileForeground
                        horizontalAlignment: Qt.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
            
            // Front content component
            Component {
                id: frontContentComponent
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    alignment: Qt.AlignHCenter | Qt.AlignTop
                    
                    // Icon or image
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height * 0.6
                        
                        Image {
                            source: modelData.icon
                            width: 48
                            height: 48
                            fillMode: Image.PreserveAspectFit
                            sourceSize: Qt.size(48, 48)
                            asynchronous: true
                            visible: modelData.icon && modelData.icon !== ""
                            
                            // Placeholder for text content
                            Text {
                                visible: !modelData.icon || modelData.icon === ""
                                anchors.centerIn: parent
                                text: "[" + (modelData.size === "small" ? "S" : modelData.size === "medium" ? "M" : modelData.size === "wide" ? "W" : "L") + "]"
                                color: tileForeground
                                font.pixelSize: 24
                            }
                        }
                    }
                    
                    // Live content
                    Text {
                        text: modelData.liveContent || ""
                        font.pixelSize: 14
                        color: tileForeground
                        horizontalAlignment: Qt.AlignHCenter
                        wrapMode: Text.WordWrap
                        visible: modelData.liveContent && modelData.liveContent !== ""
                    }
                    
                    // Title
                    Text {
                        text: modelData.title
                        font.pixelSize: 14
                        font.bold: true
                        color: tileForeground
                        horizontalAlignment: Qt.AlignHCenter
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    
                    // Badge count
                    Rectangle {
                        visible: modelData.badge && modelData.badge > 0
                        Layout.alignment: Qt.AlignHCenter
                        height: 20
                        width: Math.max(40, implicitWidth + 12)
                        radius: 10
                        color: tileAccent
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.badge > 99 ? "99+" : modelData.badge
                            color: "white"
                            font.pixelSize: 12
                            font.bold: true
                        }
                    }
                }
            }
            
            // Flip animation on click
            MouseArea {
                anchors.fill: parent
                onPressed: tileRect.flipped = true
                onReleased: tileRect.flipped = false
                onClicked: {
                    // Launch app
                }
            }
            
            // Long press for move/resize
            MouseArea {
                anchors.fill: parent
                onPressAndHold: {
                    // Show context menu for move/resize/unpin
                }
            }
        }
    }
}