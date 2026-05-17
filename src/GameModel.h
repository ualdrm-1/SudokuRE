#pragma once

#include <QObject>
#include <QList>
#include <QTimer>
#include <QVector>
#include <QtQml/qqml.h>
#include "SudokuGenerator.h"

class GameModel : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QList<int> board READ board NOTIFY boardChanged)
    Q_PROPERTY(QList<int> puzzle READ puzzle NOTIFY puzzleChanged)
    Q_PROPERTY(QList<int> solution READ solution NOTIFY solutionChanged)
    Q_PROPERTY(QList<int> notes READ notes NOTIFY notesChanged)
    Q_PROPERTY(int selectedCell READ selectedCell WRITE setSelectedCell NOTIFY selectedCellChanged)
    Q_PROPERTY(int score READ score NOTIFY scoreChanged)
    Q_PROPERTY(int mistakes READ mistakes NOTIFY mistakesChanged)
    Q_PROPERTY(int hintsLeft READ hintsLeft NOTIFY hintsLeftChanged)
    Q_PROPERTY(int elapsedSeconds READ elapsedSeconds NOTIFY elapsedSecondsChanged)
    Q_PROPERTY(bool notesMode READ notesMode WRITE setNotesMode NOTIFY notesModeChanged)
    Q_PROPERTY(int difficulty READ difficulty NOTIFY difficultyChanged)
    Q_PROPERTY(bool gameWon READ gameWon NOTIFY gameWonChanged)
    Q_PROPERTY(bool gameLost READ gameLost NOTIFY gameLostChanged)
    Q_PROPERTY(bool timerRunning READ timerRunning NOTIFY timerRunningChanged)

public:
    explicit GameModel(QObject *parent = nullptr);

    QList<int> board() const;
    QList<int> puzzle() const;
    QList<int> solution() const;
    QList<int> notes() const;  // flat 81*9 bools packed as ints (bitmask per cell)
    int selectedCell() const { return m_selectedCell; }
    int score() const { return m_score; }
    int mistakes() const { return m_mistakes; }
    int hintsLeft() const { return m_hintsLeft; }
    int elapsedSeconds() const { return m_elapsedSeconds; }
    bool notesMode() const { return m_notesMode; }
    int difficulty() const { return m_difficulty; }
    bool gameWon() const { return m_gameWon; }
    bool gameLost() const { return m_gameLost; }
    bool timerRunning() const { return m_timer.isActive(); }

    void setSelectedCell(int index);
    void setNotesMode(bool on);

    Q_INVOKABLE void newGame(int difficulty);
    Q_INVOKABLE void placeCharacter(int charIndex); // 1-9
    Q_INVOKABLE void erase();
    Q_INVOKABLE void undo();
    Q_INVOKABLE void hint();
    Q_INVOKABLE bool hasNote(int cellIndex, int charIndex) const; // charIndex 1-9
    Q_INVOKABLE QString difficultyName() const;

signals:
    void boardChanged();
    void puzzleChanged();
    void solutionChanged();
    void notesChanged();
    void selectedCellChanged();
    void scoreChanged();
    void mistakesChanged();
    void hintsLeftChanged();
    void elapsedSecondsChanged();
    void notesModeChanged();
    void difficultyChanged();
    void gameWonChanged();
    void gameLostChanged();
    void timerRunningChanged();
    void placed(bool correct);   // emitted after every non-notes placement

private slots:
    void onTimerTick();

private:
    struct UndoEntry {
        int cellIndex;
        int previousValue;
        int previousNotes;
    };

    Board m_board{};
    Board m_puzzle{};
    Board m_solution{};
    std::array<int, 81> m_notes{};  // bitmask per cell: bit (charIndex-1) set = note active

    int m_selectedCell = -1;
    int m_score = 0;
    int m_mistakes = 0;
    int m_hintsLeft = 3;
    int m_elapsedSeconds = 0;
    bool m_notesMode = false;
    int m_difficulty = 0;
    bool m_gameWon = false;
    bool m_gameLost = false;

    QTimer m_timer;
    QVector<UndoEntry> m_undoStack;
    SudokuGenerator m_generator;

    void checkWin();
    void calculateScore();
    int baseScore() const;
};
