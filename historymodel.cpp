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

#include "historymodel.h"

HistoryModel::HistoryModel(QObject* parent):
    QAbstractListModel(parent),
    m_historytracking(true)
{
    QHash<int, QByteArray> roles;
    roles[0] = "title";
    roles[1] = "hmurl";
    setRoleNames(roles);
    roles.clear();
}

HistoryModel::~HistoryModel()
{
    m_history.clear();
    m_historyurls.clear();
}

int HistoryModel::rowCount(const QModelIndex& /*index*/ ) const
{
    //LS("HitoryModel::rowCount "+QString::number(m_history.count()));
    return m_history.count();
}

QVariant HistoryModel::data(const QModelIndex& index, int role ) const
{
    if (!index.isValid())
        return QVariant();

    if (role == 0)
        {
        //LS(m_history[index.row()]);
        return QVariant(m_history[index.row()]);
        }
    else if (role == 1)
        {
        return QVariant(m_historyurls[index.row()]);
        }
    else
        {return QVariant();}
}

void HistoryModel::clearall()
{
    LS("HistoryModel::clearall >>");
    if(m_history.count()) {
        emit beginResetModel();
        m_history.clear();
        m_historyurls.clear();
        emit endResetModel();
    }
    LS("HistoryModel::clearall <<");
}

void HistoryModel::addentry(const QString& url)
{
    //parse the url and add only if it is of wikipedia origin.
    //if wikipedia origin try to get the title
    LS("HistoryModel::addentry >>");
    if(!m_historytracking)
        return; //not following

    if(url.isEmpty())
        return;

    Q_ASSERT(m_historyurls.count() == m_history.count());
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
    while(i < m_history.count())
    {
        //LS("1: "+m_history.at(i));
        //LS("2: "+newstr2);
        if(QString::compare(m_history.at(i), newstr2) == 0)
            {
            m_history.removeAt(i);
            m_historyurls.removeAt(i);
            }
        else
            i++;
    }

    //LS(newstr2);

    emit beginResetModel();
    m_history.insert(0, newstr2);
    m_historyurls.insert(0, url);
    emit endResetModel();
    LS("HistoryModel::addentry <<");
}


void HistoryModel::readfromfile(QDataStream& stream)
    {
    LS("HistoryModel::readfromfile >>");
    stream >> m_historytracking;
    stream >> m_history;
    stream >> m_historyurls;
    LS("HistoryModel::readfromfile <<");
    }


void HistoryModel::writetofile(QDataStream& stream)
    {
    //only top 30 will make it to file.
    LS("HistoryModel::writetofile >>");
    //LS(m_history);
    stream << m_historytracking;

    if(m_history.count() > 40)
        {
        QStringList list = m_history.mid(0, 40);
        stream << list;
        list.clear();

        list = m_historyurls.mid(0, 40);
        stream << list;
        list.clear();
        }
    else
        {
        stream << m_history;
        stream << m_historyurls;
        }

    LS("HistoryModel::writetofile <<");
    }

void HistoryModel::sethistorytracking(bool setting)
{
    //clear the history
    //set the state variable
    //thats it.
    m_historytracking = setting;

    if (setting == false) {
        clearall();
        }

    emit historytrackingChanged();
}

QString HistoryModel::urlforindex(int index)
{
    if(index < 0 || index >= m_historyurls.count())
        return QString();

    return m_historyurls[index];
}
