#pragma once

#include <QObject>
#include <QQmlEngine>

#include "common/qmlutil.h"
#include "sim-proto/rpc_client.pb.h"
#include <QPointF>
#include <QVariantList>
#include <vector>
#include "routing_model.h"
#include "parking_circle_model.h"
using HeroCar = simulator::rpc::client::HeroCar;

class HeroCarModel : public QObject {
  Q_OBJECT
  PROPERTY(int, type, 0)
  PROPERTY(double, x, 0.0)
  PROPERTY(double, y, 0.0)
  PROPERTY(double, z, 0.0)
  PROPERTY(double, theta, 0.0)
  PROPERTY(double, width, 1.5)
  PROPERTY(double, length, 3.6)
  PROPERTY(double, length_b, 0.87)

  PROPERTY(double, height, 2.1)
  PROPERTY(double, speed, 0.0)  //当前速度
  PROPERTY(int, dynamic_model, 2)  // 0, 动力学 1 运动学 2 跟随规划轨迹
  PROPERTY(double, wheelbase, 3.15f)  // 轴距
  PROPERTY(double, massf, 446.05f)  // 前轴质量 kg
  PROPERTY(double, massr, 537.55f)  // 后轴质量 kg
  PROPERTY(double, cf, 171291.515f)  // 前轮侧扁刚度 N/rad
  PROPERTY(double, cr, 196394.363f)  // 后轮侧扁刚度 N/rad
  PROPERTY(double, time_constant, 0.1f)  // 一阶响应频率
  PROPERTY(double, omega, 20.0f)  // 二阶响应频率
  PROPERTY(double, zeta, 1.0f)  // 二阶响应阻尼
  PROPERTY(int, delay, 2)  // 滞后系数

  PROPERTY(double, throttle, 0.0)
  PROPERTY(double, steer, 0.0)
  PROPERTY(double, ackermann_compensator_slope, 0.0)  // 补偿系数
  PROPERTY(double, ackermann_compensator_offset, 0.0)  // 补偿偏移值

 public:
  explicit HeroCarModel(QObject* parent = 0);
  explicit HeroCarModel(int type, double x, double y, QObject* parent = 0);
  virtual ~HeroCarModel();
  HeroCarModel(const HeroCarModel& other) = default;
  HeroCarModel& operator=(const HeroCarModel& other) = default;

  int getType() const { return static_cast<int>(type_); }
  void fromProto(const HeroCar& hero_car);
  void toProto(HeroCar* hero_car);
  void setTargetCurvePoints(const QVariantList& points);
  void addPredictionCurvePoints(const QPointF& points);
  void setPredictionCurvePoints(const QVariantList& points);
  void setRoutingResponsePoints(const QVariantList& points);
  void setReferencePoints(const QVariantList& points);
  void setEnableRouting(bool enable_routing_);
  // void setParkingArea(double x, double y, double radius);
  std::string toString();

  Q_INVOKABLE QVariantList findPredictionCurvePoints();
  Q_INVOKABLE void clearPredictionCurvePoints();

  Q_INVOKABLE QVariantList findRoutingResponsePoints();
  Q_INVOKABLE void clearRoutingResponsePoints();

  Q_INVOKABLE QVariantList findReferencePoints();

  QVariantList prediction_curve_points_;  //主车预测路径轨迹
  QVariantList routing_response_points_;  //主车规划路径轨迹
  QVariantList reference_points_;  //主车规划路径轨迹
  // COWA::routing::RoutingRequest* routing_request_ = nullptr;
  bool enable_routing_ = true;  // 是否启用routing

  RoutingModel *routing_model_;

private:
  int type_;

};