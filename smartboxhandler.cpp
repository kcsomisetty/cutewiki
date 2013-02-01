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

#include <QtNetwork>
#include <QDir>
#include <QVariant>
#include <QChar>
#include <QDesktopServices>
#include <QTextCodec>
#include <QtXml/QDomDocument>

#include "config.h"
#include "SmartboxHandler.h"

SmartboxHandler::SmartboxHandler(QObject* parent):
        QObject(parent),
        m_searchString(""),
        m_tracker(0),
        m_reply(0),
        m_reply2(0),
        m_urlprefix("http://en.")
{
    LS("SmartboxHandler::SmartboxHandler =>");

    //dont give a proper url. we dont want its data to be accessed.
    //we just want to initiate connection.
#ifdef CONNECT_UPON_LAUNCH
    QString s = "http://www.googleeeeeeeeeeeeeee.com";
    m_tracker = m_qnam.get(QNetworkRequest(QUrl(s)));
#endif

    m_timer.setSingleShot(true);
    m_timer.setInterval(1000);
    connect(&m_timer, SIGNAL(timeout()), this, SLOT(timerOut()));
    connect(&m_qnam, SIGNAL(networkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)),
        this, SLOT(slotnetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)));
    LS("SmartboxHandler::SmartboxHandler <<");
}

void SmartboxHandler::timerOut()
{
    LS("SmartboxHandler::timerOut =>");

    if(m_reply != NULL)
        {
        //some search is already in progress
        LS("issue abort");
        m_reply->deleteLater();
        m_reply = 0;
        }

    if(m_searchString.isEmpty())
        return; //dont do anything

#ifndef FULL_TEXT_SEARCH
    QString s = "http://en.wikipedia.org/w/api.php?action=opensearch&format=json&search=";
#else
    QString s = m_urlprefix + "wikipedia.org/w/api.php?action=query&list=search&format=xml&srwhat=text&srlimit=20&srsearch=";
#endif

    QByteArray b1;
    b1.append("/?&=:+");

    QByteArray b = QUrl::toPercentEncoding(m_searchString, b1);
    s.append(b);
    LS(s);

    m_reply = m_qnam.get(QNetworkRequest(QUrl(s)));
    connect(m_reply, SIGNAL(finished()),this, SLOT(httpFinished()));
    connect(m_reply, SIGNAL(readyRead()),this, SLOT(httpReadyRead()));
    LS("SmartboxHandler::timerOut <<");
}

void SmartboxHandler::httpReadyRead()
{
    LS("SmartboxHandler::httpReadyRead =>");
    if(m_searchString.isEmpty())
        return;

#ifndef FULL_TEXT_SEARCH
    m_result += m_reply->readAll();
#else
    m_xmlresult += m_reply->readAll();
#endif
    LS("SmartboxHandler::httpReadyRead <<");
}

void SmartboxHandler::httpFinished()
{
    LS("SmartboxHandler::httpFinished =>");
    Q_ASSERT(m_reply);

    if(m_searchString.isEmpty())
        {
        emit operationcomplete(m_searchString, QStringList(), 0);
        //does controler every come here. incase it comes emit operation complete, release resources and quit.
        m_reply->deleteLater();
        m_reply = 0;
        return;
        }

    int nwerror = m_reply->error();

    if(nwerror !=0)
        {
        m_reply->deleteLater();
        m_reply = 0;
        LS( m_xmlresult );
        m_xmlresult = "";

        if (nwerror == 5) {
            //operation cancelled
            //search again
            Search(m_searchString);
            return;
            }
        else
            {
            LS("Network error: " <<QString::number(nwerror));
            emit operationcomplete(m_searchString, QStringList(), nwerror);
            return;
            }
        }

    QStringList final;

#ifndef FULL_TEXT_SEARCH
    QString result = m_result;
    LS( "http ready read :"<< result <<":");

    result.chop(2);
    LS( result );

    int index = result.lastIndexOf("[");
    result.remove(0, index+1);
    LS( result );

    QStringList list = result.split(",");
    LS( list );

    foreach(QString liststr, list) {
        liststr.chop(1);
        liststr.remove(0,1);
        LS(liststr);
        final.append(liststr);
        }
    m_result = "";
#else
    QDomDocument dm;
    //LS(m_xmlresult);
    if(dm.setContent(m_xmlresult, true)) {
    QDomNodeList list = dm.elementsByTagName("p");

    for(int i=0; i<list.count(); i++) {
        QDomNode node = list.at(i);
        if(node.isElement())
            {
            QString val = node.toElement().attribute("title");
            LS(val);
            if(!val.isEmpty()) {
                final.append(val);
                LS(val);
                }
            }
        }
    }

    m_xmlresult = "";
#endif

    m_reply->deleteLater();
    m_reply = 0;

    emit operationcomplete(m_searchString, final, 0);

    final.clear();

    LS("SmartboxHandler::httpFinished <<");
}



