/*****************************************************************************
*   Copyright (C) 2011, 2012 by Shaun Reich <shaun.reich@kdemail.net>        *
*                                                                            *
*   This program is free software; you can redistribute it and/or            *
*   modify it under the terms of the GNU General Public License as           *
*   published by the Free Software Foundation; either version 2 of           *
*   the License, or (at your option) any later version.                      *
*                                                                            *
*   This program is distributed in the hope that it will be useful,          *
*   but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *
*   GNU General Public License for more details.                             *
*                                                                            *
*   You should have received a copy of the GNU General Public License        *
*   along with this program.  If not, see <http://www.gnu.org/licenses/>.    *
*****************************************************************************/

import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.components 0.1 as PlasmaComponents

Item {
   id: konsoleProfiles

    property int minimumWidth: 200
    property int minimumHeight: 300

    PlasmaCore.DataSource {
        id: profilesSource
        engine: "org.kde.konsoleprofiles"
        onSourceAdded: connectSource(source)
        onSourceRemoved: disconnectSource(source)

        Component.onCompleted: connectedSources = sources
    }

    PlasmaCore.DataModel {
        id: profilesModel
        dataSource: profilesSource
    }

    Component.onCompleted: {
        plasmoid.popupIcon = "utilities-terminal";
        plasmoid.aspectRatioMode = IgnoreAspectRatio;
    }


   PlasmaCore.Svg {
       id: lineSvg
       imagePath: "widgets/line"
    }


    Column {
        width: parent.width
        height: parent.height

  //      Row {
   //         id: searchRow

    //        width: parent.width

//        }


            PlasmaCore.SvgItem {
                id: separator

                anchors { left: parent.left; right: parent.right } //top: header.bottom;  }
//                anchors { topMargin: 3 }

                svg: lineSvg
                elementId: "horizontal-line"
                height: lineSvg.elementSize("horizontal-line").height
            }

        //Row {
        //    id: searchRow
        //
        //    width: parent.width
        //
        //    PlasmaComponents.TextField {
        //        id: searchBox
        //
        //        clearButtonShown: true
        //        placeholderText: i18n("Type a word...")
        //        width: parent.width // - icon.width - parent.spacing
        //
        //        onTextChanged: {
        //            timer.running = true
        //            mainWindow.listdictionaries = false
        //        }
        //    }
        //}

        //we use this to compute a fixed height for the items, and also to implement
        //the said constant below (itemHeight)
        Text {
            id: textMetric
            visible: false
            // i think this should indeed technically be translated, even though we won't ever use it, just
            // its height/width
            text: i18n("Arbitrary String Which Says The Dictionary Type")
        }

        Flickable {
            id: flickable

            width: parent.width
            height: parent.height
            //FIXME:            contentHeight: mainWindow.listdictionaries ? 0 : textBrowser.paintedHeight
            clip: true

            ListView {
                id: view

                anchors.fill: parent
                anchors.topMargin: 20

                model: profilesModel
                spacing: 15

                delegate: Item {
                    id: listdelegate
                    height: textMetric.paintedHeight
                    anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }

                    Text {
                        id: text
                        anchors.fill: parent
                        //anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter }
                       text: "TEST" //model.name + " - " + model.description
                    }

                    MouseArea {
                        height: parent.height + 15
                        anchors { left: parent.left; right: parent.right;}
                        hoverEnabled: true

                        onClicked: {
                            console.log("CLICKED: " + model.name)
                        }

                        onEntered: {
                            view.currentIndex = index
                            view.highlightItem.opacity = 1
                        }

                        onExited: {
                            view.highlightItem.opacity = 0
                        }
                    }
                }

                highlight: PlasmaComponents.Highlight {
                    anchors { left: parent.left; right: parent.right; leftMargin: 10; rightMargin: 10 }
                    height: textMetric.paintedHeight
                    hover: true;
                }

                highlightMoveDuration: 250
                highlightMoveSpeed: 1
            }
        }

        PlasmaComponents.ScrollBar {
            id: scrollBar

            anchors { bottom: parent.bottom }

            orientation: Qt.Vertical
            stepSize: 40 // textBrowser.lineCount / 4
            scrollButtonInterval: 40 //textBrowser.lineCount / 4

            flickableItem: flickable
        }
    }

//    property int itemHeight: heightMetric.height * 2
}
