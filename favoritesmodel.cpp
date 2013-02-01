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

#include "favoritesmodel.h"

FavModel::FavModel(QObject* parent) : QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles;
    roles[0] = "title";
    roles[1] = "fmurl";
    setRoleNames(roles);
    roles.clear();
}

FavModel::~FavModel()
{
    m_favlist.clear();
    m_favlisturls.clear();
}

int FavModel::rowCount(const QModelIndex& index ) const
{
    return m_favlist.count();
}

QVariant FavModel::data(const QModelIndex& index, int role ) const
{
    if (!index.isValid())
        return QVariant();

    if (role == 0)
        {
        return QVariant(m_favlist[index.row()]);
        }
    else if (role == 1)
        {
        return QVariant(m_favlisturls[index.row()]);
        }
    else
        {
        return QVariant();
        }
}

void FavModel::readfromfile(QDataStream& stream)
{
    stream >> m_favlist;
    stream >> m_favlisturls;
}

void FavModel::writetofile(QDataStream& stream)
{
    stream << m_favlist;
    stream << m_favlisturls;
}

void FavModel::addfavpage(const QString& url)
{
    LS("FavModel::addfavpage >>");
    if(url.isEmpty())
        return;

    Q_ASSERT(m_favlisturls.count() == m_favlist.count());
    LS("Assert condition passed");

    QString newstr2;

    if(url.indexOf("wikipedia.org") == -1)
        {
        newstr2 = url;
        }
    else
        {
        QString str = url;
        QString newstr = str.remove(0, 10); //remove "http://xx."
        //what if the prefix is of 3 letters.
        newstr = newstr.remove("m.wikipedia.org/wiki/", Qt::CaseInsensitive);
        if(newstr.isEmpty())
            return;

        newstr2 = newstr.replace("_", " ");
        //also convert it back
        }

    //avoid dupes
    int i=0;
    while(i < m_favlist.count())
    {
        //LS("1: "+m_favlist.at(i));
        //LS("2: "+newstr2);
        if(QString::compare(m_favlist.at(i), newstr2) == 0)
            {
            m_favlist.removeAt(i);
            m_favlisturls.removeAt(i);
            }
        else
            i++;
    }

    emit beginResetModel();
    m_favlist.insert(0, newstr2);
    m_favlisturls.insert(0, url);
    emit endResetModel();
    LS("FavModel::addfavpage <<");
}

void FavModel::removeentry(int index)
{
    LS("FavModel::removeentry >>");
    if(index < 0 || index >= m_favlist.count())
        return;

    Q_ASSERT(m_favlisturls.count() == m_favlist.count());

    emit beginResetModel();
    m_favlist.removeAt(index);
    m_favlisturls.removeAt(index);
    emit endResetModel();

    LS("FavModel::removeentry <<");
}

void FavModel::removefavpage(const QString&)
{

}

bool FavModel::isfavornot(QString url)
{
    LS("FavModel::isfavornot >>");

    //url should be a fully qualified url
    if(m_favlisturls.indexOf(url) != -1)
        return true;
    else
        return false;

    LS("FavModel::isfavornot <<");
}
