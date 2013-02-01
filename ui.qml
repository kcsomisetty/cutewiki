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
import QtWebKit 1.0
import com.nokia.symbian 1.0

Rectangle {
    id: mother
    width: 360
    height: 640
    color: "black"
    property bool numericmode: false
    property bool landscape: width > height ? true : false
    property bool usercancelledoperation: false
    property Dialog sdx;

    // 0 - fetch started
    // 1 - fetch failed
    // 2 - fetch success
    property int previousfetchfailed: 0

Item {
    id: searchview
    x: 0
    width: mother.width
    height: mother.height
    anchors.top: mother.top

    onXChanged: {
        }

    Rectangle {
        id: searchinput
        height: landscape ? parent.height * 0.12 : parent.height * 0.08
        width: parent.width
        property alias text: searchtext.text
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.left: parent.left
        radius: 2

        gradient: Gradient {
            GradientStop { position: 0.0; color: "lightgray" }
            //GradientStop { position: 0.45; color: "lightgreen" }
            GradientStop { position: 1.0; color: "gray" }
            }

        Rectangle {
            id: searchtextholder
            anchors.left: parent.left
            anchors.margins: 4
            anchors.verticalCenter: parent.verticalCenter
            width: landscape ? parent.width * 0.87 : parent.width * 0.8
            height: parent.height * 0.8;
            color: "white"
            radius: 8

            CustomInput {
                id: searchtext
                focus: true
                anchors.fill: parent
                subtext: "Search Wikipedia"
                text: ""

                onTextChanged: {
                    appModel.setSearchString(searchtext.text)
                    }
                }

            Image {
                id: busyicon
                anchors.right: searchtext.right
                anchors.margins: 5
                anchors.verticalCenter: searchtext.verticalCenter
                source: "progress.png"
                width: 25
                height: 25
                visible: appModel.p_busy ? true : false
                //z:4

                PropertyAnimation on rotation { to: 360; duration: 1000; loops: Animation.Infinite}
                }
            }

        Image {
            id: searchinternet
            smooth: true
            anchors.left: searchtextholder.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10
            source: "internet.png"
            width: landscape ? parent.width * 0.09 : parent.width * 0.15
            height: searchtextholder.height
            scale: searchMouseArea.pressed ? 0.8 : 1.0

            onScaleChanged: {
                if(scale == 1.0)
                    {
                    if(searchtext.text != "")
                        {
                        appModel.searchInternet(searchtext.text)
                        }
                    }
                }

            MouseArea {
                id: searchMouseArea
                anchors.fill: parent
                }
            }
        } //info pane

    Rectangle {
        id: searchresultsitem
        anchors.top: searchinput.bottom
        anchors.left: parent.left
        color: "black"

        width: parent.width * 0.99
        property int withkbheight: landscape ? parent.height * 0.38 : parent.height * 0.47
        height: (appModel.p_showkeyboard) ? withkbheight : parent.height * 0.80

        HMDelegate {id: delegate3 }

        ListView {
            id: searchresults
            clip: true
            anchors.fill: parent
            anchors.margins: 5
            model: appModel
            delegate: delegate3
                }
            }

    Item {
        id: keyboard
        width: parent.width * 0.99
        height: landscape ? parent.height * 0.50 : parent.height * 0.45
        anchors.bottom: parent.bottom
        visible: appModel.p_showkeyboard
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            anchors.fill: parent
            color: "black"
        }

        KBDelegate {
            id: kbdelegateitem
        }

        ListView {
            id: row1
            orientation: Qt.Horizontal
            width: parent.width
            height: parent.height * 0.27
            anchors.top: parent.top
            anchors.left: parent.left
            interactive: false
            model: kbmodelrow1
            delegate: kbdelegateitem
        }

        ListModel {
            id: kbmodelrow1
            ListElement { character: "q"; number: "1";}
            ListElement { character: "w"; number: "2";}
            ListElement { character: "e"; number: "3";}
            ListElement { character: "r"; number: "4";}
            ListElement { character: "t"; number: "5";}
            ListElement { character: "y"; number: "6";}
            ListElement { character: "u"; number: "7";}
            ListElement { character: "i"; number: "8";}
            ListElement { character: "o"; number: "9";}
            ListElement { character: "p"; number: "0";}
            }

        ListView {
            id: row2
            anchors.top: row1.bottom
            orientation: Qt.Horizontal
            width: parent.width * 0.9
            height: parent.height * 0.27
            anchors.horizontalCenter: parent.horizontalCenter
            interactive: false
            model: kbmodelrow2
            delegate: kbdelegateitem
        }

        ListModel {
            id: kbmodelrow2
            ListElement { character: "a"; number: "@";}
            ListElement { character: "s"; number: "#";}
            ListElement { character: "d"; number: "$";}
            ListElement { character: "f"; number: "!";}
            ListElement { character: "g"; number: "&";}
            ListElement { character: "h"; number: "*";}
            ListElement { character: "j"; number: "-";}
            ListElement { character: "k"; number: "+";}
            ListElement { character: "l"; number: ".";}
        }

        Item {
            id: row3
            width: parent.width
            height: parent.height * 0.27
            anchors.top: row2.bottom

            Item {
                id: numericmodeitem
                width: parent.width * 0.14
                height: parent.height * 0.95
                anchors.left: parent.left
                //anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    color: numericMA.pressed ? "lightgray" : "#4d4d4d"
                    radius: 3
                    Text {
                        font.pixelSize: 25
                        text: numericmode ? "A#" : "1#"
                        color: numericMA.pressed ? "black":"white"
                        anchors.centerIn: parent
                        }

                    MouseArea {
                        id: numericMA
                        anchors.fill: parent
                        onPressed: {
                            if(mother.numericmode)
                                mother.numericmode = false;
                            else
                                mother.numericmode = true;
                            }
                        }
                    }
                }

            ListView {
                id: row3keys
                orientation: Qt.Horizontal
                width: parent.width * 0.70
                height: parent.height
                anchors.left: numericmodeitem.right
                anchors.leftMargin: 3
                interactive: false
                model: kbmodelrow3
                delegate: kbdelegateitem
                }

            Rectangle {
                id:backitem
                color: backMA.pressed ? "lightgray" : "#4d4d4d"
                width: parent.width * 0.16
                height: parent.height * 0.95
                anchors.left: row3keys.right
                anchors.verticalCenter: parent.verticalCenter
                radius: 2

                Image {
                    width: landscape ? 50 : 40
                    height: 30
                    anchors.centerIn: parent
                    source: "clear.png"
                    smooth: true
                    }
                MouseArea {
                    id: backMA
                    anchors.fill: parent
                    onPressAndHold: {
                        searchtext.text = ""
                        }

                    onReleased: {
                        chopString(searchtext.text);
                        }
                    }
                }
            }

        ListModel {
            id: kbmodelrow3
            ListElement { character: "z"; number: "(";}
            ListElement { character: "x"; number: ")";}
            ListElement { character: "c"; number: "%";}
            ListElement { character: "v"; number: ":";}
            ListElement { character: "b"; number: "?";}
            ListElement { character: "n"; number: "'"}
            ListElement { character: "m"; number: "/";}
        }

        Item {
            id: row4
            anchors.top: row3.bottom
            anchors.topMargin: 2
            width: parent.width
            height: parent.height * 0.20

            Item {
                id: spaceitem
                width: parent.width * 0.68
                height: parent.height * 0.95
                anchors.top: parent.top
                anchors.topMargin:(parent.height - height) / 2
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    color: spaceMA.pressed ? "lightgray" : "#4d4d4d"
                    radius: 3
                    Text {
                        font.pixelSize: 25
                        text: "space"
                        color: spaceMA.pressed ? "black":"white"
                        anchors.centerIn: parent
                        }

                    MouseArea {
                        id: spaceMA
                        anchors.fill: parent
                        onPressed: {
                            //var t = searchinput.text
                            //searchinput.text = t + " "
                            var t = " "
                            addchar(t);
                            }
                        }
                    }
                }
            }

    Rectangle {
        id: highlighter
        color: "#0d6bb0"
        height: 50
        width: 50
        radius: 2
        visible: (highlightertext.text == "") ? false : true
        z: 5

        Text {
            id: highlightertext
            anchors.centerIn: parent
            anchors.margins: 10
            font.pixelSize: 30
            color: "white"
            text: ""
            onTextChanged: {
                if(text != "")
                    {
                    highlightertexthider.running = true;
                    }
                }
            }

        Timer {
            id: highlightertexthider
            interval: 330; running: false; repeat: false
            onTriggered: {
                highlightertext.text = ""
                }
            }
        }
    }

    Rectangle {
        id: settingsbutton
        color: "#4d4d4d"
        width:  parent.width * 0.15
        height: row4.height * 0.88
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        //anchors.verticalCenter: parent.verticalCenter
        Image {
            width: 50
            height: parent.height
            anchors.centerIn: parent
            source: "showmoreoptions.png"
            smooth: true
            scale: settingsMA.pressed ? 0.8 : 1.0
            onScaleChanged: {
                if(scale == 1.0)
                    mother.state = "showmoreoptions";
                }
            }

        MouseArea {
            id: settingsMA
            anchors.fill: parent
            }
        }

    Rectangle {
        id: exitbutton
        color: "#4d4d4d"
        width:  parent.width * 0.15
        height: row4.height * 0.88
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        Image {
            width: 50
            height: parent.height
            anchors.centerIn: parent
            source: "exit.png"
            smooth: true
            scale: exitMA.pressed ? 0.8 : 1.0
            onScaleChanged: {
                if(scale == 1)
                    Qt.quit();
                }
        }

        MouseArea {
            id: exitMA
            anchors.fill: parent
            }
        }

    Behavior on x {
        NumberAnimation{duration: 250}
    }
}

