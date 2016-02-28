/*
 * Copyright 2012  Luís Gabriel Lima <lampih@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

PlasmaCore.FrameSvgItem {
    property variant model

    imagePath: "widgets/frame"
    prefix: "plain"
    visible: !!model.location

    PlasmaCore.IconItem {
        source: model.conditionIcon
        height: parent.height
        width: height
    }

    PlasmaExtras.Heading {
        id: locationLabel
        anchors {
            top: parent.top
            left: parent.left
            right: tempLabel.visible ? forecastTempsLabel.left : parent.right
            topMargin: units.smallSpacing
            leftMargin: parent.width * 0.21
        }
        font {
            bold: true
            pointSize: theme.defaultFont.pointSize * 1.4
        }
        text: model.location
        elide: Text.ElideRight
    }

    PlasmaComponents.Label {
        id: conditionLabel
        anchors {
            top: parent.top
            left: locationLabel.left
            topMargin: parent.height * 0.6
        }
        text: model.conditions
    }

    PlasmaComponents.Label {
        id: tempLabel
        anchors {
            right: parent.right
            top: locationLabel.top
            rightMargin: units.smallSpacing
        }
        font: locationLabel.font
        text: model.temp
    }

    PlasmaComponents.Label {
        id: forecastTempsLabel
        anchors {
            right: tempLabel.right
            top: conditionLabel.top
        }
        font.pointSize: theme.smallestFont.pointSize
        text: model.forecastTemps
    }
}
