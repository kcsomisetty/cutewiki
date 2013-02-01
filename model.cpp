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

#include <QDesktopServices>
#include <QUrl>

#include "model.h"

Model::Model(HistoryModel* hm, FavModel* fm):
        m_url(""),
        m_hm(hm),
        m_fm(fm),
        m_showkeyboard(true),
        m_loadimages(true),
        m_busy(false),
        m_resultsmap(new QVariantMap()),
        m_error(""),
        m_searchString(""),
        m_fontsize(FONTSIZE),
        m_language(0),
        m_urlprefix("http://en."),
        m_favurl(false)
{
    LS("Model::Model =>>");

    m_dbhandler = new SmartboxHandler(this);

    QHash<int, QByteArray> roles;
    roles[0] = "title";

    setRoleNames(roles);
    roles.clear();

    QString fi(CONFIGFILE);
    QFile file( fi.toLower() );

        if(file.exists() && file.open( QIODevice::ReadOnly ))
        {
        QDataStream stream( &file );
        int configfileversion = 0;
        stream >> configfileversion; //version of config file
        //and then fontsize to use
        stream >> m_fontsize;

        bool var;
        stream >> var;
        setshowkeyboard(var);
        stream >> var;
        setloadimages(var);
        int lang = 0;
        stream >> lang;
        setlanguage(lang);

        if(m_hm)
            m_hm->readfromfile(stream);

        if(m_fm)
            m_fm->readfromfile(stream);
        }

      file.close();
      //many more to come    

    m_wakeuptimer.setInterval(WAKEUPTIMER);
    connect(&m_wakeuptimer, SIGNAL(timeout()), this, SLOT(timeout()));
    connect(m_dbhandler, SIGNAL(operationcomplete(const QString&, QStringList, int)), this, SLOT(HandleSearchComplete(const QString&, QStringList, int)));
    connect(m_dbhandler, SIGNAL(pageloaded(const QString&)), this, SLOT(HandlePageLoaded(const QString&)));

    LS("Model::Model <<");
}

Model::~Model()
{
    LS("Model::~Model =>>");
    if(m_dbhandler)
        {
        delete m_dbhandler;
        m_dbhandler = 0;
        }

    m_searchresults.clear();

    if(m_resultsmap)
    {
        m_resultsmap->clear();
        delete m_resultsmap;
        m_resultsmap = 0;
    }

    LS("Model::~Model <<");
}

int Model::rowCount(const QModelIndex& index ) const
{
    return m_searchresults.count();
}

QVariant Model::data(const QModelIndex& index, int role ) const
{
    if (!index.isValid())
        return QVariant();

    if (role == 0)
        return QVariant(m_searchresults[index.row()]);
    else if (role == 2) {}
    else
        {return QVariant();}
}

int Model::setSearchString(const QString& a_searchString)
{
    LS("Model::setSearchString =>>");
    QString searchString = a_searchString.trimmed();

    m_searchString = searchString;
    LS("Search for:"<<searchString);

    //first see if we have any cached results.
    QMap<QString, QVariant>::const_iterator iter = m_resultsmap->find(searchString);
    if(iter != m_resultsmap->end())
        {
        //LS( "we have a cached entry:"+iter.key());
        const QVariant v = iter.value();
        //LS("Search results are:"+v.toStringList());
        HandleSearchComplete(iter.key(), v.toStringList(), 0, true);
        return 0;
        }

    if(searchString.isEmpty())
        {
        emit beginResetModel();
        m_searchresults.clear();
        setbusy(false);
        emit endResetModel();
        }
    else
        {
        setbusy(true);
        }

    m_dbhandler->Search(searchString);

    LS("Model::setSearchString <<");
}


void Model::HandleSearchComplete(const QString& searchString, QStringList list, int nwerror, bool cachedresults)
{
    LS("Model::HandleSearchComplete =>>");
    LS("Restults Arrived for:"<<searchString);
    LS("Engine is expecting for:"<<m_searchString);
    LS("Restults are:"<<list);

    if(nwerror != 0)
        {
        seterror("Internet not accessible.\nTry Again Later.");
        setbusy(false);
        //entries should not be added if there is a nw error
        return;
        }
    else
        {    
        if(QString::compare(searchString, m_searchString, Qt::CaseInsensitive) == 0)
            {
            emit beginResetModel();
            m_searchresults.clear();
            if(list.count() == 1 && list.at(0).size() != 0)
                {}
            else
                m_searchresults = list;

            if(!m_searchString.isEmpty()) {
                m_searchresults.append(QString("Search in Google.com").toAscii());
                }

            emit endResetModel();
            }
        }
    setbusy(false);

    if(!cachedresults)
        {
        LS("We did not recieve cached results");
        LS("Adding entries to cache for:"+searchString);
        LS("Entries added are:"<<list);
        if(list.count() == 1 && list.at(0).isEmpty())
            {
            QStringList tempList;
            tempList.clear();
            m_resultsmap->insert(searchString, tempList);
            }
        else
            m_resultsmap->insert(searchString, list);
        }

    LS("Model::HandleSearchComplete << ");
}

