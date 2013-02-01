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
import com.nokia.symbian 1.0

Rectangle {
    id: moreoptions
    width: mother.width * 0.95
    height: mother.height * 0.95
    border.color: "gray"
    border.width: 2
    color: "black"
    clip: true

    property int clrindex: 0
    property int viewheight: landscape ? moreoptions.height * 0.85 : moreoptions.height * 0.9

    Item {
        id: favlist
        width: parent.width
        height: viewheight;//moreoptions.state == "" ? viewheight : 0
        x: 0

        ListView {
            id: favlistview
            clip: true
            model: favModel
            anchors.fill: parent
            anchors.margins: 10

            delegate: Component {
                Rectangle {
                    width: parent.width
                    radius: 3
                    height: landscape ? favlist.height * 0.2 : favlist.height * 0.1;
                    color: favtitleMA.pressed ? "#0d6bb0": "#00ffffff"

                    Item {
                        id: favtitleitem
                        anchors.left: parent.left
                        width: landscape ? parent.width * 0.9 : parent.width * 0.85
                        height: parent.height

                            Text {
                                anchors.fill: parent
                                color: "white";
                                anchors.margins: 10
                                font.pixelSize: 25
                                text: title
                                elide: Text.ElideRight;
                                verticalAlignment: Text.AlignVCenter
                                }

                            MouseArea {
                                id: favtitleMA
                                anchors.fill: parent
                                onReleased: {
                                        appModel.p_url = fmurl;
                                    }
                                }
                        }

                    Item {
                        id: trashitem
                        anchors.left: favtitleitem.right
                        width: landscape ? parent.width * 0.1 : parent.width * 0.15
                        height: parent.height

                        Image {
                            id: trash
                            source: "trash.png"
                            width: 35
                            height: 35
                            anchors.verticalCenter: parent.verticalCenter
                            scale: trashMA.pressed ? 0.8 : 1.0
                            }

                        MouseArea {
                            id: trashMA
                            anchors.fill: parent
                            onPressed: {
                                favModel.removeentry(index);
                                }
                            }
                        }
                    }
                }
            }

        Text {
            anchors.centerIn: parent
            text: "Favorites not Added yet"
            color: "white"
            font.pixelSize: 20
            visible: (favlistview.count == 0 && favlist.height != 0) ? true : false
            }
        }

    Item {
        id: historylist
        width: favlist.width
        anchors.top: moreoptions.top
        anchors.left: favlist.right
        height: viewheight;//moreoptions.state == "showhistory" ? viewheight : 0
        anchors.margins: 5

        Text {
            anchors.centerIn: parent
            text: "History Not Available"
            color: "white"
            font.pixelSize: 20
            visible: (hmlist.count == 0 && historylist.height != 0) ? true : false
            }

        ListView {
            id: hmlist
            clip: true
            width: parent.width
            height: landscape ? parent.height * 0.8 : parent.height * 0.85
            model: historyModel
            delegate: Component {
                Rectangle {
                    color: stringMA.pressed ? "#0d6bb0": "#00ffffff"
                    width: parent.width * 0.99
                    radius: 4
                    height: landscape ? historylist.height * 0.2 : historylist.height * 0.1;
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
                                appModel.p_url = hmurl;
                            }
                        }
                    }
                }
            }

        Rectangle {
            id: clearallitem
            anchors.top: hmlist.bottom
            anchors.left: parent.left
            anchors.leftMargin: ((parent.width - width) / 2)-10
            width: landscape ? parent.width * 0.5 : parent.width * 0.8;
            height: landscape ? 40 : 50;
            visible: (hmlist.count == 0 || historylist.height == 0)?  false: true
            radius: 5

            gradient: Gradient {
                GradientStop { id: gradientStop; position: 0.0; color: "#ff5500" }
                GradientStop { position: 1.0; color: "red" }
                }

            SystemPalette { id: palette }

            Text {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: "black"
                font.bold: true
                font.pixelSize: 20
                text: "Clear History"
                }

            MouseArea {
                id: clearbutton
                anchors.fill: parent

                onReleased: {
                    historyModel.clearall();
                    }
                }

            states: State {
                name: "pressed"
                when: clearbutton.pressed
                PropertyChanges { target: gradientStop; color: palette.dark }
                }
           }//clearall button
        }

    Item {
        id: settingslist
        width: favlist.width
        anchors.top: moreoptions.top
        anchors.left: historylist.right
        height: viewheight;

        SelectionListItem {
            anchors.top: parent.top
            anchors.left: parent.left
            id: langlist
               property SelectionDialog selectionDialog
               title: {
                   if (!selectionDialog)
                       selectionDialog = selectionDialogComponent.createObject(moreoptions)

                    return selectionDialog.model.get(appModel.p_language).name
                    }

               anchors.horizontalCenter: parent.horizontalCenter
               width: parent.width - parent.spacing

               onClicked: {
                   if (!selectionDialog)
                       selectionDialog = selectionDialogComponent.createObject(moreoptions)
                   selectionDialog.open()
               }

               Component {
                   id: selectionDialogComponent
                   SelectionDialog {
                       titleText: "Select Language"
                       selectedIndex: 1
                       model: ListModel {
                           ListElement { name: "English" } //0
                           ListElement { name: "Catala" }
                           ListElement { name: "Cesky" }
                           ListElement { name: "Dansk" }
                           ListElement { name: "Deutsch" }
                           ListElement { name: "Espanol" }
                           ListElement { name: "Francais" }
                           ListElement { name: "Italiano" }
                           ListElement { name: "Magyar" }
                           ListElement { name: "Nederlands" }
                           ListElement { name: "Norsk" }
                           ListElement { name: "Portugues" }
                           ListElement { name: "Polski" }
                           ListElement { name: "Suomi" }
                           ListElement { name: "Svenska" }
                           ListElement { name: "Russian" } //15
                       }

                       onAccepted: {
                           appModel.p_language = selectedIndex;
                       }
                   }
               }
           }

        Rectangle {
            id: showkeyboardsetting
            anchors.top: langlist.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            height: landscape ? parent.height * 0.22 : parent.height * 0.15
            color: "#22ffffff"
            width: parent.width * 0.99
            radius: 5
            Text {
                text: "Show Qwerty keypad?"
                color: "white"
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                visible: settingslist.height == 0 ? false : true
                }

            Switch {
                id: keyswitch
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                checked: appModel.p_showkeyboard
                onClicked: {
                    if(appModel.p_showkeyboard)
                        appModel.p_showkeyboard = false;
                    else
                        appModel.p_showkeyboard = true;
                    }
                }
            }

        Rectangle {
            id: loadimagesetting
            anchors.top: showkeyboardsetting.bottom
            anchors.topMargin: 5
            radius: 5
            anchors.horizontalCenter: parent.horizontalCenter
            height: showkeyboardsetting.height
            color: showkeyboardsetting.color
            width: showkeyboardsetting.width
            Text {
                text: "Load Images?"
                color: "white"
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                visible: settingslist.height == 0 ? false : true
                }

            Switch {
                id: imageswitch
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                checked: appModel.p_loadimages
                onClicked: {
                    if(appModel.p_loadimages)
                        appModel.p_loadimages = false;
                    else
                        appModel.p_loadimages = true;
                    }
                }
            }

        Rectangle {
            id: dontfollowmesetting
            anchors.top: loadimagesetting.bottom
            anchors.topMargin: 5
            radius: 5
            anchors.horizontalCenter: parent.horizontalCenter
            height: showkeyboardsetting.height
            color: showkeyboardsetting.color
            width: showkeyboardsetting.width
            Text {
                text: "Track History?"
                color: "white"
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 20
                visible: settingslist.height == 0 ? false : true
                }

            Switch {
                id: followme
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                checked: historyModel.p_historytracking
                onClicked: {
                    if(historyModel.p_historytracking)
                        historyModel.p_historytracking = false;
                    else
                        historyModel.p_historytracking = true;
                    }
                }
            }
        }

    Rectangle {
        id: divider
        color: "gray"
        opacity: 0.7
        anchors.bottom: optionstoolbar.top
        width: parent.width
        height: 2
    }

    Rectangle {
        id: optionstoolbar
        color: "black"
        height: landscape ? parent.height * 0.15 : parent.height * 0.1
        width: parent.width;
        anchors.left: parent.left
        anchors.bottom: moreoptions.bottom

    ListView {
        id: optionslist
        anchors.fill: parent
        model: optionsmodel
        interactive: false
        orientation: ListView.Horizontal

        delegate: Component {
                Rectangle {
                    id: temprect
                    color: ( (clrindex == index) || optonstoolbarmenuMA.pressed) ? "#0d6bb0" : "#00ffffff"
                    width: (optionstoolbar.width)/ 4
                    height: optionstoolbar.height;
                    Image {
                        smooth: true
                        anchors.centerIn: parent
                        width: 45
                        height: 45
                        source: icon
                        }

                    MouseArea {
                        id: optonstoolbarmenuMA
                        anchors.fill: parent

                        onReleased: {
                            clrindex = index
                            if(functionname == "showfavorites")
                                {
                                moreoptions.state = ""
                                }
                            else if(functionname == "showhistory")
                                {moreoptions.state = "showhistory"}
                            else if(functionname == "showsettings")
                                {moreoptions.state = "showsettings"}
                            else if(functionname == "closeoptions")
                                {mother.state = "";}
                            else
                                {}
                            }
                        }
                    }
                }
            }
        }

        ListModel {
            id: optionsmodel
            ListElement { icon: "favorites.png"; functionname: "showfavorites";}
            ListElement { icon: "history.png"; functionname: "showhistory";}
            ListElement { icon: "cutewikisettings.png"; functionname: "showsettings";}
            ListElement { icon: "back.png"; functionname: "closeoptions";}
            }

    states: [
        State {
            name: ""
            PropertyChanges { target: favlist; x:0 }
        },
        State {
            name: "showhistory";
            PropertyChanges { target: favlist; x:-moreoptions.width }
            },
        State {
            name: "showsettings";
            PropertyChanges { target: favlist; x:(-moreoptions.width*2) }
            }
        ]
    transitions: [
        Transition {
            from: ""
            to: "showhistory"
            NumberAnimation {property : "x"; duration: 100;}
            },
        Transition {
            from: "showhistory"
            to: "showsettings"
            NumberAnimation {property : "x"; duration: 100;}
            },
        Transition {
            from: "showsettings"
            to: "showhistory"
            NumberAnimation {property : "x"; duration: 100;}
            },
        Transition {
            from: "showhistory"
            to: ""
            NumberAnimation {property : "x"; duration: 100;}
            }
        ]
    }
