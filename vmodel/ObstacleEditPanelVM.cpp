#include "ObstacleEditPanelVM.h"
#include "control/ui_scenario_control.h"
#include <cmath>

ObstacleEditPanelVM::ObstacleEditPanelVM(QObject* parent) : QObject{parent}
{
  connect(this, &ObstacleEditPanelVM::refreshed, this, [this](int id) {
    ObstacleDTO* dto = SingletonScenarioControl::getInstance()->findObstacleModel(id);

    if (dto == nullptr) { return; }

    set_id(id);
    set_x(dto->getX());
    set_y(dto->getY());
    set_z(dto->getZ());
    set_length(dto->getLength());
    set_width(dto->getWidth());
    set_height(dto->getHeight());
    set_speed(dto->getSpeed());
    set_targetSpeed(dto->getTargetSpeed());
    set_acc(dto->getAcc());
    set_theta(dto->getTheta());
    set_mode(dto->getMode());
    set_route(dto->getCurveId());
    set_is_static(dto->getIsStatic());
    set_trigger_type(dto->getTriggerType());
    set_trigger_parameter(dto->getTriggerParameter());
    set_trigger_parameter_str(dto->getTriggerParameterStr());
    set_is_disturbable(dto->getIsDisturbable());
    set_disturbance_coefficient(dto->getDisturbanceCoeffi());
  });

  connect(this, &ObstacleEditPanelVM::edited, this, [this]() {
    ObstacleDTO* dto = SingletonScenarioControl::getInstance()->findObstacleModel(get_id());

    if (dto == nullptr) { return; }

    dto->setX(get_x());
    dto->setY(get_y());
    dto->setZ(get_z());
    dto->setLength(get_length());
    dto->setWidth(get_width());
    dto->setHeight(get_height());
    dto->setSpeed(get_speed());
    dto->setTargetSpeed(get_targetSpeed());
    dto->setAcc(get_acc());
    dto->setTheta(get_theta());
    dto->setMode(get_mode());
    dto->setCurveId(get_route());
    dto->setIsStatic(get_is_static());
    dto->setTriggerType(get_trigger_type());
    dto->setTriggerParameter(get_trigger_parameter());
    dto->setTriggerParameterStr(get_trigger_parameter_str());
    dto->setIsDisturbable(get_is_disturbable());
    dto->setDisturbanceCoeffi(get_disturbance_coefficient());
    SingletonScenarioControl::getInstance()->notifyUpdateObstacle(get_id(), dto);
  });

  connect(this, &ObstacleEditPanelVM::cleared, this, [this]() {
    set_x(0);
    set_y(0);
    set_z(0);
    set_length(0);
    set_width(0);
    set_height(0);
    set_theta(0);
    set_targetSpeed(0);
    set_acc(0);
    set_mode(0);
    set_route(-1);
  });
}
