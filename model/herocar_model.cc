#include "herocar_model.h"
#include "google/protobuf/text_format.h"
#include <cmath>
#include <fstream>
#include <iostream>
#include <sstream>

using HeroCar_VehicleType = simulator::rpc::client::HeroCar_VehicleType;
using simulator::rpc::client::HeroCar_Model_DYNAMICS;
using simulator::rpc::client::HeroCar_Model_KINEMATICS;
using simulator::rpc::client::HeroCar_Model_NO_CONTROL;
using simulator::rpc::client::HeroCar_VehicleType_EQ5;
using simulator::rpc::client::HeroCar_VehicleType_UNICORN;
using simulator::rpc::client::HeroCar_VehicleType_X3;
using simulator::rpc::client::HeroCar_VehicleType_MINI_BUS;

#define HERO_CAR_TYPE_START 101

HeroCarModel::HeroCarModel(QObject* parent) : QObject(parent) {
  routing_model_ = new RoutingModel(this);
}

HeroCarModel::HeroCarModel(int type, double x, double y, QObject* parent) : QObject(parent)
{
  type_ = type - HERO_CAR_TYPE_START;
  m_type = type;
  m_x = x;
  m_y = y;
  HeroCar_VehicleType v_type = static_cast<HeroCar_VehicleType>(m_type - HERO_CAR_TYPE_START);
  if (v_type == HeroCar_VehicleType_X3) {
    set_width(1.5);
    set_length(3.6);
    set_length_b(0.87);
    set_height(2.1);
    set_dynamic_model(HeroCar_Model_NO_CONTROL);
    set_wheelbase(1.8);
    set_ackermann_compensator_slope(0.17197);
    set_ackermann_compensator_offset(0.33737);
  }
  else if (v_type == HeroCar_VehicleType_EQ5) {
    set_width(1.910);
    set_length(4.630);
    set_length_b(4.630 / 2.0);

    set_height(1.655);
    set_dynamic_model(HeroCar_Model_NO_CONTROL);
    set_wheelbase(3.15);
  }
  else if (v_type == HeroCar_VehicleType_UNICORN) {
    set_width(1.04);
    set_length(1.885);
    set_length_b(1.885 / 2.0);
    set_height(1.4);
    set_dynamic_model(HeroCar_Model_NO_CONTROL);
    set_wheelbase(1.12);
    set_ackermann_compensator_slope(-0.18446);
    set_ackermann_compensator_offset(0.24289);
  } else if (v_type == HeroCar_VehicleType_MINI_BUS) {
    set_width(2.3);
    set_length(6.80);
    set_length_b(1.0);
    set_height(3.0);
    set_dynamic_model(HeroCar_Model_NO_CONTROL);
    set_wheelbase(4.32);
  }

  routing_model_ = new RoutingModel(this);
}

HeroCarModel::~HeroCarModel()
{
  routing_model_->deleteLater();
}

void HeroCarModel::fromProto(const HeroCar& hero_car)
{
  type_ = hero_car.vehicle_type();
  auto position = hero_car.position();
  m_x = position.x();
  m_y = position.y();
  m_z = position.z();
  m_theta = hero_car.heading();
  m_width = hero_car.width();
  m_length = hero_car.length_f() + hero_car.length_b();
  m_height = hero_car.height();
  m_speed = hero_car.speed();

  // HERO_CAR_TYPE_START is the base herocar type, x3s
  m_type = hero_car.vehicle_type() + HERO_CAR_TYPE_START;

  prediction_curve_points_.clear();
  for (auto point : hero_car.prediction_curve_points()) {
    prediction_curve_points_.push_back(QPointF(point.x(), point.y()));
  }

  if (hero_car.planning_curve_points_size() != 0) {
    routing_response_points_.clear();
    for (auto point : hero_car.planning_curve_points()) {
      routing_response_points_.push_back(QPointF(point.x(), point.y()));
    }
  }

  if (hero_car.has_routing()) {
    COWA::routing::RoutingRequest routing = hero_car.routing();
    routing_model_->fromProto(routing);
  }

  // for dynamic params
  m_dynamic_model = hero_car.model();
  m_wheelbase = hero_car.wheel_base();
  m_massf = hero_car.mass_f();
  m_massr = hero_car.mass_r();
  m_cf = hero_car.cf();
  m_cr = hero_car.cr();
  m_time_constant = hero_car.time_constant();
  m_omega = hero_car.omega();
  m_zeta = hero_car.zeta();
  m_delay = hero_car.delay();
  m_ackermann_compensator_slope = hero_car.ackermann_compensator_slope();
  m_ackermann_compensator_offset = hero_car.ackermann_compensator_offset();
}