Item {
    id: webpageitem
    width: mother.width
    height: mother.height
    anchors.fill: parent
    visible: false
    onVisibleChanged: {
        //if(visible)
            //console.debug("webpageitem visible now");
        //else
            //console.debug("webpageitem not visible now");
        }

    Item {
        id: zoominout
        width: 55
        height: zoomin.height + zoomout.height
        visible: wikipagetoolbar.visible ? true : false
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        z: 5
        opacity: 0.3

        Image {
            id: zoomin
            smooth: true
            anchors.margins: 1
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            source: "zoomin.png"
            width: 50
            height: 65
            scale: zoominMA.pressed ? 0.9 : 1.0

            onScaleChanged: {
                if(scale == 1.0)
                    {
                    if(web.settings.defaultFontSize <30)
                        {
                        var f = web.settings.defaultFontSize;
                        f+=3;
                        appModel.p_fontsize = f;
                        }
                    //zoomhider.restart();
                    }
            }

            MouseArea {
                id: zoominMA
                anchors.fill: parent
                }
            }

        Image {
            id: zoomout
            //asynchronous: true
            smooth: true
            anchors.margins: 1
            anchors.top: zoomin.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            source: "zoomout.png"
            width: 50
            height: 65
            scale: zoomoutMA.pressed ? 0.9 : 1.0

            onScaleChanged: {
                if(scale == 1.0)
                    {
                    //console.debug("zoom out")
                    //console.debug(web.settings.defaultFontSize)
                    if(web.settings.defaultFontSize > 8)
                        {
                        var f = web.settings.defaultFontSize;
                        f-=3;
                        appModel.p_fontsize = f;
                        }

                    //zoomhider.restart();
                    }
            }

            MouseArea {
                id: zoomoutMA
                anchors.fill: parent
                }
            }
        }

    Flickable {
        id: webpageview;
        width: mother.width
        height: mother.height
        anchors.fill: parent
        //clip: true

        //contentWidth: web.width; contentHeight: web.height
        contentWidth: Math.max(mother.width,web.width)
        contentHeight: Math.max(mother.height,web.height)
        pressDelay: 200

        onWidthChanged : {
            // Expand (but not above 1:1) if otherwise would be smaller that available width.
            //console.debug("webpageview width changed");
            if (width > web.width*web.contentsScale && web.contentsScale < 1.0)
                web.contentsScale = width / web.width * web.contentsScale;
            }

        WebView {
            id: web
            //transformOrigin: Item.TopLeft
            //smooth: false
            //onAlert: //console.debug(message)
            preferredWidth: webpageview.width
            preferredHeight: webpageview.height
            contentsScale: 1.0
            settings.defaultFontSize: appModel.p_fontsize;
            settings.autoLoadImages: appModel.p_loadimages;

            onVisibleChanged: {
                //if(visible)
                    //console.debug("web visible now");
                //else
                    //console.debug("web not visible now");
            }

            onContentsSizeChanged: {
                // zoom out
                //contentsScale = Math.min(1,webpageview.width / contentsSize.width)
                }

            url: ""
            visible: false

            onLoadFinished: {
                //console.debug("onLoadFinished");
                //console.debug(web.height)
                webpageview.contentY += 1;
                visible = true;
                progressindiacator.visible = false;
                previousfetchfailed = 2;
                }

            onLoadFailed: {
                //console.debug("onLoadFailed");
                //console.debug(web.url)
                //console.debug(usercancelledoperation);
                //console.debug(web.visible);
                //console.debug(web.html);

                previousfetchfailed = 1;
                progressindiacator.visible = false;

                if(web.url == appModel.p_url && (!web.visible || web.html.length < 40))
                    {
                    mother.state = "";
                    //appModel.p_url = "";
                    }

                if(usercancelledoperation)
                    usercancelledoperation = false;
                else
                    appModel.p_error = "Webpage could not be fetched";

                }

            onLoadStarted : {
                //console.debug("onLoadStarted");
                progressindiacator.visible = true;
                previousfetchfailed = 0;
                }

            onUrlChanged : {
                //console.debug("onUrlChanged");
                if(web.url != "")
                    historyModel.addentry(web.url);
                }
            }
        }


    Rectangle {
        id: progressindiacator
        anchors.centerIn: parent
        visible: true
        color: "#AA000000"
        width: landscape ? parent.width * 0.4 : parent.width * 0.7
        height: landscape ? parent.width * 0.2 : parent.height * 0.25
        radius: 5

        Text {
            id: progressindicatortext
            text: "Loading"
            font.pixelSize: 22
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.2
            }

        Text {
            id: progressindicatortext_ext
            text: ""
            font.pixelSize: 26
            color: "white"
            anchors.left: progressindicatortext.right
            anchors.verticalCenter: progressindicatortext.verticalCenter
            }

        Button {
            id: cancelbutton
            anchors.top: progressindicatortext.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.6
            height: parent.height * 0.25
            text: "Cancel";
            onClicked: {
                usercancelledoperation = true;
                web.stop.trigger();

                if(appModel.p_url == web.url)
                    {
                    //this might happen when first time an article is requested or when Secondary level link is pressed and cancelled immediately.
                    if(!web.visible)
                        mother.state = "";
                    }
                }
            }

//        TextButton {
//            id: cancelbutton
//            anchors.top: progressindicatortext.bottom
//            anchors.topMargin: 20
//            anchors.horizontalCenter: parent.horizontalCenter
//            width: parent.width * 0.6
//            height: parent.height * 0.25
//            text: "Cancel";
//            onClicked: {
//                usercancelledoperation = true;
//                web.stop.trigger();

//                if(appModel.p_url == web.url)
//                    {
//                    //this might happen when first time an article is requested or when Secondary level link is pressed and cancelled immediately.
//                    if(!web.visible)
//                        mother.state = "";
//                    }
//                }
//            }

        Timer {
            id: heartbeat
            interval: 350; running: progressindiacator.visible; repeat: true
            onTriggered: {
                if(progressindicatortext_ext.text.length == 0)
                    progressindicatortext_ext.text = ".";
                else if(progressindicatortext_ext.text.length == 1)
                    progressindicatortext_ext.text = "..";
                else if(progressindicatortext_ext.text.length == 2)
                    progressindicatortext_ext.text = "...";
                else if(progressindicatortext_ext.text.length == 3)
                    progressindicatortext_ext.text = "....";
                else
                    progressindicatortext_ext.text = "";
                }
            }
        }

    Rectangle {
        id: wikipagetoolbar
        color: "#AA4d4d4d"
        height: landscape ? parent.height * 0.15 : parent.height * 0.1
        width: parent.width;
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        visible: (web.visible && !progressindiacator.visible) ? true : false;

        Row {
            id: roww
            anchors.fill: parent

            Rectangle {
               color: menuMA1.pressed ? "#0d6bb0" : "#00ffffff"
               radius: 4
               anchors.margins: 3
               width: (parent.width)/ 5
               height: parent.height * 0.9;

               Image {
                   smooth: true
                   anchors.centerIn: parent
                   width: 40
                    height: 40
                    source: "back.png"
                   }

               MouseArea {
                   id: menuMA1
                   anchors.fill: parent

                   onReleased: { gotoPrevious();  }
                    }
                }

            Rectangle {
               color: menuMA2.pressed ? "#0d6bb0" : "#00ffffff"
               radius: 4
               anchors.margins: 3
               width: (parent.width)/ 5
               height: parent.height * 0.9;

               Image {
                   smooth: true
                   anchors.centerIn: parent
                   width: 40
                    height: 40
                    source: "home.png"
                   }

               MouseArea {
                   id: menuMA2
                   anchors.fill: parent

                   onReleased: { mother.state = ""; web.visible = false;  }
                    }
                }

            Rectangle {
               color: menuMA3.pressed ? "#0d6bb0" : "#00ffffff"
               radius: 4
               anchors.margins: 3
               width: (parent.width)/ 5
               height: parent.height * 0.9;

               Image {
                   smooth: true
                   anchors.centerIn: parent
                   width: 40
                    height: 40
                    source: "addfavorites.png"
                   }

               MouseArea {
                   id: menuMA3
                   anchors.fill: parent

                   onReleased: { favModel.addfavpage(web.url); }
                    }
                }

            Rectangle {
               color: menuMA5.pressed ? "#0d6bb0" : "#00ffffff"
               radius: 4
               anchors.margins: 3
               width: (appModel.p_loadimages) ? (parent.width)/ 5 : 0
               height: parent.height * 0.9;

               Image {
                   smooth: true
                   anchors.centerIn: parent
                   width: (parent.width) ? 40 : 0
                    height: (parent.width) ? 40 : 0
                    source: "imageloadon.png"
                   }

               MouseArea {
                   id: menuMA5
                   anchors.fill: parent

                   onReleased: { appModel.p_loadimages = false; }
                    }
                }

            Rectangle {
               color: menuMA6.pressed ? "#0d6bb0" : "#00ffffff"
               radius: 4
               anchors.margins: 3
               width: (appModel.p_loadimages) ? 0 : (parent.width)/ 5
               height: parent.height * 0.9;

               Image {
                   smooth: true
                   anchors.centerIn: parent
                   width: (parent.width) ? 40 : 0
                    height: (parent.width) ? 40 : 0
                    source: "imageloadoff.png"
                   }

               MouseArea {
                   id: menuMA6
                   anchors.fill: parent

                   onReleased: { appModel.p_loadimages = true; }
                    }
                }

            Rectangle {
               color: menuMA4.pressed ? "#0d6bb0" : "#00ffffff"
               radius: 4
               anchors.margins: 3
               width: (parent.width)/ 5
               height: parent.height * 0.9;

               Image {
                   smooth: true
                   anchors.centerIn: parent
                   width: 40
                    height: 40
                    source: "email.png"
                   }

               MouseArea {
                   id: menuMA4
                   anchors.fill: parent

                   onReleased: { sharearticle(); }
                    }
                }

            }
        }
}


