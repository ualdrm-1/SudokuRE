import QtQuick

Item {
    id: root
    signal loadingFinished()

    Rectangle {
        anchors.fill: parent
        color: "#0A0A0A"

        // ── Blood drips (rendered BEFORE text → appear behind it) ─────────
        Repeater {
            model: 12

            delegate: Item {
                id: dripItem

                // Varied target heights: mix of mid-screen and full-screen
                readonly property real targetH: {
                    var heights = [320, 580, 210, 660, 390, 480, 260, 640, 340, 520, 180, 600]
                    return heights[index]
                }
                // Varied grow speed: slow ooze feel
                readonly property int growDur:   1100 + (index * 137) % 700
                // Staggered start so they don't all begin at once
                readonly property int startDelay: (index * 251 + index * index * 19) % 900

                // Stream width: 2–4 px; droplet: 6–12 px
                readonly property int streamW:  2 + index % 3
                readonly property int dropW:    6 + (index % 3) * 3

                x: parent.width * (0.04 + index * 0.088) - dropW / 2
                y: 0
                width: dropW
                height: 0
                opacity: 0

                // ── Thin stream ───────────────────────────────────────────
                Rectangle {
                    anchors {
                        top:              parent.top
                        horizontalCenter: parent.horizontalCenter
                        bottom:           droplet.top
                    }
                    width:   dripItem.streamW
                    color:   "#CC0000"
                    opacity: 0.8
                    visible: dripItem.height > dripItem.dropW
                }

                // ── Rounded droplet at the tip ────────────────────────────
                Rectangle {
                    id: droplet
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    width:  dripItem.dropW
                    height: dripItem.dropW
                    radius: dripItem.dropW / 2
                    color:   "#CC0000"
                    opacity: 0.95
                    visible: dripItem.height >= dripItem.dropW
                }

                // ── Loop: stagger → grow+fade-in → hold → fade-out → reset ──
                SequentialAnimation {
                    running: true
                    loops:   Animation.Infinite

                    // Initial stagger (first cycle only feels different, but loops fine)
                    PauseAnimation { duration: dripItem.startDelay }

                    // Grow down while fading in
                    ParallelAnimation {
                        NumberAnimation {
                            target: dripItem; property: "height"
                            from: 0; to: dripItem.targetH
                            duration: dripItem.growDur
                            easing.type: Easing.InQuad
                        }
                        NumberAnimation {
                            target: dripItem; property: "opacity"
                            from: 0; to: 1
                            duration: 400
                        }
                    }

                    // Hold at full length
                    PauseAnimation { duration: 300 + (index * 83) % 500 }

                    // Smooth fade-out
                    NumberAnimation {
                        target: dripItem; property: "opacity"
                        from: 1; to: 0
                        duration: 800
                        easing.type: Easing.InOutQuad
                    }

                    // Instant reset before next cycle
                    PropertyAction { target: dripItem; property: "height"; value: 0 }

                    // Pause between cycles
                    PauseAnimation { duration: 400 + (index * 73) % 700 }
                }
            }
        }

        // ── Central content (rendered AFTER drips → always on top) ────────
        Column {
            anchors.centerIn: parent
            spacing: 32

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SUDOKU"
                    font.pixelSize: 64; font.bold: true; font.letterSpacing: 16
                    color: "#FFFFFF"
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "RESIDENT EVIL"
                    font.pixelSize: 22; font.letterSpacing: 8
                    color: "#CC0000"
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 300; height: 2; color: "#CC0000"; opacity: 0.8
                }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 90; height: 90; radius: 45
                color: "transparent"
                border.color: "#CC0000"; border.width: 2

                Text { anchors.centerIn: parent; text: "☣"; font.pixelSize: 46; color: "#CC0000" }

                RotationAnimation on rotation {
                    from: 0; to: 360; duration: 4000
                    loops: Animation.Infinite; running: true
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 400; height: 4; radius: 2; color: "#1A1A1A"

                    Rectangle {
                        height: parent.height; width: 0; radius: 2; color: "#CC0000"
                        NumberAnimation on width {
                            from: 0; to: 400; duration: 2400; running: true
                            easing.type: Easing.InOutCubic
                            onFinished: root.loadingFinished()
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "LOADING..."
                    font.pixelSize: 13; font.letterSpacing: 5; color: "#666666"
                }
            }
        }
    }
}