void HeroCarModel::toProto(HeroCar* hero_car)
{
  hero_car->set_id(-1);
  // HERO_CAR_TYPE_START is the base herocar type, x3s
  hero_car->set_vehicle_type(static_cast<::simulator::rpc::client::HeroCar_VehicleType>(m_type - HERO_CAR_TYPE_START));
  auto position = hero_car->mutable_position();
  position->set_x(m_x);
  position->set_y(m_y);
  position->set_z(m_z);

  if (this->enable_routing_) {
    // if (routing_request_ != nullptr) {
    //   hero_car->mutable_routing()->CopyFrom(*routing_request_);
    //   std::string str_buffer;
    //   google::protobuf::TextFormat::PrintToString(*routing_request_, &str_buffer);
    //   std::string path = "routing_request.pb.txt";
    //   std::ofstream str_ofstream(path, std::ios::out);
    //   str_ofstream << str_buffer;
    //   str_ofstream.flush();
    //   str_ofstream.close();
    // }
      COWA::routing::RoutingRequest routing_request_;
      routing_model_->toProto(&routing_request_);
      hero_car->mutable_routing()->CopyFrom(routing_request_);
      std::string str_buffer;
      google::protobuf::TextFormat::PrintToString(routing_request_, &str_buffer);
      std::string path = "routing_request.pb.txt";
      std::ofstream str_ofstream(path, std::ios::out);
      str_ofstream << str_buffer;
      str_ofstream.flush();
      str_ofstream.close();

      std::cout << "write routing request into file " << std::endl;
      std::cout << str_buffer << std::endl;

  }

  // for dynamic params
  hero_car->set_model(static_cast<simulator::rpc::client::HeroCar_Model>(m_dynamic_model));
  hero_car->set_wheel_base(m_wheelbase);
  hero_car->set_mass_f(m_massf);
  hero_car->set_mass_r(m_massr);
  hero_car->set_cf(m_cf);
  hero_car->set_cr(m_cr);
  hero_car->set_time_constant(m_time_constant);
  hero_car->set_omega(m_omega);
  hero_car->set_zeta(m_zeta);
  hero_car->set_delay(m_delay);

  hero_car->set_speed(m_speed);
  hero_car->set_heading(m_theta);
  hero_car->set_width(m_width);
  hero_car->set_height(m_height);
  hero_car->set_length_f(m_length - m_length_b);
  hero_car->set_length_b(m_length_b);
  hero_car->set_ackermann_compensator_slope(m_ackermann_compensator_slope);
  hero_car->set_ackermann_compensator_offset(m_ackermann_compensator_offset);
}

void HeroCarModel::setTargetCurvePoints(const QVariantList& points)
{
  routing_model_->setRoutingPoints(points);
}

void HeroCarModel::addPredictionCurvePoints(const QPointF& pos)
{
  prediction_curve_points_.push_back(pos);
}

void HeroCarModel::setPredictionCurvePoints(const QVariantList& points)
{
  prediction_curve_points_.clear();
  prediction_curve_points_ = points;
}

void HeroCarModel::setRoutingResponsePoints(const QVariantList& points)
{
  routing_response_points_ = std::move(points);
}

void HeroCarModel::clearPredictionCurvePoints()
{
  prediction_curve_points_.clear();
}

QVariantList HeroCarModel::findPredictionCurvePoints()
{
  return prediction_curve_points_;
}

QVariantList HeroCarModel::findRoutingResponsePoints()
{
  return routing_response_points_;
}

void HeroCarModel::clearRoutingResponsePoints()
{
  routing_response_points_.clear();
}

QVariantList HeroCarModel::findReferencePoints()
{
  return reference_points_;
}

void HeroCarModel::setReferencePoints(const QVariantList& points)
{
  reference_points_ = std::move(points);
}

void HeroCarModel::setEnableRouting(bool enable_routing)
{
  enable_routing_ = enable_routing;
}

// void HeroCarModel::setParkingArea(double x, double y, double radius)
// {
//   parking_circle_model_->add_parking_area(x, y, radius);
// }

std::string HeroCarModel::toString()
{
  return "";
}