void Model::showArticle(const QString& title)
    {
    LS("Model::showArticle =>>");
    //convert title to url and setit to p_url
    QString final;
    QString temp1 = title;
    QString temp2;
    temp2 = temp1.replace(" ", "_");

#ifdef USE_MOBILE_VERSION
    final = m_urlprefix + "m.wikipedia.org/wiki/" + temp2;
#else
    final = m_urlprefix + "wikipedia.org/w/index.php?action=render&title=";
    final.append(temp2);
    final.append("&printable=yes");
#endif
    LS(final);

    seturl(final);
    LS("Model::showArticle <<");
    }

void Model::HandlePageLoaded(const QString& html)
{
    LS("Model::HandlePageLoaded >>");

    QString thtml = html;
    seturl(thtml);
    LS("Model::HandlePageLoaded <<");
}

void Model::shareArticle(const QString& url)
{
    LS("Model::shareArticle >>");
    LS(url);
    //extract the title name if the article being shared is of wikipedia origin.
    QString newurl;

#ifdef USE_MOBILE_VERSION
        newurl = url;
#else
    if(url.contains("wikipedia.org"))
        {
        //its a wikipedia site. fetch title now.
        QStringList list = url.split("&");
        foreach (QString l, list) {
            LS(l);
            if(l.contains("title="))
                {
                newurl = "http://en.wikipedia.org/wiki/" + l.right(l.size() - 6); //6-stands for 'title='
                break;
                }
            else
                newurl = url;
            }
        }
    else
        {
        newurl = url;
        }
#endif
    LS( newurl );
    QString final = "mailto:?subject=Check this article&body=I found an interesting article. Check it out.\n "+ newurl;
    QDesktopServices::openUrl(QUrl(final));
    LS("Model::shareArticle <<");
}

void Model::searchInternet(const QString& a_str)
    {
    LS("Model::searchInternet >>");
    QString str = a_str.trimmed();

    if(str.isEmpty())
        return;

    QString final;
    QString temp2;

    QByteArray exclude;
    exclude.append(" ");
    QByteArray a = QUrl::toPercentEncoding(str, exclude);
    LS(a);
    QString temp1 = a;

    temp2 = temp1.replace(" ", "+");
    final = "http://www.google.com/m?q=" + temp2;
    LS(final);
    QDesktopServices::openUrl(QUrl(final));
    LS("Model::searchInternet <<");
    }

void Model::addFavorite(const QString& /*str*/)
{
    LS("Model::addFavorite>> <<");
}

void Model::quitNow()
{
    LS("Model::quitNow() =>>");

    QFile file( CONFIGFILE );
    if ( file.open( QIODevice::WriteOnly ) )
        {
        QDataStream stream( &file );
        stream << 1; //config file version
        stream << m_fontsize;
        stream << m_showkeyboard;
        stream << m_loadimages;
        stream << m_language;
        if(m_hm)
            m_hm->writetofile(stream);

        if(m_fm)
            m_fm->writetofile(stream);
        }
    else
        {
        //nothing can be done in a destructor
        }
    file.close();

    emit canQuit();

    LS("Model::quitNow() <<");
}

QString Model::languageToStr()
{
    switch (m_language)
    {
    default:
    case 0:
        return "http://en.";
    case 1:
        return "http://pa.";
    case 2:
        return "http://cs.";
    case 3:
        return "http://da.";
    case 4:
        return "http://de.";
    case 5:
        return "http://es.";
    case 6:
        return "http://fr.";
    case 7:
        return "http://it.";
    case 8:
        return "http://hu.";
    case 9:
        return "http://nl.";
    case 10:
        return "http://no.";
    case 11:
        return "http://pt.";
    case 12:
        return "http://pl.";
    case 13:
        return "http://fi.";
    case 14:
        return "http://sv.";
    case 15:
        return "http://ru.";  }
}

void Model::setawake(bool awake)
 {
 LS("Model::setawake >>");
 LS(awake);

#ifdef USE_WAKEUP_TIMER
    if( awake == true)
    {
    if(!m_wakeuptimer.isActive())
        m_wakeuptimer.start();
    }
    else
    {
    m_wakeuptimer.stop();
    }
#endif

 LS("Model::setawake <<");
 }

void Model::timeout()
{
    LS("Model::timeout >>");
#ifdef USE_WAKEUP_TIMER
    User::ResetInactivityTime();
#endif
    LS("Model::timeout <<");
}
