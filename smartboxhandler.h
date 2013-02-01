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

#ifndef SmartboxHandler_H
#define SmartboxHandler_H

#include <QtCore>
#include <QNetworkAccessManager>
#include <QTimer>


class QNetworkReply;


class SmartboxHandler: public QObject
{
    Q_OBJECT

public:

    SmartboxHandler(QObject* parent = NULL);

    ~SmartboxHandler();

    void Search(const QString& searchString);

    void fetchArticle(QString title);

    void seturlprefix(QString prefix) {
        m_urlprefix = prefix;
    }

public slots:

private slots:
    void httpFinished();
    void httpReadyRead();
    void timerOut();
    void httpFinished2();
    void httpReadyRead2();
    #ifndef QT_NO_OPENSSL
    void sslErrors(QNetworkReply*,const QList<QSslError> &errors);
    #endif
    void slotnetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility accessible);
signals:
    void operationcomplete(const QString& searchString, QStringList data, int error);
    void pageloaded(const QString& html);
private:
    QNetworkAccessManager m_qnam;
    QNetworkReply* m_reply;
    QNetworkReply* m_reply2;
    QNetworkReply* m_tracker;
    QString m_searchString;
    QString m_result;
    QString m_result2;
    QByteArray m_xmlresult;
    QTimer m_timer;
    QString m_urlprefix;
};

#endif // SmartboxHandler_H
