#include "VersionInfoVM.h"
#include "Util.h"


VersionInfoVM::VersionInfoVM(QObject* parent) : QObject{parent}
{
    set_buildVersion(QString::fromStdString(Util::GetBuildVersion()));
    set_buildTime(QString::fromStdString(Util::GetBuildTime()));
}

VersionInfoVM::~VersionInfoVM()
{
}