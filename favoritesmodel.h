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

#ifndef FAVORITESMODEL_H
#define FAVORITESMODEL_H

#include <QtCore>
#include <QAbstractItemModel>

#include "config.h"

class FavModel : public QAbstractListModel {
    Q_OBJECT

public:
    FavModel(QObject* parent = NULL);
    ~FavModel();

    virtual int rowCount(const QModelIndex& index ) const;
    virtual QVariant data(const QModelIndex& index, int role ) const;

    void readfromfile(QDataStream&);
    void writetofile(QDataStream&);
    bool isfavornot(QString url);

    //Q_INVOKABLE void clearall();
    Q_INVOKABLE void addfavpage(const QString&);
    Q_INVOKABLE void removeentry(int index);
    Q_INVOKABLE void removefavpage(const QString&);

signals:

private:

public slots:

private slots:

private:
    QStringList m_favlist;
    QStringList m_favlisturls;
};

#endif // FAVORITESMODEL_H
