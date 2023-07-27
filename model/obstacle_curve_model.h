#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QVariant>

#include "common_model.h"

class ObstacleCurveModel : public QObject {
  Q_OBJECT
  Q_PROPERTY(int id READ getId)
  Q_PROPERTY(QVariantList line_curve READ getCurve WRITE setCurve)
  Q_PROPERTY(QVariantList speeds READ getSpeeds WRITE setSpeeds)
 public:


 public:
  explicit ObstacleCurveModel(QObject* parent = 0) : QObject(parent) {}
  virtual ~ObstacleCurveModel() {}

  int getId() {
    return id_;
  }
  Q_INVOKABLE QVariantList getCurve() { return line_curve_; }
  Q_INVOKABLE QVariantList getSpeeds() { return speeds_; }
  void setCurve(const QVariantList& line_curve) { line_curve_ = line_curve; }
  void setSpeeds(const QVariantList& speeds) { speeds_ = speeds; }
  Q_INVOKABLE void updateSpeed(int index, double speed) {
    speeds_.replace(index, speed);
  }

 public:
  int id_;
  QVariantList line_curve_;
  QVariantList speeds_;
};
