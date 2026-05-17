import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    signal startGame(int difficulty)
    signal showLeaderboard()

    property var difficultyLabels: ["EASY", "MEDIUM", "HARD"]
    property var difficultyDescs: [
        "40 clues · 3 mistakes",
        "30 clues · 3 mistakes",
        "22 clues · 3 mistakes"
    ]
    property var difficultyColors: ["#2E7D32", "#F57F17", "#B71C1C"]

    Rectangle {
        anchors.fill: parent
        color: "#0A0A0A"

        // Entrance fade-in
        opacity: 0
        Component.onCompleted: entranceFade.start()
        NumberAnimation { id: entranceFade; target: parent; property: "opacity"; from: 0; to: 1; duration: 600; easing.type: Easing.InOutQuad }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 0

            // Header
            Item { Layout.fillHeight: true; Layout.preferredHeight: 1 }

            Column {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SRE"
                    font.pixelSize: 56
                    font.bold: true
                    font.letterSpacing: 14
                    color: "#FFFFFF"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SUDOKU RESIDENT EVIL"
                    font.pixelSize: 13
                    font.letterSpacing: 4
                    color: "#CC0000"
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 180
                    height: 1
                    color: "#CC0000"
                    opacity: 0.6
                    Layout.topMargin: 8
                }
            }

            Item { Layout.fillHeight: true; Layout.preferredHeight: 1 }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "SELECT DIFFICULTY"
                font.pixelSize: 13
                font.letterSpacing: 5
                color: "#666666"
            }

            Item { height: 16 }

            // Difficulty buttons
            Column {
                Layout.alignment: Qt.AlignHCenter
                spacing: 14

                Repeater {
                    model: 3
                    delegate: DifficultyButton {
                        label: root.difficultyLabels[index]
                        description: root.difficultyDescs[index]
                        accentColor: root.difficultyColors[index]
                        onClicked: root.startGame(index)
                    }
                }
            }

            Item { Layout.fillHeight: true; Layout.preferredHeight: 1 }

            // Leaderboard link
            Item {
                Layout.alignment: Qt.AlignHCenter
                width: leaderBtn.width + 16
                height: leaderBtn.height + 12

                Text {
                    id: leaderBtn
                    anchors.centerIn: parent
                    text: "LEADERBOARD"
                    font.pixelSize: 13
                    font.letterSpacing: 4
                    color: "#444444"

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showLeaderboard()
                        onPressed: leaderBtn.color = "#CC0000"
                        onReleased: leaderBtn.color = "#444444"
                    }
                }
            }

            Item { Layout.fillHeight: true; Layout.preferredHeight: 1 }
        }
    }

    component DifficultyButton: Rectangle {
        id: btn
        width: 280
        height: 72
        radius: 6
        color: ma.pressed ? Qt.darker(accentColor, 1.5) : "#111111"
        border.color: accentColor
        border.width: ma.containsMouse ? 2 : 1
        scale: ma.pressed ? 0.96 : 1.0

        property string label: ""
        property string description: ""
        property color accentColor: "#CC0000"

        signal clicked()

        Behavior on border.width { NumberAnimation { duration: 120 } }
        Behavior on color  { ColorAnimation  { duration: 120 } }
        Behavior on scale  { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }

        // Left accent bar
        Rectangle {
            width: 4
            height: parent.height - 16
            anchors { left: parent.left; leftMargin: 0; verticalCenter: parent.verticalCenter }
            radius: 2
            color: btn.accentColor
        }

        Column {
            anchors {
                left: parent.left; leftMargin: 20
                verticalCenter: parent.verticalCenter
            }
            spacing: 4

            Text {
                text: btn.label
                font.pixelSize: 20
                font.bold: true
                font.letterSpacing: 4
                color: "#FFFFFF"
            }
            Text {
                text: btn.description
                font.pixelSize: 12
                color: "#666666"
            }
        }

        // Arrow
        Text {
            anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
            text: "›"
            font.pixelSize: 28
            color: btn.accentColor
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }
}
