#pragma once

#include <QObject>
#include <QQmlEngine>

#include "common_model.h"
#include "qpoint.h"
#include "sim-proto/rpc_client.pb.h"

using ObstacleInfo = simulator::rpc::client::ObstacleInfo;

class ObstacleModel : public QObject {
  Q_OBJECT
  Q_PROPERTY(int id READ getId)
  Q_PROPERTY(double x READ getX WRITE setX NOTIFY xChanged)
  Q_PROPERTY(double y READ getY WRITE setY NOTIFY yChanged)
  Q_PROPERTY(double z READ getZ WRITE setZ NOTIFY zChanged)
  Q_PROPERTY(double theta READ getTheta WRITE setTheta NOTIFY thetaChanged)
  Q_PROPERTY(double width READ getWidth WRITE setWidth NOTIFY widthChanged)
  Q_PROPERTY(double length READ getLength WRITE setLength NOTIFY lengthChanged)
  Q_PROPERTY(double height READ getHeight WRITE setHeight NOTIFY heightChanged)
  Q_PROPERTY(double speed READ getSpeed WRITE setSpeed NOTIFY speedChanged)
  Q_PROPERTY(int mode READ getMode WRITE setMode)
  Q_PROPERTY(int type READ getType WRITE setType)
  Q_PROPERTY(double targetSpeed READ getTargetSpeed WRITE setTargetSpeed NOTIFY targetSpeedChanged)
  Q_PROPERTY(double acc READ getAcc WRITE setAcc NOTIFY accChanged)
  Q_PROPERTY(int curve_id READ getCurveId WRITE setCurveId)
  Q_PROPERTY(bool is_static READ getIsStatic WRITE setIsStatic)
  Q_PROPERTY(int trigger_type_ READ getTriggerType WRITE setTriggerType)
  Q_PROPERTY(double trigger_parameter READ getTriggerParameter WRITE setTriggerParameter)
  Q_PROPERTY(QString trigger_parameter_str READ getTriggerParameterStr WRITE setTriggerParameterStr)
  Q_PROPERTY(bool is_disturbable READ getIsDisturbable WRITE setIsDisturbable);
  Q_PROPERTY(float disturbance_coefficient READ getDisturbanceCoeffi WRITE setDisturbanceCoeffi);
  Q_PROPERTY(bool visible READ getVisible WRITE setVisible);

 public:
  explicit ObstacleModel(QObject* parent = 0);
  virtual ~ObstacleModel();
  ObstacleModel(const ObstacleModel& other) = default;
  ObstacleModel& operator=(const ObstacleModel& other) = default;

  void fromProto(const ObstacleInfo& obstacle_info);
  void toProto(ObstacleInfo* obstacle_info);
  std::string toString();

  int getId() const { return id_; }
  void setId(int id) { id_ = id; }
  double getX() const { return p_x_; }
  void setX(double x)
  {
    if (p_x_ != x) {
      p_x_ = x;
      Q_EMIT xChanged();
    }
  }
  double getY() const { return p_y_; }
  void setY(double y)
  {
    if (p_y_ != y) {
      p_y_ = y;
      Q_EMIT yChanged();
    }
  }
  double getZ() const { return p_z_; }
  void setZ(double z)
  {
    if (p_z_ != z) {
      p_z_ = z;
      Q_EMIT zChanged();
    }
  }
  double getTheta() const { return p_heading_; }
  void setTheta(double theta)
  {
    if (p_heading_ != theta) {
      p_heading_ = theta;
      Q_EMIT thetaChanged();
    }
  }
  double getWidth() const { return width_; }
  void setWidth(double width)
  {
    if (width_ != width) {
      width_ = width;
      Q_EMIT widthChanged(width);
    }
  }

