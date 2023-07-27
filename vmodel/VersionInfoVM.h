#pragma once

#include <QObject>
#include "common/qmlutil.h"

class VersionInfoVM : public QObject
{
    Q_OBJECT
    PROPERTY(QString, buildVersion, "1.0")
    PROPERTY(QString, buildTime, "")
    
public:
    explicit VersionInfoVM(QObject *parent = nullptr);
    ~VersionInfoVM();
};
