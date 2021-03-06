/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *  Copyright 2016 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.draganddrop 2.0 as DnD

import "items"

Item {
    id: root

    //be at least the same size as the system tray popup
    Layout.minimumWidth: units.gridUnit * 24
    Layout.minimumHeight: units.gridUnit * 21
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight * 1.5

    property Component plasmoidItemComponent

    Containment.onAppletAdded: {
        addApplet(applet);
        //when we add an applet, select it straight away
        //we know it will always be at the end of the stack
        tabbar.currentIndex = mainStack.count -1
    }
    Containment.onAppletRemoved: {
       for (var i=0; i<mainStack.count; i++) {
            if (mainStack.children[i].itemId == applet.id) {
                mainStack.children[i].destroy();
                break;
            }
       }
    }

    function addApplet(applet) {
        if (!plasmoidItemComponent) {
            plasmoidItemComponent = Qt.createComponent("items/PlasmoidItem.qml");
        }
        if (plasmoidItemComponent.status == Component.Error) {
            console.warn("Could not create PlasmoidItem", plasmoidItemComponent.errorString());
        }

        var plasmoidContainer = plasmoidItemComponent.createObject(mainStack, {"applet": applet});

        applet.parent = plasmoidContainer;
        applet.anchors.fill = plasmoidContainer;
        applet.visible = true;
    }

    Component.onCompleted: {
        var applets = Containment.applets;
        for (var i =0 ; i < applets.length; i++) {
            addApplet(applets[i]);
        }
    }

    PlasmaComponents.TabBar {
        id: tabbar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
        LayoutMirroring.childrenInherit: true

        Repeater {
            model: mainStack.children

            //attached properties:
            //  model == a QQmlDMObjectData wrapper round the PlasmoidItem
            //  modelData == the PlasmoidItem instance
            PlasmaComponents.TabButton {
                text: model.text
                MouseArea {
                    acceptedButtons: Qt.RightButton
                    anchors.fill: parent
                    onClicked: {
                        modelData.clicked(mouse);
                    }
                }
            }
        }
        //hack: PlasmaComponents.TabBar is being weird with heights. Probably a bug
        height: contentChildren[0].height || 0
    }

    StackLayout {
        id: mainStack
        currentIndex: tabbar.currentIndex
        anchors.top: tabbar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    DnD.DropArea {
        anchors.fill: parent

        preventStealing: true;

        /** Extracts the name of the applet in the drag data if present
         * otherwise returns null*/
        function appletName(event) {
            if (event.mimeData.formats.indexOf("text/x-plasmoidservicename") < 0) {
                return null;
            }
            var plasmoidId = event.mimeData.getDataAsByteArray("text/x-plasmoidservicename");
            return plasmoidId;
        }

        onDragEnter: {
            if (!appletName(event)) {
                event.ignore();
            }
        }

        onDrop: {
            var plasmoidId = appletName(event);
            if (!plasmoidId) {
                event.ignore();
                return;
            }
            plasmoid.nativeInterface.newTask(plasmoidId);
        }
    }

    PlasmaComponents.Label {
        anchors.fill: mainStack
        text: i18n("Drag applets here")
        visible: mainStack.count == 0
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
