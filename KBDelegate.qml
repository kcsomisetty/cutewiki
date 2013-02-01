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
    Item {
        id: kbitem
        width: row1.width * 0.098
        height: row1.height

        Rectangle {
            anchors.fill: parent
            anchors.margins: parent.width * 0.05
            //anchors.fill: parent
            color: letterMA.pressed ? "lightgray" : "#4d4d4d"
            radius: 3
            Text {
                font.pixelSize: 25
                text: mother.numericmode ? number : character
                color: letterMA.pressed ? "black" : "white"
                anchors.centerIn: parent
                }

            MouseArea {
                id: letterMA
                anchors.fill: parent
                onPressed: {
                    //var t = searchinput.text
                    var txt = mother.numericmode ? number : character;

                    if(txt == "9" || txt == "q" || txt == "w" || txt == "e" || txt == "r" || txt == "t" || txt == "y" || txt == "u" || txt == "i" || txt == "o" || txt == "p" || txt == "1" || txt == "2" || txt == "3" || txt == "4" || txt == "5" || txt == "6" || txt == "7" || txt == "8" || txt == "0")
                        {//row1
                        highlighter.x = kbitem.x;
                        highlighter.anchors.bottom = row1.top
                        highlighter.anchors.bottomMargin = 10
                        }
                    else if(txt == "a" || txt == "s" || txt == "d" || txt == "f" || txt == "g" || txt == "h" || txt == "j" || txt == "k" || txt == "l" || txt == "@" || txt == "#" || txt == "$" || txt == "!" || txt == "&" || txt == "*" || txt == "-" || txt == "+" || txt == ".")
                        {//row2
                        //adjust the x
                        highlighter.x =  kbitem.x + row2.x
                        highlighter.anchors.bottom = row2.top
                        highlighter.anchors.bottomMargin = 10
                        }
                    else if(txt == "z" || txt == "x" || txt == "c" || txt == "v" || txt == "b" || txt == "n" || txt == "m" || txt == "(" || txt == ")" || txt == "%" || txt == ":" || txt == "?" || txt == "'" || txt == "/")
                        {//row3
                        highlighter.x =  kbitem.x + row3keys.x;
                        highlighter.anchors.bottom = row3.top
                        highlighter.anchors.bottomMargin = 10
                        }

                    highlightertext.text = txt;
                    addchar(txt);
                    //searchinput.text += txt;
                    }
                }
            }
        }
    }
