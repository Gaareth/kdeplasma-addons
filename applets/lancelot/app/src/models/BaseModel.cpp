/*
 *   Copyright (C) 2007 Ivan Cukic <ivan.cukic+kde@gmail.com>
 *   Copyright (C) 2007 Robert Knight <robertknight@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "BaseModel.h"
#include <QFileInfo>

#include <KRun>
#include <KLocalizedString>
#include <KDesktopFile>
#include <KIcon>
#include <KGlobal>
#include <KMimeType>
#include <KUrl>
#include <KDebug>

#include "logger/Logger.h"

namespace Models {

ApplicationConnector * ApplicationConnector::m_instance = NULL;

ApplicationConnector * ApplicationConnector::instance()
{
    if (m_instance == NULL) {
        m_instance = new ApplicationConnector();
    }
    return m_instance;
}

void ApplicationConnector::search(const QString & search)
{
    emit doSearch(search);
}

bool ApplicationConnector::hide(bool immediate)
{
    return emit doHide(immediate);
}

ApplicationConnector::ApplicationConnector()
{

}

ApplicationConnector::~ApplicationConnector()
{

}


BaseModel::BaseModel(bool enableDefaultDnD)
    : m_enableDefaultDnD(enableDefaultDnD)
{
}

BaseModel::~BaseModel()
{
}

void BaseModel::activate(int index)
{
    QString data = itemAt(index).data.toString();

    Logger::instance()->log("base-model", data);
    new KRun(KUrl(data), 0);
    hideLancelotWindow();
}

void BaseModel::hideLancelotWindow()
{
    ApplicationConnector::instance()->hide(true);
}

void BaseModel::changeLancelotSearchString(const QString & string)
{
    ApplicationConnector::instance()->search(string);
}

int BaseModel::addServices(const QStringList & serviceNames)
{
    int result = 0;
    foreach (const QString & serviceAlternatives, serviceNames) {
        foreach (const QString & serviceName, serviceAlternatives.split('|')) {
            if (addService(serviceName)) {
                ++result;
                break;
            }
        }
    }
    return result;
}

bool BaseModel::addService(const QString & serviceName)
{
    const KService::Ptr service = KService::serviceByStorageId(serviceName);
    return addService(service);
}

bool BaseModel::addService(const KService::Ptr & service)
{
    if (!service) {
        return false;
    }

    QString genericName = service->genericName();
    QString appName = service->name();

    add(
        genericName.isEmpty() ? appName : genericName,
        genericName.isEmpty() ? "" : appName,
        KIcon(service->icon()),
        service->entryPath()
    );
    return true;
}

int BaseModel::addUrls(const QStringList & urls)
{
    int result = 0;
    foreach (const QString & url, urls) {
        if (addUrl(url)) {
            ++result;
        }
    }
    return result;
}

bool BaseModel::addUrl(const QString & url)
{
    const KUrl kurl(url);
    return addUrl(kurl);
}

bool BaseModel::addUrl(const KUrl & url)
{
    if (url.isLocalFile() && QFileInfo(url.path()).suffix() == "desktop") {
        // .desktop files may be services (type field == 'Application' or 'Service')
        // or they may be other types such as links.
        //
        // first look in the KDE service database to see if this file is a service,
        // otherwise represent it as a generic .desktop file

        KDesktopFile desktopFile(url.path());

        if ((desktopFile.readType() == "Service" || desktopFile.readType() == "Application")
                && addService(url.path())) {
            return true;
        }

        KUrl desktopUrl(desktopFile.readUrl());

        add(
            QFileInfo(url.path()).baseName(),
            desktopUrl.isLocalFile() ? desktopUrl.path() : desktopUrl.prettyUrl(),
            KIcon(desktopFile.readIcon()),
            // url.path() //desktopFile.readUrl()
            url.url()
        );
    } else {
        add(
            QFileInfo(url.path()).baseName(),
            url.isLocalFile() ? url.path() : url.prettyUrl(),
            KIcon(KMimeType::iconNameForUrl(url)),
            url.url()
        );
    }

    return true;
}

QMimeData * BaseModel::mimeForUrl(const KUrl & url)
{
    QMimeData * data = new QMimeData();
    kDebug() << url.url();
    data->setData("text/uri-list", url.url().toAscii());
    data->setData("text/plain", url.url().toAscii());
    return data;
}

QMimeData * BaseModel::mimeData(int index) const
{
    if (!m_enableDefaultDnD) {
        kDebug() << "Requested mime for index" << index
            << "but we don't support DnD";
        return NULL;
    }

    kDebug() << "Requested mime for index" << index;
    return BaseModel::mimeForUrl(itemAt(index).data.toString());
}

void BaseModel::setDropActions(int index,
            Qt::DropActions & actions, Qt::DropAction & defaultAction)
{
    Q_UNUSED(index);
    actions = Qt::CopyAction;
    defaultAction = Qt::CopyAction;
}


QMimeData * BaseModel::mimeForUrl(const QString & url)
{
    return mimeForUrl(KUrl(url));
}

QMimeData * BaseModel::mimeForService(const KService::Ptr & service)
{
    if (!service) return NULL;

    return mimeForUrl(service->entryPath());
}

QMimeData * BaseModel::mimeForService(const QString & serviceName)
{
    const KService::Ptr service = KService::serviceByStorageId(serviceName);
    return mimeForService(service);
}

} // namespace Models
