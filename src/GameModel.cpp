#include "GameModel.h"
#include <algorithm>

GameModel::GameModel(QObject *parent)
    : QObject(parent)
{
    m_timer.setInterval(1000);
    connect(&m_timer, &QTimer::timeout, this, &GameModel::onTimerTick);
}

QList<int> GameModel::board() const
{
    QList<int> result;
    result.reserve(81);
    for (int r = 0; r < 9; ++r)
        for (int c = 0; c < 9; ++c)
            result.append(m_board[r][c]);
    return result;
}

QList<int> GameModel::puzzle() const
{
    QList<int> result;
    result.reserve(81);
    for (int r = 0; r < 9; ++r)
        for (int c = 0; c < 9; ++c)
            result.append(m_puzzle[r][c]);
    return result;
}

QList<int> GameModel::solution() const
{
    QList<int> result;
    result.reserve(81);
    for (int r = 0; r < 9; ++r)
        for (int c = 0; c < 9; ++c)
            result.append(m_solution[r][c]);
    return result;
}

QList<int> GameModel::notes() const
{
    QList<int> result;
    result.reserve(81);
    for (int i = 0; i < 81; ++i)
        result.append(m_notes[i]);
    return result;
}

bool GameModel::hasNote(int cellIndex, int charIndex) const
{
    if (cellIndex < 0 || cellIndex >= 81 || charIndex < 1 || charIndex > 9) return false;
    return (m_notes[cellIndex] >> (charIndex - 1)) & 1;
}

void GameModel::setSelectedCell(int index)
{
    if (m_selectedCell == index) return;
    m_selectedCell = index;
    emit selectedCellChanged();
}

void GameModel::setNotesMode(bool on)
{
    if (m_notesMode == on) return;
    m_notesMode = on;
    emit notesModeChanged();
}

void GameModel::newGame(int difficulty)
{
    m_timer.stop();
    m_difficulty = difficulty;
    m_mistakes = 0;
    m_score = 0;
    m_elapsedSeconds = 0;
    m_selectedCell = -1;
    m_notesMode = false;
    m_gameWon = false;
    m_gameLost = false;
    m_hintsLeft = 3;
    m_undoStack.clear();
    m_notes.fill(0);

    Board puzzle = m_generator.generate(difficulty);
    m_puzzle = puzzle;
    m_board = puzzle;
    m_solution = m_generator.solution();

    m_timer.start();

    emit boardChanged();
    emit puzzleChanged();
    emit solutionChanged();
    emit notesChanged();
    emit selectedCellChanged();
    emit scoreChanged();
    emit mistakesChanged();
    emit hintsLeftChanged();
    emit elapsedSecondsChanged();
    emit notesModeChanged();
    emit difficultyChanged();
    emit gameWonChanged();
    emit gameLostChanged();
    emit timerRunningChanged();
}

void GameModel::placeCharacter(int charIndex)
{
    if (m_selectedCell < 0 || m_gameWon || m_gameLost) return;
    if (charIndex < 1 || charIndex > 9) return;

    int row = m_selectedCell / 9;
    int col = m_selectedCell % 9;

    // Can't modify given clues
    if (m_puzzle[row][col] != 0) return;

    if (m_notesMode) {
        int bit = 1 << (charIndex - 1);
        int prev = m_notes[m_selectedCell];
        m_notes[m_selectedCell] ^= bit;
        m_undoStack.push_back({m_selectedCell, m_board[row][col], prev});
        emit notesChanged();
        return;
    }

    // Normal placement
    int prevVal = m_board[row][col];
    int prevNotes = m_notes[m_selectedCell];

    m_undoStack.push_back({m_selectedCell, prevVal, prevNotes});

    m_board[row][col] = charIndex;
    m_notes[m_selectedCell] = 0; // clear notes when value placed

    bool correct = (charIndex == m_solution[row][col]);
    if (!correct) {
        ++m_mistakes;
        emit mistakesChanged();
        if (m_mistakes >= 3) {
            m_gameLost = true;
            m_timer.stop();
            emit gameLostChanged();
            emit timerRunningChanged();
        }
    }

    emit boardChanged();
    emit notesChanged();
    emit placed(correct);
    checkWin();
}

void GameModel::erase()
{
    if (m_selectedCell < 0 || m_gameWon || m_gameLost) return;

    int row = m_selectedCell / 9;
    int col = m_selectedCell % 9;

    if (m_puzzle[row][col] != 0) return; // clue cell, can't erase

    int prevVal = m_board[row][col];
    int prevNotes = m_notes[m_selectedCell];

    if (prevVal == 0 && prevNotes == 0) return; // nothing to erase

    m_undoStack.push_back({m_selectedCell, prevVal, prevNotes});
    m_board[row][col] = 0;
    m_notes[m_selectedCell] = 0;

    emit boardChanged();
    emit notesChanged();
}

void GameModel::undo()
{
    if (m_undoStack.isEmpty() || m_gameWon || m_gameLost) return;

    UndoEntry entry = m_undoStack.takeLast();
    int row = entry.cellIndex / 9;
    int col = entry.cellIndex % 9;

    m_board[row][col] = entry.previousValue;
    m_notes[entry.cellIndex] = entry.previousNotes;

    emit boardChanged();
    emit notesChanged();
}

void GameModel::hint()
{
    if (m_hintsLeft <= 0 || m_gameWon || m_gameLost) return;

    // Find an empty cell to reveal
    QList<int> emptyCells;
    for (int i = 0; i < 81; ++i) {
        int r = i / 9, c = i % 9;
        if (m_board[r][c] == 0)
            emptyCells.append(i);
    }
    if (emptyCells.isEmpty()) return;

    // Prefer selected cell if it's empty
    int target = -1;
    if (m_selectedCell >= 0) {
        int r = m_selectedCell / 9, c = m_selectedCell % 9;
        if (m_board[r][c] == 0) target = m_selectedCell;
    }
    if (target < 0) target = emptyCells.first();

    int row = target / 9, col = target % 9;
    int prevVal = m_board[row][col];
    int prevNotes = m_notes[target];

    m_undoStack.push_back({target, prevVal, prevNotes});
    m_board[row][col] = m_solution[row][col];
    m_notes[target] = 0;

    --m_hintsLeft;
    emit hintsLeftChanged();
    emit boardChanged();
    emit notesChanged();
    checkWin();
}

void GameModel::checkWin()
{
    for (int r = 0; r < 9; ++r)
        for (int c = 0; c < 9; ++c)
            if (m_board[r][c] != m_solution[r][c]) return;

    m_gameWon = true;
    m_timer.stop();
    calculateScore();

    emit gameWonChanged();
    emit timerRunningChanged();
    emit scoreChanged();
}

void GameModel::calculateScore()
{
    int base = baseScore();
    int timeBonus = qMax(0, 600 - m_elapsedSeconds) * 2;
    int mistakePenalty = m_mistakes * 500;
    int hintPenalty = (3 - m_hintsLeft) * 300;
    m_score = qMax(0, base + timeBonus - mistakePenalty - hintPenalty);
    emit scoreChanged();
}

int GameModel::baseScore() const
{
    switch (m_difficulty) {
    case 0: return 1000;
    case 1: return 2000;
    default: return 4000;
    }
}

QString GameModel::difficultyName() const
{
    switch (m_difficulty) {
    case 0: return QStringLiteral("Easy");
    case 1: return QStringLiteral("Medium");
    default: return QStringLiteral("Hard");
    }
}

void GameModel::onTimerTick()
{
    ++m_elapsedSeconds;
    emit elapsedSecondsChanged();
}
