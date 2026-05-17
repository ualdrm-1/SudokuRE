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

    // ── Character data ────────────────────────────────────────────────────────
    // To replace placeholder icons with real images:
    //   1. Put 9 PNG files (square, ideally 200×200) into resources/characters/
    //      Named: leon.png, claire.png, jill.png, chris.png, ada.png,
    //             wesker.png, nemesis.png, tyrant.png, ethan.png
    //   2. Add them to CMakeLists.txt RESOURCES section in qt_add_qml_module
    //   3. In the character button Rectangle below, replace the Column+Text with:
    //        Image {
    //            anchors.fill: parent; fillMode: Image.PreserveAspectCrop
    //            source: "qrc:/AlinaRE/characters/" + charFileNames[index] + ".png"
    //            layer.enabled: true
    //            layer.effect: OpacityMask { maskSource: Rectangle { radius: width/2; width: parent.width; height: parent.height } }
    //        }
    readonly property var charNames:  ["", "LEON", "CLAIRE", "JILL", "CHRIS", "ADA", "WESKER", "NEMESIS", "TYRANT", "ETHAN"]
    readonly property var charShort:  ["", "LE", "CL", "JI", "CH", "AD", "WE", "NE", "TY", "ET"]
    readonly property var charFileNames: ["", "leon", "claire", "jill", "chris", "ada", "wesker", "nemesis", "tyrant", "ethan"]
    readonly property var charColors: [
        "transparent",
        "#1565C0", "#AD1457", "#2E7D32", "#0277BD",
        "#B71C1C", "#4A148C", "#4E342E", "#37474F", "#E65100"
    ]

    // ── Helpers ───────────────────────────────────────────────────────────────
    function formatTime(s) {
        let m = Math.floor(s / 60)
        let sec = s % 60
        return (m < 10 ? "0" + m : m) + ":" + (sec < 10 ? "0" + sec : sec)
    }

    function isSameGroup(cellA, cellB) {
        if (cellA < 0 || cellB < 0) return false
        let rA = Math.floor(cellA / 9), cA = cellA % 9
        let rB = Math.floor(cellB / 9), cB = cellB % 9
        return rA === rB || cA === cB ||
               (Math.floor(rA / 3) === Math.floor(rB / 3) && Math.floor(cA / 3) === Math.floor(cB / 3))
    }

    // ── Sound effects ─────────────────────────────────────────────────────────
    // Add .wav/.mp3 files to resources/audio/ and uncomment source lines.
    // Supported formats depend on platform codecs (wav is safest).
    SoundEffect {
        id: sfxPlace
        // source: "qrc:/AlinaRE/audio/place.wav"
        volume: 0.7
    }
    SoundEffect {
        id: sfxError
        // source: "qrc:/AlinaRE/audio/error.wav"
        volume: 0.8
    }
    SoundEffect {
        id: sfxHint
        // source: "qrc:/AlinaRE/audio/hint.wav"
        volume: 0.6
    }
    SoundEffect {
        id: sfxUndo
        // source: "qrc:/AlinaRE/audio/undo.wav"
        volume: 0.5
    }
    SoundEffect {
        id: sfxWin
        // source: "qrc:/AlinaRE/audio/win.wav"
        volume: 1.0
    }
    SoundEffect {
        id: sfxLose
        // source: "qrc:/AlinaRE/audio/lose.wav"
        volume: 1.0
    }
    SoundEffect {
        id: sfxSelect
        // source: "qrc:/AlinaRE/audio/select.wav"
        volume: 0.35
    }

    // ── Sound + animation triggers ────────────────────────────────────────────
    Connections {
        target: game
        function onPlaced(correct) {
            if (correct) sfxPlace.play()
            else {
                sfxError.play()
                mistakesShake.restart()
            }
        }
        function onGameWonChanged()  { if (game.gameWon)  sfxWin.play() }
        function onGameLostChanged() { if (game.gameLost) sfxLose.play() }
        function onHintsLeftChanged() { sfxHint.play() }
    }

    // Shake animation for mistakes counter
    SequentialAnimation {
        id: mistakesShake
        loops: 1
        NumberAnimation { target: mistakesRow; property: "x"; to: 6;  duration: 50 }
        NumberAnimation { target: mistakesRow; property: "x"; to: -6; duration: 50 }
        NumberAnimation { target: mistakesRow; property: "x"; to: 4;  duration: 40 }
        NumberAnimation { target: mistakesRow; property: "x"; to: -4; duration: 40 }
        NumberAnimation { target: mistakesRow; property: "x"; to: 0;  duration: 40 }
    }

    // ── Background ────────────────────────────────────────────────────────────
    Rectangle { anchors.fill: parent; color: "#0A0A0A" }

    // ── Root layout ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.bottomMargin: 22  // room for signature
        spacing: 8

        // ── Top bar ───────────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            Rectangle {
                id: backBtn
                anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                width: 36; height: 36; radius: 18
                color: backMa.pressed ? "#CC0000" : "#1A1A1A"
                scale: backMa.pressed ? 0.9 : 1.0

                Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: 22; color: "#FFFFFF" }

                MouseArea {
                    id: backMa
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.goBack()
                }
                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }
            }

            // Score with pulse on change
            Text {
                id: scoreText
                anchors.centerIn: parent
                text: game.score
                font.pixelSize: 20
                font.bold: true
                color: "#FFFFFF"

                onTextChanged: scorePulse.restart()

                SequentialAnimation {
                    id: scorePulse
                    NumberAnimation { target: scoreText; property: "scale"; to: 1.25; duration: 120; easing.type: Easing.OutQuad }
                    NumberAnimation { target: scoreText; property: "scale"; to: 1.0;  duration: 180; easing.type: Easing.InOutQuad }
                }
            }

            Text {
                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                text: "SRE"
                font.pixelSize: 16; font.bold: true; font.letterSpacing: 3
                color: "#CC0000"
            }
        }

        // ── Stats row ─────────────────────────────────────────────────────────
        Item {
            id: mistakesRow
            Layout.fillWidth: true
            height: statsRowContent.implicitHeight

            Row {
                id: statsRowContent
                anchors { left: parent.left; right: parent.right; leftMargin: 12; rightMargin: 12 }

                Repeater {
                    model: [
                        { label: "ALL TIME",   value: leaderboard.allTimeHigh },
                        { label: "DIFFICULTY", value: game.difficultyName() },
                        { label: "MISTAKES",   value: game.mistakes + "/3" },
                        { label: "TIME",       value: root.formatTime(game.elapsedSeconds) }
                    ]
                    delegate: Column {
                        width: root.width / 4
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label
                            font.pixelSize: 9; font.letterSpacing: 2
                            color: "#555555"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.value
                            font.pixelSize: 14; font.bold: true
                            color: index === 2 && game.mistakes > 0 ? "#CC0000" : "#FFFFFF"

                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#1E1E1E" }

        // ── Sudoku grid ───────────────────────────────────────────────────────
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: width

            property real cellSize: width / 9

            Grid {
                id: sudokuGrid
                anchors.fill: parent
                rows: 9; columns: 9

                Repeater {
                    id: cellRepeater
                    model: 81

                    delegate: SudokuCell {
                        width:  sudokuGrid.parent.cellSize
                        height: sudokuGrid.parent.cellSize
                        cellIndex:          index
                        cellValue:          game.board[index]   ?? 0
                        isClue:             (game.puzzle[index] ?? 0) !== 0
                        isSelected:         game.selectedCell === index
                        isHighlighted:      root.isSameGroup(game.selectedCell, index)
                        sameValueHighlight: game.selectedCell >= 0
                                            && (game.board[index] ?? 0) !== 0
                                            && (game.board[index] ?? 0) === (game.board[game.selectedCell] ?? 0)
                        isWrong:    !isClue && cellValue !== 0 && cellValue !== (game.solution[index] ?? 0)
                        notesMask:  game.notes[index] ?? 0
                        charColors: root.charColors
                        charShort:  root.charShort
                        onCellTapped: {
                            sfxSelect.play()
                            game.selectedCell = index
                        }
                    }
                }
            }

            // 3×3 box borders
            Repeater {
                model: 4
                Rectangle {
                    x: index * (sudokuGrid.parent.cellSize * 3)
                    y: 0; width: 2; height: sudokuGrid.parent.height
                    color: "#444444"; visible: index > 0
                }
            }
            Repeater {
                model: 4
                Rectangle {
                    x: 0; y: index * (sudokuGrid.parent.cellSize * 3)
                    width: sudokuGrid.parent.width; height: 2
                    color: "#444444"; visible: index > 0
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#1E1E1E" }

        // ── Action buttons ─────────────────────────────────────────────────────
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            Repeater {
                model: [
                    { icon: "↩", label: "Undo",  action: function() { sfxUndo.play(); game.undo() } },
                    { icon: "⌫", label: "Erase", action: function() { game.erase() } },
                    { icon: "✏", label: "Notes", action: function() { game.notesMode = !game.notesMode } },
                    { icon: "💡", label: "Hint",  action: function() { game.hint() } }
                ]
                delegate: Item {
                    id: actionItem
                    width: root.width / 4
                    height: 60

                    scale: actionMa.pressed ? 0.88 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.icon
                            font.pixelSize: 22
                            color: (index === 2 && game.notesMode)  ? "#CC0000"
                                 : (index === 3 && game.hintsLeft === 0) ? "#333333"
                                 : "#CCCCCC"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: index === 3
                                  ? modelData.label + " (" + game.hintsLeft + ")"
                                  : modelData.label
                            font.pixelSize: 10
                            color: "#555555"
                        }
                    }

                    MouseArea {
                        id: actionMa
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.action()
                    }
                }
            }
        }

        // ── Character selector — ROUND icons ──────────────────────────────────
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            Repeater {
                model: 9
                delegate: Item {
                    id: charItem
                    width: root.width / 9
                    height: width  // square container → circle

                    scale: charMa.pressed ? 0.82 : 1.0
                    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }

                    // Count of this character already placed on board
                    property int usedCount: {
                        let cnt = 0
                        for (let i = 0; i < 81; i++)
                            if ((game.board[i] ?? 0) === index + 1) cnt++
                        return cnt
                    }
                    property bool exhausted: usedCount >= 9

                    // ── ROUND icon ────────────────────────────────────────────
                    // Currently a coloured circle with initials.
                    // To use a real image: replace the Column{} block below with
                    //   Image { source: "qrc:/AlinaRE/characters/<name>.png"
                    //           anchors.fill: parent; fillMode: Image.PreserveAspectCrop }
                    // The Rectangle with radius: width/2 already clips it to a circle.
                    Rectangle {
                        id: charCircle
                        anchors.centerIn: parent
                        width: parent.width - 8
                        height: width
                        radius: width / 2   // ← perfect circle
                        color: charItem.exhausted
                               ? "#1A1A1A"
                               : root.charColors[index + 1]
                        opacity: charItem.exhausted ? 0.4
                               : charMa.containsMouse ? 1.0 : 0.88
                        clip: true

                        Behavior on opacity { NumberAnimation { duration: 120 } }
                        Behavior on color   { ColorAnimation  { duration: 200 } }

                        // Initials + remaining count
                        Column {
                            anchors.centerIn: parent
                            spacing: 0

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.charShort[index + 1]
                                font.pixelSize: Math.max(8, charCircle.width * 0.28)
                                font.bold: true
                                color: "#FFFFFF"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: 9 - charItem.usedCount
                                font.pixelSize: Math.max(6, charCircle.width * 0.18)
                                color: "#FFFFFF"
                                opacity: 0.65
                            }
                        }

                        // Thin border ring
                        Rectangle {
                            anchors.fill: parent
                            radius: width / 2
                            color: "transparent"
                            border.color: "#FFFFFF"
                            border.width: 1
                            opacity: 0.15
                        }
                    }

                    MouseArea {
                        id: charMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: !charItem.exhausted
                        onClicked: game.placeCharacter(index + 1)
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }

    // ── Win / Lose overlay ────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#CC000000"
        visible: game.gameWon || game.gameLost
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 350 } }

        Column {
            anchors.centerIn: parent
            spacing: 24

            // Title with scale-in entrance
            Text {
                id: overlayTitle
                anchors.horizontalCenter: parent.horizontalCenter
                text: game.gameWon ? "MISSION\nCOMPLETE" : "GAME\nOVER"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 42; font.bold: true; font.letterSpacing: 6
                color: game.gameWon ? "#FFFFFF" : "#CC0000"
                scale: (game.gameWon || game.gameLost) ? 1.0 : 0.6
                Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: game.gameWon
                      ? "Score: " + game.score + "\n" + root.formatTime(game.elapsedSeconds)
                      : "3 mistakes · Game over"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 16
                color: "#AAAAAA"
                opacity: game.gameWon || game.gameLost ? 1 : 0
                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation  { duration: 200 }
                        NumberAnimation { duration: 300 }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16

                Rectangle {
                    width: 140; height: 44; radius: 22
                    color: "#CC0000"
                    scale: playAgainMa.pressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }

                    Text {
                        anchors.centerIn: parent
                        text: "PLAY AGAIN"
                        font.pixelSize: 13; font.bold: true; font.letterSpacing: 2
                        color: "#FFFFFF"
                    }
                    MouseArea {
                        id: playAgainMa
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (game.gameWon)
                                leaderboard.addEntry(game.score, game.elapsedSeconds, game.difficulty)
                            game.newGame(game.difficulty)
                        }
                    }
                }

                Rectangle {
                    width: 100; height: 44; radius: 22
                    color: "#1A1A1A"; border.color: "#333333"
                    scale: menuMa.pressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }

                    Text {
                        anchors.centerIn: parent
                        text: "MENU"
                        font.pixelSize: 13; font.bold: true; font.letterSpacing: 2
                        color: "#FFFFFF"
                    }
                    MouseArea {
                        id: menuMa
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (game.gameWon)
                                leaderboard.addEntry(game.score, game.elapsedSeconds, game.difficulty)
                            root.goBack()
                        }
                    }
                }
            }
        }
    }

    // ── SudokuCell component ──────────────────────────────────────────────────
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

        signal cellTapped()

        // Tap scale bounce
        scale: 1.0
        Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutBack } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 0.5
            color: cell.isSelected          ? "#2A0000"
                 : cell.sameValueHighlight  ? "#1A1A00"
                 : cell.isHighlighted       ? "#141414"
                 : "#0A0A0A"
            border.color: cell.isSelected ? "#CC0000" : "#1E1E1E"
            border.width: cell.isSelected ? 1.5 : 0.5

            Behavior on color { ColorAnimation { duration: 100 } }

            // Filled value
            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 6; height: parent.height - 6
                radius: 4
                color: cell.cellValue > 0
                       ? (cell.isWrong ? "#3A0000" : cell.charColors[cell.cellValue] ?? "transparent")
                       : "transparent"
                opacity: cell.isClue ? 1.0 : 0.85
                visible: cell.cellValue > 0

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: cell.cellValue > 0 ? (cell.charShort[cell.cellValue] ?? "") : ""
                    font.pixelSize: Math.max(8, parent.width * 0.3)
                    font.bold: true
                    color: cell.isWrong ? "#FF4444" : "#FFFFFF"
                }

                // Dot marker for given clues
                Rectangle {
                    anchors { top: parent.top; right: parent.right; margins: 2 }
                    width: 4; height: 4; radius: 2
                    color: "#FFFFFF"; opacity: 0.45
                    visible: cell.isClue
                }
            }

            // Notes 3×3 grid
            Grid {
                anchors.fill: parent
                anchors.margins: 1
                rows: 3; columns: 3
                visible: cell.cellValue === 0 && cell.notesMask !== 0

                Repeater {
                    model: 9
                    delegate: Item {
                        width: cell.width  / 3 - 0.67
                        height: cell.height / 3 - 0.67
                        Text {
                            anchors.centerIn: parent
                            text: (cell.notesMask >> index) & 1
                                  ? (cell.charShort[index + 1] ?? "") : ""
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
