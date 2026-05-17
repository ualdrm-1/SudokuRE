#pragma once

#include <QAbstractListModel>
#include <QtQml/qqml.h>

struct LeaderboardEntry {
    int score;
    int seconds;
    int difficulty;
    QString date;
};

class LeaderboardModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int allTimeHigh READ allTimeHigh NOTIFY allTimeHighChanged)

public:
    enum Roles {
        ScoreRole = Qt::UserRole + 1,
        SecondsRole,
        DifficultyRole,
        DateRole,
        DifficultyNameRole
    };

    explicit LeaderboardModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int allTimeHigh() const;

    Q_INVOKABLE void addEntry(int score, int seconds, int difficulty);
    Q_INVOKABLE void clear();
    Q_INVOKABLE int bestScoreForDifficulty(int difficulty) const;

signals:
    void allTimeHighChanged();

private:
    QList<LeaderboardEntry> m_entries;

    void load();
    void save();
};
