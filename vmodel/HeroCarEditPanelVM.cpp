#include "HeroCarEditPanelVM.h"
#include "control/ui_scenario_control.h"
#include <cmath>

HeroCarEditPanelVM::HeroCarEditPanelVM(QObject* parent) : QObject{parent}
{
  connect(this, &HeroCarEditPanelVM::refreshed, this, [this]() {
    HeroCarDTO* dto = SingletonScenarioControl::getInstance()->findHeroCarModel();

    if (dto == nullptr) { return; }
    set_x(dto->get_x());
    set_y(dto->get_y());
    set_z(dto->get_z());
    set_length(dto->get_length());
    set_width(dto->get_width());
    set_height(dto->get_height());
    set_speed(dto->get_speed());
    set_theta(dto->get_theta());

    set_dynamic_model(dto->get_dynamic_model());
    set_wheelbase(dto->get_wheelbase());
    set_massf(dto->get_massf());
    set_massr(dto->get_massr());
    set_cf(dto->get_cf());
    set_cr(dto->get_cr());
    set_omega1st(dto->get_time_constant());
    set_omega2ed(dto->get_omega());
    set_zeta(dto->get_zeta());
    set_delay(dto->get_delay());

    set_throttle(dto->get_throttle());
    set_steer(dto->get_steer());
    set_ackermann_compensator_slope(dto->get_ackermann_compensator_slope());
    set_ackermann_compensator_offset(dto->get_ackermann_compensator_offset());
    set_enable_routing(dto->enable_routing_);
  });

  connect(this, &HeroCarEditPanelVM::edited, this, [this]() {
    HeroCarDTO* dto = SingletonScenarioControl::getInstance()->findHeroCarModel();

    if (dto == nullptr) { return; }

    dto->set_x(get_x());
    dto->set_y(get_y());
    dto->set_z(get_z());
    dto->set_length(get_length());
    dto->set_width(get_width());

    dto->set_height(get_height());
    dto->set_speed(get_speed());
    dto->set_theta(get_theta());

    dto->set_dynamic_model(get_dynamic_model());
    dto->set_wheelbase(get_wheelbase());
    dto->set_massf(get_massf());
    dto->set_massr(get_massr());
    dto->set_cf(get_cf());
    dto->set_cr(get_cr());
    dto->set_time_constant(get_omega1st());
    dto->set_omega(get_omega2ed());
    dto->set_zeta(get_zeta());
    dto->set_delay(get_delay());
    dto->set_ackermann_compensator_slope(get_ackermann_compensator_slope());
    dto->set_ackermann_compensator_offset(get_ackermann_compensator_offset());
    dto->enable_routing_ = get_enable_routing();
    SingletonScenarioControl::getInstance()->notifyUpdateHeroCar(dto);
  });

  connect(this, &HeroCarEditPanelVM::cleared, this, [this]() {
    set_x(0);
    set_y(0);
    set_z(0);
    set_length(0);
    set_width(0);
    set_height(0);
    set_theta(0);
    // TODO 
    set_ackermann_compensator_slope(0);
    set_ackermann_compensator_offset(0);
  });
}
