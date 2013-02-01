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

import QtQuick 1.0

Component {
    Rectangle {
        color: stringMA.pressed ? "#0d6bb0": "#00ffffff"
        width: parent.width * 0.99
        radius: 4
        property int withkbheightitem: landscape ? searchresults.height * 0.25 : searchresults.height * 0.15;
        property int withoutkbheightitem: landscape ? searchresults.height * 0.20 : searchresults.height * 0.1;

        height: appModel.p_showkeyboard ? withkbheightitem : withoutkbheightitem
        Text {
            id: resultstitle
            color: "white";
            anchors.fill: parent
            anchors.margins: 10
            font.pixelSize: 25
            text: title
            width: parent.width
            elide: Text.ElideRight;
            verticalAlignment: Text.AlignVCenter
            }

        MouseArea {
            id: stringMA
            anchors.fill: parent
            onReleased: {
                if(title == "Search in Google.com")
                    {
                    appModel.searchInternet(searchtext.text);
                    }
                else
                    {
                    appModel.showArticle(title);
                    }
                }
            }
        }
    }
