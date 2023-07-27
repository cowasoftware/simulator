#pragma once

#include "common/qmlutil.h"
#include "model/herocar_model.h"
#include <QObject>

using HeroCarDTO = HeroCarModel;

class HeroCarEditPanelVM : public QObject {
  Q_OBJECT
  PROPERTY(QString, title, "")
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

  PROPERTY(int, dynamic_model, 2)
  PROPERTY(double, wheelbase, 0.0)
  PROPERTY(double, massf, 0.0)
  PROPERTY(double, massr, 0.0)
  PROPERTY(double, cf, 0.0)
  PROPERTY(double, cr, 0.0)
  PROPERTY(double, omega1st, 0.0)
  PROPERTY(double, omega2ed, 0.0)
  PROPERTY(double, zeta, 0.0)
  PROPERTY(int, delay, 0.0)

  PROPERTY(bool, visible, false)

  PROPERTY(double, throttle, 0.0)
  PROPERTY(double, steer, 0.0)
  // TODO
  PROPERTY(double, ackermann_compensator_slope, 0.0)
  PROPERTY(double, ackermann_compensator_offset, 0.0)
  PROPERTY(bool, enable_routing, true)

 public:
  explicit HeroCarEditPanelVM(QObject* parent = nullptr);

 Q_SIGNALS:
  void refreshed();
  void edited();
  void focusLosed();
  void cleared();
};
