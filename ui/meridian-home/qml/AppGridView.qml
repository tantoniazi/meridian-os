import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kirigami

Kirigami.ScrollView {
    id: root
    
    property var model
    property int columns: 4
    property int spacing: 16
    
    clip: true
    
    GridView {
        id: gridView
        anchors.fill: parent
        cellWidth: (width - (root.columns + 1) * root.spacing) / root.columns
        cellHeight: (width - (root.columns + 1) * root.spacing) / root.columns * 1.3
        model: root.model
        
        delegate: AppTileDelegate {
            required property var model
            required property int index
            
            width: gridView.cellWidth
            height: gridView.cellHeight
        }
    }
}

Component {
    id: AppTileDelegate
    
    required property var model
    required property int index
    
    Kirigami.Card {
        id: tile
        width: parent ? parent.gridView.cellWidth : 80
        height: parent ? parent.gridView.cellHeight : 100
        
        property bool pressed: false
        
        // Badge
        Rectangle {
            id: badgeRect
            visible: model.badge && model.badge > 0
            anchors.right: parent.right
            anchors.top: parent.top
            width: Math.max(24, height)
            height: 20
            radius: 10
            color: Kirigami.Theme.errorColor
            
            Text {
                anchors.centerIn: parent
                text: model.badge > 99 ? "99+" : model.badge
                color: "white"
                font.pixelSize: 12
                font.bold: true
            }
        }
        
        // Content
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4
            alignment: Qt.AlignHCenter | Qt.AlignTop
            
            // Front content
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height * 0.7
                
                Image {
                    anchors.centerIn: parent
                    source: model.icon
                    width: 48
                    height: 48
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(48, 48)
                    asynchronous: true
                    visible: model.icon && model.icon !== ""
                    
                    // Placeholder for text content
                    Text {
                        visible: !model.icon || model.icon === ""
                        anchors.centerIn: parent
                        text: "[App]"
                        color: Kirigami.Theme.textColor
                        font.pixelSize: 24
                    }
                }
            }
            
            // Title
            Text {
                text: model.name
                font.pixelSize: 14
                font.bold: true
                color: Kirigami.Theme.textColor
                horizontalAlignment: Qt.AlignHCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            
            // Badge count
            Rectangle {
                visible: model.badge && model.badge > 0
                Layout.alignment: Qt.AlignHCenter
                height: 20
                width: Math.max(40, implicitWidth + 12)
                radius: 10
                color: Kirigami.Theme.errorColor
                
                Text {
                    anchors.centerIn: parent
                    text: model.badge > 99 ? "99+" : model.badge
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }
        
        // Flip animation on click
        property bool flipped: false
        
        MouseArea {
            anchors.fill: parent
            onPressed: {
                tile.flipped = true
            }
            onReleased: {
                tile.flipped = false
            }
            onClicked: {
                // Launch app
            }
        }
        
        // Flip animation
        states: [
            State {
                name: "flipped"
                when: flipped
                PropertyChanges { target: tile; rotation: 180 }
            }
        ]
        
        transitions: [
            Transition {
                from: ""
                to: "flipped"
                NumberAnimation { property: "rotation"; duration: 600; easing.type: Easing.InOutQuad }
            },
            Transition {
                from: "flipped"
                to: ""
                NumberAnimation { property: "rotation"; duration: 600; easing.type: Easing.InOutQuad }
            }
        ]
    }
}