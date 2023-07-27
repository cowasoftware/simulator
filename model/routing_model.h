#pragma once

#include "qpoint.h"

#include "common/qmlutil.h"
#include "sim-proto/rpc_client.pb.h"
#include <QObject>
#include <QQmlEngine>
#include <QVariant>

enum WorkMode {
  UNKNOWN = 0,
  UNWORK = 1,
  WORKON = 2,
  TRANS = 3,
  PULLOVER = 4,
  PARKING = 5,
  STARTGO = 6,
};
enum WorkSide {
  LEFT = 1,
  RIGHT = 2,
  MIDDLE = 3,
};

class RoutingModel : public QObject {
  Q_OBJECT
  PROPERTY(int, type, 0)
  // QML_ELEMENT
 public:
  explicit RoutingModel(QObject* parent = 0) : QObject(parent) {}
  virtual ~RoutingModel() {}
  RoutingModel(const RoutingModel& other) = default;
  RoutingModel& operator=(const RoutingModel& other) = default;

  void fromProto(const COWA::routing::RoutingRequest& routing_request);
  void toProto(COWA::routing::RoutingRequest* routing_request);

 public:
  Q_INVOKABLE void setRoutingPoints(const QVariantList& line_curve);

  Q_INVOKABLE void setWorkMode(int i, int mode) { work_mode_[i] = mode; }
  Q_INVOKABLE void setWorkSide(int i, int side) { work_side_[i] = side; }

  Q_INVOKABLE int getWorkMode(int i) { return work_mode_[i]; }
  Q_INVOKABLE int getWorkSide(int i) { return work_side_[i]; }

 private:
  std::vector<double> routing_points_;
  std::vector<int> work_mode_;
  std::vector<int> work_side_;
};