//ErrorDialog {
//    id: syserrordialog
//    z: 5
//    anchors.top: parent.top
//    anchors.topMargin: landscape ? parent.height * 0.15 : parent.height * 0.20
//    anchors.horizontalCenter: parent.horizontalCenter
//    //source: appModel.p_error != "" ? "ErrorDialog.qml" : ""
//    }

Loader {
    id: moreoptionsloader
    anchors.centerIn: mother
    width: parent.width * 0.95
    height:  parent.height * 0.98
    //color: "black"
    //border.color: "gray"
    //border.width: 2
    visible: false
    source: visible ? "options.qml" : ""

    onVisibleChanged: {
        //if(visible)
            //console.debug("moreoptions visible now");
        //else
            //console.debug("moreoptions not visible now");

        }
}


states: [
    State {
        name: "";
        PropertyChanges {target: searchview; visible: true;}
        PropertyChanges {target: appModel; p_keepawake: false;}
        PropertyChanges {target: webpageitem; visible: false;}
        PropertyChanges {target: searchtext; focus: true;}
        },
    State {
        name: "showwebpage";
        PropertyChanges {target: searchview; visible: false;}
        //PropertyChanges {target: searchview; visible: false;}
        PropertyChanges {target: webpageitem; visible: true;}
        PropertyChanges {target: web; visible: false;}
        PropertyChanges {target: searchtext; focus: false;}
        PropertyChanges {target: appModel; p_keepawake: true;}
        },
    State {
        name: "showmoreoptions";
        PropertyChanges {target: searchview; visible: false;}
        PropertyChanges {target: moreoptionsloader; visible: true;}
        PropertyChanges {target: searchtext; focus: false;}
        }
    ]

