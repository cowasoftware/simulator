#include "trafficlight_model.h"
#include "client/logger.h"
#include <cmath>
#include <iostream>

using namespace simulator::rpc::client;

SubLight::SubLight(QObject* parent) : QObject(parent) {}
SubLight::SubLight(int type, QObject* parent) : QObject(parent)
{
  this->id = std::to_string(type);
  this->type = type;
  this->color = static_cast<int>(SignalState::GREEN);
  // printf("type %d color %d\n", type, color);
  this->remain_time = 50;
  this->states.push_back(static_cast<int>(SignalState::GREEN));
  this->intervals.push_back(50);
}

TrafficLightModel::TrafficLightModel(QObject* parent, bool is_crosswalk) : QObject(parent)
{
  this->is_crosswalk = is_crosswalk;
  if (is_crosswalk) {
    auto forward = new SubLight(static_cast<int>(SignalState_Direction_FORWARD), parent);
    sublights.push_back(forward);
  } else {
    auto left = new SubLight(static_cast<int>(SignalState_Direction_LEFT), parent);
    sublights.push_back(left);

    auto forward = new SubLight(static_cast<int>(SignalState_Direction_FORWARD), parent);
    sublights.push_back(forward);

    auto right = new SubLight(static_cast<int>(SignalState_Direction_RIGHT), parent);
    sublights.push_back(right);

    auto uturn = new SubLight(static_cast<int>(SignalState_Direction_UTURN), parent);
    sublights.push_back(uturn);
  }
}
TrafficLightModel::~TrafficLightModel() {}

// 同步服务端 发来的红绿灯状态
void TrafficLightModel::fromSignalState(const SignalState& signal_state)
{
  if (signal_state.subsignal_state_map_size() <= 0) { return; }
  auto m = signal_state.subsignal_state_map();
  for (int j = 0; j < sublights.size(); ++j) {
    auto it = m.find(sublights[j]->id);
    if (it != m.end()) {
      auto& substate = it->second;
      sublights[j]->color = static_cast<int>(substate.current_state());
      sublights[j]->remain_time = substate.remain_time();

      // SINFO << "sublights[j]" << sublights[j]->color << " sublights[j]->remain_time " << sublights[j]->remain_time;
    }
  }
}

void TrafficLightModel::toSignalConfig(SignalConfig* signal_config)
{
  signal_config->set_id(id.toStdString());

  if (trigger) {
    signal_config->mutable_trigger_position()->set_x(hero_car_x);
    signal_config->mutable_trigger_position()->set_y(hero_car_y);
  }

  for (auto sublight : sublights) {
    SignalConfig::SubSignalConfig subconfig;
    subconfig.set_sub_id(sublight->id);
    subconfig.set_light_type(static_cast<SignalState_Direction>(sublight->type));
    // printf("TrafficLightModel::toProto sublight type %d\n", sublight->type);
    for (auto s : sublight->states) { subconfig.add_states(static_cast<simulator::rpc::client::SignalState_State>(s)); }
    for (auto s : sublight->intervals) { subconfig.add_state_time(s); }

    signal_config->mutable_subsignal_config_map()->insert(
        google::protobuf::MapPair<std::string, SignalConfig::SubSignalConfig>(sublight->id, subconfig));
  }
}
void TrafficLightModel::fromSignalConfig(const SignalConfig& signal_config)
{
  if (signal_config.has_trigger_position()) {
    hero_car_x = signal_config.trigger_position().x();
    hero_car_y = signal_config.trigger_position().y();
    trigger = true;
  }

  for (auto& item : signal_config.subsignal_config_map()) {
    auto& sub_config = item.second;
    auto sub_id = sub_config.sub_id();
    auto light_type = sub_config.light_type();

    for (auto& sublight : sublights) {
      if (sub_id == sublight->id) {
        // 清除默认值，全量替换
        sublight->states.clear();
        sublight->intervals.clear();
        for (auto state : sub_config.states()) { sublight->states.push_back(state); }
        for (auto time : sub_config.state_time()) { sublight->intervals.push_back(time); }
      }
    }
  }
}

void TrafficLightModel::clear() {
  hero_car_x = 0;
  hero_car_y = 0;
  trigger = false;
  is_crosswalk = false;
  for (auto& sublight : sublights) {
    sublight->states.clear();
    sublight->intervals.clear();
  }
}

std::string TrafficLightModel::toString()
{
  return "";
}