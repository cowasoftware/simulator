#include "obstacle_model.h"

#include "logger.h"
#include <cmath>
#include <iostream>

using simulator::rpc::client::ControlMode;
using simulator::rpc::client::ControlMode_Trigger;

ObstacleModel::ObstacleModel(QObject* parent) : QObject(parent) {}
ObstacleModel::~ObstacleModel() {}

void ObstacleModel::fromProto(const ObstacleInfo& obstacle_info)
{
  auto obs = obstacle_info.obstacle();
  id_ = obs.id();
  auto pose = obs.pose();
  auto position = pose.position();
  p_x_ = position.x();
  p_y_ = position.y();
  p_z_ = position.z();
  p_heading_ = obs.theta();

  width_ = obs.width();
  length_ = obs.length();
  height_ = obs.height();
  type_ = obs.type();

  auto control_mode = obstacle_info.control_mode();
  control_mode_ = control_mode.mode();
  speed_ = control_mode.speed();
  is_disturbable_ = control_mode.disturbable();
  disturbance_coefficient_ = control_mode.disturbable_coefficient();

  switch (control_mode_) {
  case ControlMode::REPLAY: break;
  case ControlMode::STRAIGHT: {
    auto param = control_mode.param_straight();
    target_v_ = param.target_speed();
    acc_ = param.acceleration();
    trigger_type_ = param.trigger();
    trigger_parameter_ = param.parameter();
    trigger_parameter_str_ = "";
    for (int index = 0; index < param.parameter_str_size(); ++index) {
      if (index == 0) { trigger_parameter_str_ += QString::fromStdString(param.parameter_str(index)); }
      else {
        trigger_parameter_str_ += QString::fromStdString("," + param.parameter_str(index));
      }
    }
    break;
  }
  case ControlMode::KEEP_LANE: {
    auto param = control_mode.param_keep_lane();
    target_v_ = param.target_speed();
    acc_ = param.acceleration();
    trigger_type_ = param.trigger();
    trigger_parameter_ = param.parameter();
    trigger_parameter_str_ = "";
    for (int index = 0; index < param.parameter_str_size(); ++index) {
      if (index == 0) { trigger_parameter_str_ += QString::fromStdString(param.parameter_str(index)); }
      else {
        trigger_parameter_str_ += QString::fromStdString("," + param.parameter_str(index));
      }
    }
    break;
  }
  case ControlMode::REINFORCEMENT: {
    auto param = control_mode.param_rl();
    break;
  }
  case ControlMode::FOLLOW_CURVE: {
    auto param = control_mode.param_follow_curve();
    routing_points_.clear();
    for (auto point : param.curve_points()) {
      routing_points_.push_back(point.x());
      routing_points_.push_back(point.y());
    }
    speed_points_.clear();
    for (auto speed : param.speed_points()) { speed_points_.push_back(speed); }

    trigger_type_ = param.trigger();
    trigger_parameter_ = param.parameter();
    trigger_parameter_str_ = "";
    for (int index = 0; index < param.parameter_str_size(); ++index) {
      if (index == 0) { trigger_parameter_str_ += QString::fromStdString(param.parameter_str(index)); }
      else {
        trigger_parameter_str_ += QString::fromStdString("," + param.parameter_str(index));
      }
    }
    break;
  }
  case ControlMode::DEEPLEARNING: {
    auto param = control_mode.param_dl();
    target_v_ = param.target_speed();
    acc_ = param.acceleration();
    break;
  }
  case ControlMode::PNC: {
    auto param = control_mode.param_pnc();
    routing_points_.clear();
    for (auto point : param.routing_points()) {
      routing_points_.push_back(point.x());
      routing_points_.push_back(point.y());
    }
    break;
  }
  default: break;
  }
}

