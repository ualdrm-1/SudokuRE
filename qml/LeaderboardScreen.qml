import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import AlinaRE

Item {
    id: root
    required property LeaderboardModel leaderboard
    signal goBack()

    Rectangle {
        anchors.fill: parent
        color: "#0A0A0A"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            // Header
            Item {
                Layout.fillWidth: true
                height: 44

                Rectangle {
                    id: backBtn
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                    width: 36; height: 36; radius: 18
                    color: backMa.pressed ? "#CC0000" : "#1A1A1A"
                    Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 22; color: "#FFFFFF" }
                    MouseArea { id: backMa; anchors.fill: parent; onClicked: root.goBack() }
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Text {
                    anchors.centerIn: parent
                    text: "LEADERBOARD"
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: 5
                    color: "#FFFFFF"
                }
            }

            // Column headers
            Row {
                Layout.fillWidth: true
                Repeater {
                    model: ["RANK", "SCORE", "TIME", "DIFF", "DATE"]
                    delegate: Text {
                        width: [40, 80, 60, 60, 90][index]
                        text: modelData
                        font.pixelSize: 10
                        font.letterSpacing: 2
                        color: "#555555"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#1E1E1E" }

            // Entries
            ListView {
                id: leaderListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: root.leaderboard
                clip: true
                spacing: 4

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 40
                    radius: 4
                    color: index === 0 ? "#1A1000" : index % 2 === 0 ? "#111111" : "#0D0D0D"
                    border.color: index === 0 ? "#CC8800" : "transparent"

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left

                        Text {
                            width: 40
                            text: "#" + (index + 1)
                            font.pixelSize: 13
                            font.bold: index === 0
                            color: index === 0 ? "#CC8800" : "#666666"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Text {
                            width: 80
                            text: score
                            font.pixelSize: 14
                            font.bold: true
                            color: "#FFFFFF"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Text {
                            width: 60
                            text: {
                                let m = Math.floor(seconds / 60)
                                let s = seconds % 60
                                return (m < 10 ? "0"+m : m) + ":" + (s < 10 ? "0"+s : s)
                            }
                            font.pixelSize: 12
                            color: "#AAAAAA"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Text {
                            width: 60
                            text: difficultyName
                            font.pixelSize: 12
                            color: difficulty === 0 ? "#2E7D32" : difficulty === 1 ? "#F57F17" : "#B71C1C"
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Text {
                            width: 90
                            text: date
                            font.pixelSize: 11
                            color: "#555555"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: leaderListView.count === 0
                    text: "No records yet.\nPlay and win to set a score!"
                    horizontalAlignment: Text.AlignHCenter
                    color: "#444444"
                    font.pixelSize: 14
                }
            }
        }
    }
}
