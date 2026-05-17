import QtQuick
import QtQuick.Controls

Item {
    id: root
    signal loadingFinished()

    Rectangle {
        anchors.fill: parent
        color: "#0A0A0A"

        // Blood drip decorative lines
        Repeater {
            model: 6
            Rectangle {
                x: 30 + index * 60
                y: 0
                width: 3
                height: dripAnim.running ? 120 + (index * 20) : 0
                color: "#CC0000"
                opacity: 0.6
                radius: 2
                NumberAnimation on height {
                    id: dripAnim
                    from: 0
                    to: 120 + index * 20
                    duration: 800 + index * 150
                    running: true
                    easing.type: Easing.InQuad
                }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 32

            // Logo / Title
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SUDOKU"
                    font.pixelSize: 48
                    font.bold: true
                    font.letterSpacing: 12
                    color: "#FFFFFF"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "RESIDENT EVIL"
                    font.pixelSize: 20
                    font.letterSpacing: 6
                    color: "#CC0000"
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 200
                    height: 2
                    color: "#CC0000"
                    opacity: 0.8
                }
            }

            // Umbrella Corp logo placeholder
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 80
                height: 80
                radius: 40
                color: "transparent"
                border.color: "#CC0000"
                border.width: 2

                Text {
                    anchors.centerIn: parent
                    text: "☣"
                    font.pixelSize: 40
                    color: "#CC0000"
                }

                RotationAnimation on rotation {
                    from: 0; to: 360
                    duration: 4000
                    loops: Animation.Infinite
                    running: true
                }
            }

            // Progress bar
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Rectangle {
                    width: 240
                    height: 4
                    radius: 2
                    color: "#1A1A1A"

                    Rectangle {
                        id: progressBar
                        height: parent.height
                        width: 0
                        radius: 2
                        color: "#CC0000"
                        NumberAnimation on width {
                            from: 0
                            to: 240
                            duration: 2200
                            running: true
                            easing.type: Easing.InOutCubic
                            onFinished: root.loadingFinished()
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "LOADING..."
                    font.pixelSize: 12
                    font.letterSpacing: 4
                    color: "#666666"
                }
            }
        }
    }
}
