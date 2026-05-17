#include "SudokuGenerator.h"
#include <algorithm>
#include <numeric>

SudokuGenerator::SudokuGenerator()
    : m_rng(std::random_device{}())
{
}

bool SudokuGenerator::isValid(const Board &board, int row, int col, int val)
{
    for (int i = 0; i < 9; ++i) {
        if (board[row][i] == val) return false;
        if (board[i][col] == val) return false;
    }
    int boxRow = (row / 3) * 3;
    int boxCol = (col / 3) * 3;
    for (int r = boxRow; r < boxRow + 3; ++r)
        for (int c = boxCol; c < boxCol + 3; ++c)
            if (board[r][c] == val) return false;
    return true;
}

bool SudokuGenerator::fillCell(Board &board, int pos)
{
    if (pos == 81) return true;
    int row = pos / 9, col = pos % 9;

    std::array<int, 9> vals;
    std::iota(vals.begin(), vals.end(), 1);
    std::shuffle(vals.begin(), vals.end(), m_rng);

    for (int v : vals) {
        if (isValid(board, row, col, v)) {
            board[row][col] = v;
            if (fillCell(board, pos + 1)) return true;
            board[row][col] = 0;
        }
    }
    return false;
}

bool SudokuGenerator::solve(Board &board)
{
    for (int pos = 0; pos < 81; ++pos) {
        int row = pos / 9, col = pos % 9;
        if (board[row][col] != 0) continue;
        for (int v = 1; v <= 9; ++v) {
            if (isValid(board, row, col, v)) {
                board[row][col] = v;
                if (solve(board)) return true;
                board[row][col] = 0;
            }
        }
        return false;
    }
    return true;
}

int SudokuGenerator::countSolutions(Board board, int limit)
{
    for (int pos = 0; pos < 81; ++pos) {
        int row = pos / 9, col = pos % 9;
        if (board[row][col] != 0) continue;
        int count = 0;
        for (int v = 1; v <= 9; ++v) {
            if (isValid(board, row, col, v)) {
                board[row][col] = v;
                count += countSolutions(board, limit - count);
                if (count >= limit) return count;
                board[row][col] = 0;
            }
        }
        return count;
    }
    return 1;
}

void SudokuGenerator::removeClues(Board &board, int targetClues)
{
    // Build a shuffled list of all 81 positions
    std::array<int, 81> positions;
    std::iota(positions.begin(), positions.end(), 0);
    std::shuffle(positions.begin(), positions.end(), m_rng);

    int clues = 81;
    for (int pos : positions) {
        if (clues <= targetClues) break;
        int row = pos / 9, col = pos % 9;
        int saved = board[row][col];
        board[row][col] = 0;
        if (countSolutions(board, 2) == 1) {
            --clues;
        } else {
            board[row][col] = saved;
        }
    }
}

Board SudokuGenerator::generate(int difficulty)
{
    // Generate full solution
    Board full{};
    fillCell(full, 0);
    m_solution = full;

    // Target clue counts per difficulty
    int targetClues;
    switch (difficulty) {
    case 0: targetClues = 40; break; // easy
    case 1: targetClues = 30; break; // medium
    default: targetClues = 22; break; // hard
    }

    Board puzzle = full;
    removeClues(puzzle, targetClues);
    return puzzle;
}
