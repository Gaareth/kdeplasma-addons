#ifndef KDEOBSERVATORY_HEADER
#define KDEOBSERVATORY_HEADER

#include <KConfigGroup>

#include <Plasma/Applet>

class QTimer;
class QGraphicsProxyWidget;
class QGraphicsLinearLayout;

class KdeObservatoryConfigGeneral;
class KdeObservatoryConfigProjects;
class KdeObservatoryConfigTopActiveProjects;
class CommitCollector;

namespace Plasma
{
    class Label;
    class PushButton;
}

namespace Ui
{
    class KdeObservatoryConfigTopActiveProjects;
}

class KdeObservatory : public Plasma::Applet
{
    Q_OBJECT
public:
    KdeObservatory(QObject *parent, const QVariantList &args);
    ~KdeObservatory();

    void init();

    struct Project
    {
        QString commitSubject;
        QString icon;
    };

protected Q_SLOTS:
    void createConfigurationInterface(KConfigDialog *parent);
    void configAccepted();
    void collectFinished();
    void moveViewRight();
    void moveViewLeft();
    void switchViews(int delta);
    void runCollectors();

private:
    KConfigGroup m_configGroup;

    KdeObservatoryConfigGeneral *m_configGeneral;
    KdeObservatoryConfigProjects *m_configProjects;
    KdeObservatoryConfigTopActiveProjects *m_configTopActiveProjects;

    // Config - General
    int  m_commitExtent;
    int  m_synchronizationDelay;
    bool m_cacheContents;
    bool m_enableAnimations;
    bool m_enableTransitionEffects;
    bool m_enableAutoViewChange;
    int  m_viewsDelay;
    QList< QPair<QString, bool> > m_activeViews;

    // Config - Projects
    QMap<QString, Project> m_projects;

    // Config - Top Active Projects
    QHash<QString, bool> m_topActiveProjectsViews;

    // Main Layout
    QGraphicsLinearLayout *m_horizontalLayout;
    QGraphicsWidget *m_viewContainer;
    QGraphicsProxyWidget *m_progressProxy;
    Plasma::Label *m_updateLabel;
    Plasma::PushButton *m_right;
    Plasma::PushButton *m_left;

    QList<QGraphicsWidget *> m_views;
    int m_currentView;

    QTimer *m_viewTransitionTimer;
    QTimer *m_synchronizationTimer;

    CommitCollector *m_collector;
};

#endif