transitions: [
    Transition {
        from: ""; to: "showwebpage"
        //PropertyChanges {target: searchtext; focus: true;}
        NumberAnimation {property : "x"; duration: 200;}
        },
    Transition {
        from: "showwebpage"; to: ""
        NumberAnimation {property : "x"; duration: 100;}
        }
    ]

function newurl()
{
    //first time
    //second time
    //selection from history
    mother.state = "showwebpage"

    if(web.url == appModel.p_url)
        {
        //console.debug("new url is same as old one");
        if(previousfetchfailed == 2)
            {
            //console.debug("article is already loaded. just show the view");
            progressindiacator.visible = false;
            web.visible  = true; //just in case. not required though.
            }
        else
            {
            //control can come here even if with same url and failed state.
            //so just reset the url before assigning it.
            //console.debug("issue a reload");
            web.url = "";
            web.url = appModel.p_url;
            }
        }
    else
        {
        //console.debug("new url. just assign it");
        web.url = appModel.p_url;
        }
}

function gotoPrevious()
    {
    if(web.url == appModel.p_url || web.url == "")
        {
        mother.state = "";
        //stop if loading is already in progress
        }
    else
        {
        web.stop.trigger();
        web.back.trigger();
        }

    }

function sharearticle()
    {
    appModel.shareArticle(web.url);
    }

