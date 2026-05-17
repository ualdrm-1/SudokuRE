#pragma once

#include <array>
#include <random>

using Board = std::array<std::array<int, 9>, 9>;

class SudokuGenerator {
public:
    SudokuGenerator();

    // difficulty: 0=easy, 1=medium, 2=hard
    Board generate(int difficulty);
    Board solution() const { return m_solution; }

    static bool solve(Board &board);
    static bool isValid(const Board &board, int row, int col, int val);

private:
    Board m_solution;
    std::mt19937 m_rng;

    bool fillCell(Board &board, int pos);
    void removeClues(Board &board, int targetClues);
    static int countSolutions(Board board, int limit);
};
