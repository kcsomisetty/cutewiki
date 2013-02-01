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

import Qt 4.7

FocusScope {
    id: focusScope
    property alias text: textInput.text
    property string subtext: ""
    property alias echoMode: textInput.echoMode
    property alias position: textInput.cursorPosition

    Text {
        id: typeSomething
        anchors.fill: parent;
        anchors.leftMargin: 8
        verticalAlignment: Text.AlignVCenter
        text: subtext
        color: "gray"
        font.italic: true
        font.pixelSize: parent.height / 2;
    }

    MouseArea { 
        anchors.fill: parent
        //onClicked: { textInput.openSoftwareInputPanel(); }//focusScope.focus = true;}
    }

    TextInput {
        id: textInput
        width: parent.width * 0.85
        anchors { left: parent.left; leftMargin: 8;
        rightMargin: 8; verticalCenter: parent.verticalCenter }
        color: "#151515"; selectionColor: "green"
        font.pixelSize: parent.height / 2
        cursorVisible: true
        activeFocusOnPress: true
        //focus: mother.state == "" ? true : false
        onFocusChanged: {
            if(appModel.p_showkeyboard)
                return;

            if(!focus)
                textInput.closeSoftwareInputPanel();
            else
                textInput.openSoftwareInputPanel();
        }
    }

    states: State {
        name: "hasText"; when: textInput.text != ''
        PropertyChanges { target: typeSomething; opacity: 0 }
    }

    transitions: [
        Transition {
            from: ""; to: "hasText"
            NumberAnimation { exclude: typeSomething; properties: "opacity" }
        },
        Transition {
            from: "hasText"; to: ""
            NumberAnimation { properties: "opacity" }
        }
    ]
}
