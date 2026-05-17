import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import AlinaRE

Item {
    id: root

    required property GameModel game
    required property LeaderboardModel leaderboard

    signal goBack()

    // ── Character data ────────────────────────────────────────────────────
    readonly property var charNames:     ["", "LEON", "CLAIRE", "JILL", "CHRIS", "ADA", "WESKER", "NEMESIS", "TYRANT", "ETHAN"]
    readonly property var charShort:     ["", "LE", "CL", "JI", "CH", "AD", "WE", "NE", "TY", "ET"]
    readonly property var charFileNames: ["", "leon", "claire", "jill", "chris", "ada", "wesker", "nemesis", "tyrant", "ethan"]
    readonly property var charColors: [
        "transparent",
        "#1565C0", "#AD1457", "#2E7D32", "#0277BD",
        "#B71C1C", "#4A148C", "#4E342E", "#37474F", "#E65100"
    ]

    function formatTime(s) {
        let m = Math.floor(s / 60), sec = s % 60
        return (m < 10 ? "0" + m : m) + ":" + (sec < 10 ? "0" + sec : sec)
    }

    function isSameGroup(a, b) {
        if (a < 0 || b < 0) return false
        let rA = Math.floor(a / 9), cA = a % 9, rB = Math.floor(b / 9), cB = b % 9
        return rA === rB || cA === cB ||
               (Math.floor(rA/3) === Math.floor(rB/3) && Math.floor(cA/3) === Math.floor(cB/3))
    }

    SoundEffect { id: sfxPlace;  volume: 0.7  /* source: "qrc:/qt/qml/AlinaRE/audio/place.wav"  */ }
    SoundEffect { id: sfxError;  volume: 0.8  /* source: "qrc:/qt/qml/AlinaRE/audio/error.wav"  */ }
    SoundEffect { id: sfxHint;   volume: 0.6  /* source: "qrc:/qt/qml/AlinaRE/audio/hint.wav"   */ }
    SoundEffect { id: sfxUndo;   volume: 0.5  /* source: "qrc:/qt/qml/AlinaRE/audio/undo.wav"   */ }
    SoundEffect { id: sfxWin;    volume: 1.0  /* source: "qrc:/qt/qml/AlinaRE/audio/win.wav"    */ }
    SoundEffect { id: sfxLose;   volume: 1.0  /* source: "qrc:/qt/qml/AlinaRE/audio/lose.wav"   */ }
    SoundEffect { id: sfxSelect; volume: 0.35 /* source: "qrc:/qt/qml/AlinaRE/audio/select.wav" */ }

    Connections {
        target: game
        function onPlaced(correct) {
            if (correct) sfxPlace.play()
            else { sfxError.play(); mistakesShake.restart() }
        }
        function onGameWonChanged()   { if (game.gameWon)  sfxWin.play()  }
        function onGameLostChanged()  { if (game.gameLost) sfxLose.play() }
        function onHintsLeftChanged() { sfxHint.play() }
    }

    SequentialAnimation {
        id: mistakesShake
        NumberAnimation { target: statsSection; property: "x"; to:  8; duration: 50 }
        NumberAnimation { target: statsSection; property: "x"; to: -8; duration: 50 }
        NumberAnimation { target: statsSection; property: "x"; to:  5; duration: 40 }
        NumberAnimation { target: statsSection; property: "x"; to: -5; duration: 40 }
        NumberAnimation { target: statsSection; property: "x"; to:  0; duration: 40 }
    }

    Rectangle { anchors.fill: parent; color: "#0A0A0A" }

    Row {
        anchors.fill: parent

        Item {
            id: leftPanel
            width: parent.width - rightPanel.width
            height: parent.height

            // Vertical divider
            Rectangle {
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: 1; color: "#222222"
            }

            Repeater {
                model: 10
                Rectangle {
                    x: leftPanel.width * (0.04 + index * 0.1)
                    y: 0
                    width: 2 + index % 2
                    height: 0
                    color: "#CC0000"
                    opacity: 0.2 + (index % 3) * 0.1
                    radius: 1

                    SequentialAnimation on height {
                        loops: Animation.Infinite
                        running: true
                        PauseAnimation  { duration: 600 + index * 400 }
                        NumberAnimation { from: 0; to: 50 + (index * 29) % 100; duration: 600 + index * 70; easing.type: Easing.InQuad }
                        PauseAnimation  { duration: 2000 + index * 300 }
                        NumberAnimation { from: 50 + (index * 29) % 100; to: 0; duration: 200 }
                    }
                }
            }

            Item {
                id: gridContainer
                property real gridSize: Math.min(leftPanel.width - 40, leftPanel.height - 40)
                property real cellSize: gridSize / 9
                width: gridSize; height: gridSize
                anchors.centerIn: parent

                Grid {
                    anchors.fill: parent
                    rows: 9; columns: 9

                    Repeater {
                        model: 81
                        delegate: SudokuCell {
                            width:  gridContainer.cellSize
                            height: gridContainer.cellSize
                            cellIndex:          index
                            cellValue:          game.board[index]   ?? 0
                            isClue:             (game.puzzle[index] ?? 0) !== 0
                            isSelected:         game.selectedCell === index
                            isHighlighted:      root.isSameGroup(game.selectedCell, index)
                            sameValueHighlight: game.selectedCell >= 0
                                                && (game.board[index] ?? 0) !== 0
                                                && (game.board[index] ?? 0) === (game.board[game.selectedCell] ?? 0)
                            isWrong:       !isClue && cellValue !== 0 && cellValue !== (game.solution[index] ?? 0)
                            notesMask:     game.notes[index] ?? 0
                            charColors:    root.charColors
                            charShort:     root.charShort
                            charFileNames: root.charFileNames
                            onCellTapped:  { sfxSelect.play(); game.selectedCell = index }
                        }
                    }
                }

                Repeater {
                    model: 4
                    Rectangle {
                        x: index * (gridContainer.cellSize * 3); y: 0
                        width: 2; height: gridContainer.gridSize
                        color: "#505050"; visible: index > 0
                    }
                }
                Repeater {
                    model: 4
                    Rectangle {
                        x: 0; y: index * (gridContainer.cellSize * 3)
                        width: gridContainer.gridSize; height: 2
                        color: "#505050"; visible: index > 0
                    }
                }
            }
        }

        Item {
            id: rightPanel
            width: 320
            height: parent.height

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Item {
                    Layout.fillWidth: true
                    height: 44

                    Rectangle {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        width: 36; height: 36; radius: 18
                        color: backMa.pressed ? "#CC0000" : "#1A1A1A"
                        scale: backMa.pressed ? 0.9 : 1.0
                        Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 22; color: "#FFFFFF" }
                        MouseArea {
                            id: backMa; anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.goBack()
                        }
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                    }

                    Text {
                        id: scoreText
                        anchors.centerIn: parent
                        text: game.score
                        font.pixelSize: 22; font.bold: true; color: "#FFFFFF"
                        onTextChanged: scorePulse.restart()
                        SequentialAnimation {
                            id: scorePulse
                            NumberAnimation { target: scoreText; property: "scale"; to: 1.3; duration: 120; easing.type: Easing.OutQuad }
                            NumberAnimation { target: scoreText; property: "scale"; to: 1.0; duration: 180; easing.type: Easing.InOutQuad }
                        }
                    }

                    Text {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        text: "SRE"
                        font.pixelSize: 16; font.bold: true; font.letterSpacing: 3
                        color: "#CC0000"
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#1E1E1E" }

                Item {
                    id: statsSection
                    Layout.fillWidth: true
                    height: 56

                    Grid {
                        anchors.fill: parent
                        columns: 2; rows: 2
                        columnSpacing: 0; rowSpacing: 6

                        Repeater {
                            model: [
                                { label: "ALL TIME",   value: leaderboard.allTimeHigh },
                                { label: "DIFFICULTY", value: game.difficultyName() },
                                { label: "MISTAKES",   value: game.mistakes + "/3" },
                                { label: "TIME",       value: root.formatTime(game.elapsedSeconds) }
                            ]
                            delegate: Column {
                                width: statsSection.width / 2
                                spacing: 1
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    font.pixelSize: 9; font.letterSpacing: 2; color: "#555555"
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.value
                                    font.pixelSize: 15; font.bold: true
                                    color: index === 2 && game.mistakes > 0 ? "#CC0000" : "#FFFFFF"
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#1E1E1E" }

                Grid {
                    id: actionGrid
                    Layout.fillWidth: true
                    columns: 2; spacing: 8

                    Repeater {
                        model: [
                            { icon: "↩", label: "Undo",  action: function() { sfxUndo.play(); game.undo() } },
                            { icon: "⌫", label: "Erase", action: function() { game.erase() } },
                            { icon: "✏", label: "Notes", action: function() { game.notesMode = !game.notesMode } },
                            { icon: "💡", label: "Hint",  action: function() { game.hint() } }
                        ]
                        delegate: Rectangle {
                            width: (actionGrid.width - 8) / 2; height: 54
                            radius: 8
                            color: actMa.pressed ? "#2A2A2A" : "#141414"
                            border.color: (index === 2 && game.notesMode) ? "#CC0000" : "#252525"
                            border.width: 1
                            scale: actMa.pressed ? 0.93 : 1.0
                            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Column {
                                anchors.centerIn: parent; spacing: 3
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.icon; font.pixelSize: 20
                                    color: (index === 2 && game.notesMode)       ? "#CC0000"
                                         : (index === 3 && game.hintsLeft === 0) ? "#333333"
                                         : "#CCCCCC"
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: index === 3 ? modelData.label + " (" + game.hintsLeft + ")" : modelData.label
                                    font.pixelSize: 10; color: "#666666"
                                }
                            }
                            MouseArea {
                                id: actMa; anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.action()
                            }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#1E1E1E" }

                Grid {
                    id: charGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3; spacing: 6

                    Repeater {
                        model: 9
                        delegate: Item {
                            id: charItem
                            width:  (charGrid.width - 12) / 3
                            height: width

                            scale: charMa.pressed ? 0.84 : 1.0
                            Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }

                            property int  usedCount: {
                                let cnt = 0
                                for (let i = 0; i < 81; i++)
                                    if ((game.board[i] ?? 0) === index + 1) cnt++
                                return cnt
                            }
                            property bool exhausted: usedCount >= 9

                            Rectangle {
                                id: charCircle
                                anchors.fill: parent
                                radius: 6
                                color: "#111111"
                                opacity: charItem.exhausted ? 0.3 : charMa.containsMouse ? 1.0 : 0.88
                                clip: true
                                Behavior on opacity { NumberAnimation { duration: 120 } }
                                Behavior on color   { ColorAnimation  { duration: 200 } }

                                Image {
                                    id: charImg
                                    anchors.fill: parent
                                    source: "qrc:/qt/qml/AlinaRE/resources/characters/"
                                            + root.charFileNames[index + 1] + ".png"
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    visible: status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: root.charShort[index + 1]
                                    font.pixelSize: Math.max(10, charCircle.width * 0.24)
                                    font.bold: true; color: "#FFFFFF"
                                    visible: charImg.status !== Image.Ready && !charItem.exhausted
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"; font.pixelSize: charCircle.width * 0.38
                                    color: "#555555"; visible: charItem.exhausted
                                }

                                Rectangle {
                                    anchors { bottom: parent.bottom; right: parent.right; margins: 2 }
                                    width: charCircle.width * 0.32; height: width; radius: width / 2
                                    color: "#000000"; opacity: 0.72
                                    visible: !charItem.exhausted
                                    Text {
                                        anchors.centerIn: parent
                                        text: 9 - charItem.usedCount
                                        font.pixelSize: Math.max(7, charCircle.width * 0.2)
                                        font.bold: true; color: "#FFFFFF"
                                    }
                                }

                            }

                            MouseArea {
                                id: charMa; anchors.fill: parent
                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                enabled: !charItem.exhausted
                                onClicked: game.placeCharacter(index + 1)
                            }
                        }
                    }
                }

                Item { height: 2 }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#CC000000"
        visible: game.gameWon || game.gameLost
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 350 } }

        Column {
             anchors.centerIn: parent; spacing: 28

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: game.gameWon ? "MISSION\nCOMPLETE" : "GAME\nOVER"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 56; font.bold: true; font.letterSpacing: 8
                color: game.gameWon ? "#FFFFFF" : "#CC0000"
                scale: (game.gameWon || game.gameLost) ? 1.0 : 0.6
                Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: game.gameWon
                      ? "Score: " + game.score + "     " + root.formatTime(game.elapsedSeconds)
                      : "3 mistakes · Game over"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 18; color: "#AAAAAA"
                opacity: (game.gameWon || game.gameLost) ? 1 : 0
                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation  { duration: 200 }
                        NumberAnimation { duration: 300 }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter; spacing: 16

                Rectangle {
                    width: 160; height: 50; radius: 25; color: "#CC0000"
                    scale: playMa.pressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                    Text { anchors.centerIn: parent; text: "PLAY AGAIN"; font.pixelSize: 14; font.bold: true; font.letterSpacing: 2; color: "#FFFFFF" }
                    MouseArea {
                        id: playMa; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (game.gameWon) leaderboard.addEntry(game.score, game.elapsedSeconds, game.difficulty)
                            game.newGame(game.difficulty)
                        }
                    }
                }

                Rectangle {
                    width: 120; height: 50; radius: 25
                    color: "#1A1A1A"; border.color: "#333333"
                    scale: menuMa.pressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
                    Text { anchors.centerIn: parent; text: "MENU"; font.pixelSize: 14; font.bold: true; font.letterSpacing: 2; color: "#FFFFFF" }
                    MouseArea {
                        id: menuMa; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (game.gameWon) leaderboard.addEntry(game.score, game.elapsedSeconds, game.difficulty)
                            root.goBack()
                        }
                    }
                }
            }
        }
    }

    component SudokuCell: Item {
        id: cell

        property int  cellIndex:          0
        property int  cellValue:          0
        property bool isClue:             false
        property bool isSelected:         false
        property bool isHighlighted:      false
        property bool sameValueHighlight: false
        property bool isWrong:            false
        property int  notesMask:          0
        property var  charColors:         []
        property var  charShort:          []
        property var  charFileNames:      []

        signal cellTapped()

        scale: 1.0
        Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }

        Rectangle {
            anchors.fill: parent; anchors.margins: 0.5
            color: cell.isSelected         ? "#2A0000"
                 : cell.sameValueHighlight ? "#1A1A00"
                 : cell.isHighlighted      ? "#141414"
                 : "#0A0A0A"
            border.color: cell.isSelected ? "#CC0000" : "transparent"
            border.width: cell.isSelected ? 2 : 0
            Behavior on color { ColorAnimation { duration: 100 } }

            // Filled value
            Rectangle {
                anchors.fill: parent
                radius: 0
                color: cell.cellValue > 0
                       ? (cell.isWrong ? "#440000" : "#111111")
                       : "transparent"
                opacity: cell.isClue ? 1.0 : 0.85
                visible: cell.cellValue > 0
                clip: true

                // Character photo
                Image {
                    id: cellImg
                    anchors.fill: parent
                    source: cell.cellValue > 0
                            ? "qrc:/qt/qml/AlinaRE/resources/characters/"
                              + (cell.charFileNames[cell.cellValue] ?? "") + ".png"
                            : ""
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    visible: status === Image.Ready
                    opacity: cell.isWrong ? 0.35 : 1.0
                }

                Text {
                    anchors.centerIn: parent
                    text: cell.cellValue > 0 ? (cell.charShort[cell.cellValue] ?? "") : ""
                    font.pixelSize: Math.max(8, parent.width * 0.28)
                    font.bold: true
                    color: cell.isWrong ? "#FF4444" : "#FFFFFF"
                    visible: cellImg.status !== Image.Ready
                }

                Rectangle {
                    anchors { top: parent.top; right: parent.right; margins: 2 }
                    width: 4; height: 4; radius: 2
                    color: "#FFFFFF"; opacity: 0.45
                    visible: cell.isClue
                }
            }

            Grid {
                anchors.fill: parent; anchors.margins: 1
                rows: 3; columns: 3
                visible: cell.cellValue === 0 && cell.notesMask !== 0

                Repeater {
                    model: 9
                    Item {
                        width:  cell.width  / 3 - 0.67
                        height: cell.height / 3 - 0.67
                        Text {
                            anchors.centerIn: parent
                            text: (cell.notesMask >> index) & 1 ? (cell.charShort[index + 1] ?? "") : ""
                            font.pixelSize: Math.max(5, cell.width * 0.13)
                            color: cell.charColors[index + 1] ?? "#888888"
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onPressed:  cell.scale = 0.88
                onReleased: cell.scale = 1.0
                onClicked:  cell.cellTapped()
            }
        }
    }
}
