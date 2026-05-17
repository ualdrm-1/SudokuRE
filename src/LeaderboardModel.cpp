#include "LeaderboardModel.h"
#include <QSettings>
#include <QDateTime>
#include <algorithm>

static const char *kGroup = "leaderboard";
static const int kMaxEntries = 50;

LeaderboardModel::LeaderboardModel(QObject *parent)
    : QAbstractListModel(parent)
{
    load();
}

int LeaderboardModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_entries.size();
}

QVariant LeaderboardModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size()) return {};
    const auto &e = m_entries[index.row()];
    switch (role) {
    case ScoreRole:       return e.score;
    case SecondsRole:     return e.seconds;
    case DifficultyRole:  return e.difficulty;
    case DateRole:        return e.date;
    case DifficultyNameRole:
        switch (e.difficulty) {
        case 0: return QStringLiteral("Easy");
        case 1: return QStringLiteral("Medium");
        default: return QStringLiteral("Hard");
        }
    }
    return {};
}

QHash<int, QByteArray> LeaderboardModel::roleNames() const
{
    return {
        {ScoreRole,          "score"},
        {SecondsRole,        "seconds"},
        {DifficultyRole,     "difficulty"},
        {DateRole,           "date"},
        {DifficultyNameRole, "difficultyName"},
    };
}

int LeaderboardModel::allTimeHigh() const
{
    if (m_entries.isEmpty()) return 0;
    return m_entries.first().score;
}

int LeaderboardModel::bestScoreForDifficulty(int difficulty) const
{
    for (const auto &e : m_entries)
        if (e.difficulty == difficulty) return e.score;
    return 0;
}

void LeaderboardModel::addEntry(int score, int seconds, int difficulty)
{
    LeaderboardEntry entry{score, seconds, difficulty,
                           QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd"))};

    beginInsertRows({}, 0, 0);
    m_entries.prepend(entry);
    endInsertRows();

    // Sort by score descending
    beginResetModel();
    std::sort(m_entries.begin(), m_entries.end(),
              [](const LeaderboardEntry &a, const LeaderboardEntry &b) {
                  return a.score > b.score;
              });
    if (m_entries.size() > kMaxEntries)
        m_entries.resize(kMaxEntries);
    endResetModel();

    save();
    emit allTimeHighChanged();
}

void LeaderboardModel::clear()
{
    beginResetModel();
    m_entries.clear();
    endResetModel();
    save();
    emit allTimeHighChanged();
}

void LeaderboardModel::load()
{
    QSettings s;
    s.beginGroup(kGroup);
    int count = s.beginReadArray(QStringLiteral("entries"));
    m_entries.reserve(count);
    for (int i = 0; i < count; ++i) {
        s.setArrayIndex(i);
        LeaderboardEntry e;
        e.score      = s.value(QStringLiteral("score")).toInt();
        e.seconds    = s.value(QStringLiteral("seconds")).toInt();
        e.difficulty = s.value(QStringLiteral("difficulty")).toInt();
        e.date       = s.value(QStringLiteral("date")).toString();
        m_entries.append(e);
    }
    s.endArray();
    s.endGroup();
}

void LeaderboardModel::save()
{
    QSettings s;
    s.beginGroup(kGroup);
    s.beginWriteArray(QStringLiteral("entries"), m_entries.size());
    for (int i = 0; i < m_entries.size(); ++i) {
        s.setArrayIndex(i);
        s.setValue(QStringLiteral("score"),      m_entries[i].score);
        s.setValue(QStringLiteral("seconds"),    m_entries[i].seconds);
        s.setValue(QStringLiteral("difficulty"), m_entries[i].difficulty);
        s.setValue(QStringLiteral("date"),       m_entries[i].date);
    }
    s.endArray();
    s.endGroup();
}
