#pragma once

#include "common/qmlutil.h"
#include "model/obstacle_model.h"
#include <QObject>

using ObstacleDTO = ObstacleModel;

class ObstacleEditPanelVM : public QObject {
  Q_OBJECT
  PROPERTY(QString, title, "")
  PROPERTY(int, id, -1)
  PROPERTY(double, x, 0.0)
  PROPERTY(double, y, 0.0)
  PROPERTY(double, z, 0.0)
  PROPERTY(double, speed, 0.0)
  PROPERTY(double, targetSpeed, 0.0)
  PROPERTY(double, acc, 0.0)
  PROPERTY(double, theta, 0.0)
  PROPERTY(double, length, 0.0)
  PROPERTY(double, width, 0.0)
  PROPERTY(double, height, 0.0)
  PROPERTY(int, mode, 1)
  PROPERTY(int, route, -1)
  PROPERTY(bool, visible, false);
  PROPERTY(bool, is_static, false);
  PROPERTY(int, trigger_type, 0);
  PROPERTY(double, trigger_parameter, 0);
  PROPERTY(QString, trigger_parameter_str, QString::fromStdString(""));
  PROPERTY(bool, is_disturbable, false);
  PROPERTY(float, disturbance_coefficient, 0.0f);

 public:
  explicit ObstacleEditPanelVM(QObject* parent = nullptr);

 Q_SIGNALS:
  void refreshed(int id);
  void edited();
  void focusLosed();
  void cleared();
};