void SmartboxHandler::Search(const QString& searchString)
{
    LS("SmartboxHandler::Search =>");

    if(m_timer.isActive())
        m_timer.stop();

    m_searchString = searchString;
    LS(m_searchString);
    m_timer.start();
    LS("SmartboxHandler::Search <<");
}

void SmartboxHandler::httpFinished2()
{
    LS("SmartboxHandler::httpFinished2 =>");
    LS(m_result2);
    emit pageloaded(m_result2);
    //m_result2 = "";
    LS("SmartboxHandler::httpFinished2 <<");
}

void SmartboxHandler::httpReadyRead2()
{
    LS("SmartboxHandler::httpReadyRead2 =>");
    m_result2 += m_reply2->readAll();
    //LS(m_result2);
    LS("SmartboxHandler::httpReadyRead2 <<");
}

void SmartboxHandler::fetchArticle(QString title)
{
    LS("SmartboxHandler::fetchArticle =>");

    if(m_reply2 != 0)
        {
        //some search is already in progress
        LS("issue abort for article fetch");
        m_reply2->deleteLater();
        m_reply2 = 0;
        }

    if(title.isEmpty())
        return; //dont do anything

    //convert spaces in title to userscore
    QString temp;
    temp = title.replace(" ", "_");
    //more entries if more formatting is needed

    QString s = "http://en.wikipedia.org/w/index.php?action=render&title=";
    s.append(temp);
    s.append("&printable=yes");
    QByteArray b1;
    b1.append("/&?=:()");
    QByteArray b = QUrl::toPercentEncoding(s, b1);
    LS(b);

    m_reply2 = m_qnam.get(QNetworkRequest(QUrl(b)));
    connect(m_reply2, SIGNAL(finished()),this, SLOT(httpFinished2()));
    connect(m_reply2, SIGNAL(readyRead()),this, SLOT(httpReadyRead2()));
    LS("SmartboxHandler::fetchArticle <<");
}


void SmartboxHandler::sslErrors(QNetworkReply*,const QList<QSslError> &errors)
{
LS("SmartboxHandler::sslErrors >> <<");
}

SmartboxHandler::~SmartboxHandler()
    {
    LS("SmartboxHandler::~SmartboxHandler >> ");
    m_timer.stop();

    if(m_tracker)
        {
        delete m_tracker;
        m_tracker = 0;
        }

    if(m_reply)
        {
        delete m_reply;
        m_reply = 0;
        }

    if(m_reply2)
        {
        delete m_reply2;
        m_reply2 = 0;
        }
    LS("SmartboxHandler::~SmartboxHandler <<");
    }

void SmartboxHandler::slotnetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility accessible)
    {
    LS("SmartboxHandler::slotnetworkAccessibleChanged =>>");
    LS(QString::number(accessible));
    LS("SmartboxHandler::slotnetworkAccessibleChanged <<");
    }
