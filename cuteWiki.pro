#cutewiki is wikipedia reader for symbian and meego platforms
#Copyright (C) 2010 Krishna Somisetty

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#cutewiki is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.


#cusrule.pkg_prerules = \
#"%{\"Somisetty\"}"\
#" "\
#:\"Somisetty\""

DEPLOYMENT += cusrule

symbian {
    TARGET.UID3 = 0x2003AFFA #0xE2EC32EA    #0x2003AFFA
    TARGET.CAPABILITY += NetworkServices
    TARGET.EPOCHEAPSIZE = 0x020000 0x2000000
    TARGET.EPOCSTACKSIZE = 0x14000
    }

DEPLOYMENT.display_name = cuteWiki
DEPLOYMENT.installer_header = 0x2002CCCF

VERSION = 2.0.0

SOURCES += main.cpp \
    smartboxhandler.cpp \
    model.cpp \
    historymodel.cpp \
    favoritesmodel.cpp
HEADERS += smartboxhandler.h \
    model.h \
    config.h \
    historymodel.h \
    favoritesmodel.h

# Please do not modify the following two lines. Required for deployment.
include(deployment.pri)
qtcAddDeployment()

OTHER_FILES += \
    ui.qml \
    KBDelegate.qml \
    CustomInput.qml \
    HMDelegate.qml \
    options.qml

RESOURCES += \
    cutewiki.qrc

QT += declarative network xml

CONFIG += qt-components


