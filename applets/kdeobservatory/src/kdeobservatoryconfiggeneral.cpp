/*************************************************************************
 * Copyright 2009 Sandro Andrade sandroandrade@kde.org                   *
 *                                                                       *
 * This program is free software; you can redistribute it and/or         *
 * modify it under the terms of the GNU General Public License as        *
 * published by the Free Software Foundation; either version 2 of        *
 * the License or (at your option) version 3 or any later version        *
 * accepted by the membership of KDE e.V. (or its successor approved     *
 * by the membership of KDE e.V.), which shall act as a proxy            *
 * defined in Section 14 of version 3 of the license.                    *
 *                                                                       *
 * This program is distributed in the hope that it will be useful,       *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 * GNU General Public License for more details.                          *
 *                                                                       *
 * You should have received a copy of the GNU General Public License     *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>. *
 * ***********************************************************************/

#include "kdeobservatoryconfiggeneral.h"

KdeObservatoryConfigGeneral::KdeObservatoryConfigGeneral(QWidget *parent, Qt::WindowFlags f)
: QWidget(parent, f)
{
    setupUi(this);
}

KdeObservatoryConfigGeneral::~KdeObservatoryConfigGeneral()
{
}

void KdeObservatoryConfigGeneral::on_tlbUp_clicked()
{
    swapViewItems(-1);
}

void KdeObservatoryConfigGeneral::on_tlbDown_clicked()
{
    swapViewItems(1);
}

void KdeObservatoryConfigGeneral::swapViewItems(int updown)
{
    int linenumber = activeViews->currentRow();

    if (linenumber + updown < activeViews->count())
    {
        QListWidgetItem *item = activeViews->currentItem();
        activeViews->takeItem(linenumber);
        activeViews->insertItem(linenumber + updown, item);
        activeViews->setCurrentItem(item);
    }
}
