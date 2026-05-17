import QtQuick
import QtQuick.Controls
import QtMultimedia
import AlinaRE

Window {
    id: window
    width: 960
    height: 680
    minimumWidth: 800
    minimumHeight: 560
    visible: true
    title: "SRE – Sudoku Resident Evil"
    color: "#0A0A0A"

    GameModel {
        id: gameModel
    }

    LeaderboardModel {
        id: leaderboardModel
    }

    // ── Background music ─────────────────────────────────────────────────────
    // Drop your ambient loop into resources/audio/ambient.mp3
    // and uncomment the source line + bgMusic.play() below.
    MediaPlayer {
        id: bgMusic
        // source: "qrc:/AlinaRE/audio/ambient.mp3"
        loops: MediaPlayer.Infinite
        audioOutput: AudioOutput { volume: 0.22 }  // property binding, not child
    }
    // Component.onCompleted: bgMusic.play()

    // ── Navigation ───────────────────────────────────────────────────────────
    StackView {
        id: stack
        anchors.fill: parent
        initialItem: loadingComponent

        // Slide + fade for push (forward navigation)
        pushEnter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: 60; to: 0; duration: 300; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 280 }
            }
        }
        pushExit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: 0; to: -60; duration: 300; easing.type: Easing.InCubic }
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 280 }
            }
        }
        // Reverse slide for pop (back navigation)
        popEnter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: -60; to: 0; duration: 300; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 280 }
            }
        }
        popExit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: 0; to: 60; duration: 300; easing.type: Easing.InCubic }
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 280 }
            }
        }
        // Crossfade for loading → menu replace
        replaceEnter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 280; easing.type: Easing.InOutQuad }
        }
        replaceExit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 }
        }
    }

    // ── Signature ─────────────────────────────────────────────────────────────
    Text {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 5 }
        z: 1000
        text: "special for alinalaptop777"
        font.pixelSize: 14
        font.letterSpacing: 1
        color: "#CC0000"
        opacity: 0.5
    }

    // ── Screen components ─────────────────────────────────────────────────────
    Component {
        id: loadingComponent
        LoadingScreen {
            onLoadingFinished: Qt.callLater(function() { stack.replace(menuComponent) })
        }
    }

    Component {
        id: menuComponent
        MainMenu {
            onStartGame: function(difficulty) {
                gameModel.newGame(difficulty)
                stack.push(gameComponent)
            }
            onShowLeaderboard: stack.push(leaderboardComponent)
        }
    }

    Component {
        id: gameComponent
        GameScreen {
            game: gameModel
            leaderboard: leaderboardModel
            onGoBack: stack.pop()
        }
    }

    Component {
        id: leaderboardComponent
        LeaderboardScreen {
            leaderboard: leaderboardModel
            onGoBack: stack.pop()
        }
    }
}