function addchar(txt)
{
    var str = searchtext.text;
    var previousposition = searchtext.position;
    //console.log(previousposition)
    var t = str.substring(0, searchtext.position);
    t = t + txt;
    t = t + str.substring(searchtext.position, str.length)
    searchtext.text = t;
    searchtext.position = previousposition+1;
}

function chopString(str)
    {    
    var previousposition = searchtext.position;
    var t = str.substring(0, searchtext.position-1);
    t = t + str.substring(searchtext.position, str.length)
    searchtext.text = t;
    searchtext.position = previousposition-1;
    //searchtext.text = str.substring(0, str.length-1);
    }

function gotoNext()
    {
    web.forward.trigger();
    }

Component {
        id: errdialogcomponent

        CommonDialog {
            id: errdialog
            titleText: "Error"
            width: parent.width * 0.5
            height: landscape ? parent.height * 0.4 : parent.height * 0.3
            visible: false

            buttons: ToolBar {
                id: buttons
                width: parent.width
                height: errdialog.height * 0.3

                tools: Row {
                    anchors.centerIn: parent
                    spacing: 1

                    ToolButton {
                        text: "OK"
                        width: buttons.width * 0.8
                        onClicked: { errdialog.accept(); appModel.p_error = ""}
                        }
                    }
                }

            content: Text {
                id: errdialogmessage
                text: appModel.p_error
                color: "white"
                font { bold: true; pixelSize: 20 }
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }


Connections {
    target: appModel
    onErrorChanged: {
        if(appModel.p_error == "")
            return;

        if (!sdx)
            sdx = errdialogcomponent.createObject(mother)

        if(sdx)
            sdx.open()
        }
    }

}
