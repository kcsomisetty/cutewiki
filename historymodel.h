//cutewiki is wikipedia reader for symbian and meego platforms
//Copyright (C) 2010 Krishna Somisetty

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.

//cutewiki is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef HISTORYMODEL_H
#define HISTORYMODEL_H

#include <QtCore>
#include <QAbstractItemModel>

#include "config.h"

class HistoryModel: public QAbstractListModel {
    Q_OBJECT

    Q_PROPERTY(  bool p_historytracking
                 READ historytracking
                 WRITE sethistorytracking
                 NOTIFY historytrackingChanged)

public:
    HistoryModel(QObject* parent = NULL);
    ~HistoryModel();

    virtual int rowCount(const QModelIndex& index ) const;
    virtual QVariant data(const QModelIndex& index, int role ) const;

    void readfromfile(QDataStream&);
    void writetofile(QDataStream&);

    bool historytracking() {
     return m_historytracking;
    }
    QString urlforindex(int index);
    void sethistorytracking(bool setting);

    Q_INVOKABLE void clearall();
    Q_INVOKABLE void addentry(const QString&);

signals:
    void historytrackingChanged();

private:

public slots:

private slots:

private:
    QStringList m_history;
    QStringList m_historyurls;
    bool m_historytracking;
};

#endif // HISTORYMODEL_H