void ObstacleModel::toProto(ObstacleInfo* obstacle_info)
{
  auto control_mode = obstacle_info->mutable_control_mode();
  control_mode->set_mode(control_mode_);
  control_mode->set_speed(speed_);
  control_mode->set_disturbable(is_disturbable_);
  control_mode->set_disturbable_coefficient(disturbance_coefficient_);

  switch (control_mode_) {
  case ControlMode::REPLAY: break;
  case ControlMode::STRAIGHT: {
    auto param = control_mode->mutable_param_straight();
    param->set_target_speed(target_v_);
    param->set_acceleration(acc_);
    param->set_parameter(trigger_parameter_);
    auto ss = Util::Split(trigger_parameter_str_.toStdString(), ",");
    for (auto s : ss) { param->add_parameter_str(s); }
    param->set_trigger(static_cast<ControlMode_Trigger>(trigger_type_));
    break;
  }
  case ControlMode::KEEP_LANE: {
    auto param = control_mode->mutable_param_keep_lane();
    param->set_target_speed(target_v_);
    param->set_acceleration(acc_);
    param->set_parameter(trigger_parameter_);
    auto ss = Util::Split(trigger_parameter_str_.toStdString(), ",");
    for (auto s : ss) { param->add_parameter_str(s); }
    param->set_trigger(static_cast<ControlMode_Trigger>(trigger_type_));
    break;
  }
  case ControlMode::REINFORCEMENT: {
    break;
  }
  case ControlMode::FOLLOW_CURVE: {
    auto param = control_mode->mutable_param_follow_curve();
    param->clear_curve_points();
    for (auto it = routing_points_.begin(); it != routing_points_.end();) {
      auto point3d = param->add_curve_points();
      double x = *it;
      ++it;
      double y = *it;
      ++it;
      point3d->set_x(x);
      point3d->set_y(y);
      point3d->set_z(0);
    }
    param->clear_speed_points();
    if (speed_points_.empty()) {
      for (int i = 0; i < (int)routing_points_.size() / 2; ++i) { param->add_speed_points(target_v_); }
    }
    else {
      for (auto it = speed_points_.begin(); it != speed_points_.end(); ++it) { param->add_speed_points(*it); }
    }
    param->set_parameter(trigger_parameter_);
    auto ss = Util::Split(trigger_parameter_str_.toStdString(), ",");
    for (auto s : ss) { param->add_parameter_str(s); }
    param->set_trigger(static_cast<ControlMode_Trigger>(trigger_type_));
    break;
  }
  case ControlMode::DEEPLEARNING: {
    auto param = control_mode->mutable_param_dl();
    param->set_target_speed(target_v_);
    param->set_acceleration(acc_);
    break;
  }
  case ControlMode::PNC: {
    auto param = control_mode->mutable_param_pnc();
    param->clear_routing_points();
    for (auto it = routing_points_.begin(); it != routing_points_.end();) {
      auto point3d = param->add_routing_points();
      double x = *it;
      ++it;
      double y = *it;
      ++it;
      point3d->set_x(x);
      point3d->set_y(y);
      point3d->set_z(0);
    }
    break;
  }

  default: break;
  }

  auto obs = obstacle_info->mutable_obstacle();
  obs->set_id(id_);
  auto pose = obs->mutable_pose();
  auto position = pose->mutable_position();
  position->set_x(p_x_);
  position->set_y(p_y_);
  position->set_z(p_z_);
  // 转角
  obs->set_theta(p_heading_);
  obs->set_width(width_);
  obs->set_length(length_);
  obs->set_height(height_);
  obs->set_type(type_);

  obs->set_is_static(target_v_ > 0.1 ? false : true);
  auto vel_l = obs->mutable_velocity()->mutable_linear();
  vel_l->set_x(speed_ > 0.1 ? speed_ * std::cos(p_heading_) : 0);
  vel_l->set_y(speed_ > 0.1 ? speed_ * std::sin(p_heading_) : 0);
  auto point0 = obs->add_bounding_contours();
  point0->set_x(0.5 * length_ * std::cos(p_heading_) - 0.5 * width_ * std::sin(p_heading_) + p_x_);
  point0->set_y(0.5 * length_ * std::sin(p_heading_) + 0.5 * width_ * std::cos(p_heading_) + p_y_);
  point0->set_z(p_z_);
  auto point1 = obs->add_bounding_contours();
  point1->set_x(0.5 * length_ * std::cos(p_heading_) + 0.5 * width_ * std::sin(p_heading_) + p_x_);
  point1->set_y(0.5 * length_ * std::sin(p_heading_) - 0.5 * width_ * std::cos(p_heading_) + p_y_);
  point1->set_z(p_z_);
  auto point2 = obs->add_bounding_contours();
  point2->set_x(-0.5 * length_ * std::cos(p_heading_) + 0.5 * width_ * std::sin(p_heading_) + p_x_);
  point2->set_y(-0.5 * length_ * std::sin(p_heading_) - 0.5 * width_ * std::cos(p_heading_) + p_y_);
  point2->set_z(p_z_);
  auto point3 = obs->add_bounding_contours();
  point3->set_x(-0.5 * length_ * std::cos(p_heading_) - 0.5 * width_ * std::sin(p_heading_) + p_x_);
  point3->set_y(-0.5 * length_ * std::sin(p_heading_) + 0.5 * width_ * std::cos(p_heading_) + p_y_);
  point3->set_z(p_z_);
}

void ObstacleModel::updateCurveSpeedAtIndex(int index, double val)
{
  if (index < 0 || index >= (int)speed_points_.size()) { return; }
  speed_points_.at(index) = val;
  SINFO << "succeed to update obstacle speed.";
}

void ObstacleModel::addPredictionCurvePoints(QPointF points)
{
  predict_curve_points_.push_back(points);
}

QVariantList ObstacleModel::findPredictionCurvePoints()
{
  return predict_curve_points_;
}

std::string ObstacleModel::toString()
{
  return "";
}