  double getLength() const { return length_; }
  void setLength(double length)
  {
    if (length_ != length) {
      length_ = length;
      Q_EMIT lengthChanged();
    }
  }
  double getHeight() const { return height_; }
  void setHeight(double height)
  {
    if (height_ != height) {
      height_ = height;
      Q_EMIT heightChanged();
    }
  }
  double getSpeed() const { return speed_; }
  void setSpeed(double v)
  {
    if (speed_ != v) {
      speed_ = v;
      Q_EMIT speedChanged();
    }
  }
  int getMode() const { return static_cast<int>(control_mode_); }
  void setMode(int mode) { control_mode_ = static_cast<ObstacleControlMode>(mode); }
  int getType() const { return static_cast<int>(type_); }
  void setType(int type) { type_ = static_cast<ObstacleType>(type); }
  double getTargetSpeed() const { return target_v_; }
  void setTargetSpeed(double speed)
  {
    if (target_v_ != speed) {
      target_v_ = speed;
      Q_EMIT targetSpeedChanged();
    }
  }
  double getAcc() const { return acc_; }
  void setAcc(double acc)
  {
    if (acc_ != acc) {
      acc_ = acc;
      Q_EMIT accChanged();
    }
  }

  int getCurveId() const { return curve_id_; }
  void setCurveId(int id) { curve_id_ = id; }

  bool getIsStatic() const { return static_; }
  void setIsStatic(bool isStatic) { static_ = isStatic; }

  bool getIsDisturbable() const { return is_disturbable_; }
  void setIsDisturbable(bool isDisturbable) { is_disturbable_ = isDisturbable; }

  float getDisturbanceCoeffi() const { return disturbance_coefficient_; }
  void setDisturbanceCoeffi(float disturbance_coefficient) { disturbance_coefficient_ = disturbance_coefficient; }

  bool getVisible() const { return visible_; }
  void setVisible(bool visible) { visible_ = visible; }

  void setCurvePoints(QVariantList points, QVariantList speeds)
  {
    routing_points_.clear();
    for (auto it = points.begin(); it != points.end(); ++it) {
      routing_points_.emplace_back(it->toPointF().x());
      routing_points_.emplace_back(it->toPointF().y());
    }
  
    speed_points_.clear();
    for (auto it = speeds.begin(); it != speeds.end(); ++it) { speed_points_.emplace_back(it->toDouble()); }
  }

  // 更新障碍物index位置上的速度
  void updateCurveSpeedAtIndex(int index, double val);

  int getTriggerType() const { return trigger_type_; }
  void setTriggerType(int type) { trigger_type_ = type; }
  double getTriggerParameter() const { return trigger_parameter_; }
  void setTriggerParameter(double param) { trigger_parameter_ = param; }

  QString getTriggerParameterStr() const { return trigger_parameter_str_; }
  void setTriggerParameterStr(QString param) { trigger_parameter_str_ = param; }

  void addPredictionCurvePoints(QPointF points);

  Q_INVOKABLE QVariantList findPredictionCurvePoints();

 public:
 Q_SIGNALS:
  void xChanged();
  void yChanged();
  void zChanged();
  void thetaChanged();
  void widthChanged(double width);
  void lengthChanged();
  void heightChanged();
  void speedChanged();
  void targetSpeedChanged();
  void accChanged();

 public:
  QVariantList predict_curve_points_;  //　障碍物预测路径轨迹

 private:
  int id_;
  double p_x_ = 0.0f;
  double p_y_ = 0.0f;
  double p_z_ = 0.0f;
  double p_heading_ = 0.0f;

  double width_ = 1.0f;
  double length_ = 1.0f;
  double height_ = 1.0f;
  double speed_ = 0;  //当前速度

  ObstacleControlMode control_mode_;  // 控制策略, 由仿真算法定义, 客户端选择
  ObstacleType type_;  // 障碍物类型, 由proto定义
  double target_v_ = 0.0;  // 目标速度
  double acc_ = 0.0;  // 加速度
  bool static_ = false;  // 是否是静止物体

  int curve_id_ = -1;  // 运动轨迹ID
  std::vector<double> routing_points_;  // 运动轨迹
  std::vector<double> speed_points_;  // 运动速度
  int trigger_type_ = 0;
  double trigger_parameter_ = 0;
  QString trigger_parameter_str_;
  bool is_disturbable_ = false;
  float disturbance_coefficient_ = 0.5f;
  bool visible_ = true;
};
