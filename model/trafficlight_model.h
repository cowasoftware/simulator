#pragma once

#include <QObject>
#include <QQmlEngine>

#include "common/qmlutil.h"
#include "common_model.h"
#include "sim-proto/rpc_client.pb.h"
#include <QPointF>
#include <QVariantList>
#include <vector>

using SignalConfig = simulator::rpc::client::SignalConfig;
using SignalState = simulator::rpc::client::SignalState;

class SubLight : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString id READ getId)
  Q_PROPERTY(int type READ getType)
  Q_PROPERTY(int color READ getColor)
  Q_PROPERTY(int remain_time READ getRemainTime)
  Q_PROPERTY(QList<int> states READ getStates)
  Q_PROPERTY(QList<int> intervals READ getInterval)
 public:
  explicit SubLight(QObject* parent = 0);
  explicit SubLight(int type, QObject* parent = 0);
  QString getId() { return QString::fromStdString(id); }
  int getType()
  {
    // printf("type %d \n", type);
    return type;
  };
  int getColor() { return color; };
  int getRemainTime() { return remain_time; };

  QList<int> getStates() { return states; };
  QList<int> getInterval() { return intervals; };

 public:
  std::string id;
  int type;
  int color;
  int remain_time;

  QList<int> states;
  QList<int> intervals;
};

class TrafficLightModel : public QObject {
  Q_OBJECT
 public:
  // align define in proto TrafficLight2
  enum Type { FORWARD = 1, LEFT = 2, RIGHT = 3, UTURN = 4 };
  enum Color {
    GREEN = 1,
    RED = 2,
    YELLOW = 3,
    UNKNOWN = 4,
    BLACK = 5,
  };
  Q_ENUMS(Type)
  Q_ENUMS(Color)
  Q_PROPERTY(QList<Point2D*> stopline READ getStopLine)
  Q_PROPERTY(QList<SubLight*> sublights READ getSUbLights)
  Q_PROPERTY(QString id READ getId)
  Q_PROPERTY(double x READ getX)
  Q_PROPERTY(double y READ getY)

 public:
  explicit TrafficLightModel(QObject* parent = 0, bool is_crosswalk = false);
  virtual ~TrafficLightModel();
  TrafficLightModel(const TrafficLightModel& other) = default;
  TrafficLightModel& operator=(const TrafficLightModel& other) = default;

  void fromSignalState(const SignalState& signal_state);
  void toSignalConfig(SignalConfig* signal_config);
  void fromSignalConfig(const SignalConfig& signal_config);
  void clear();


  std::string toString();

  QList<Point2D*> getStopLine() const { return stopline; }
  QList<SubLight*> getSUbLights() const { return sublights; }
  QString getId() { return id; };
  double getX() { return x; };
  double getY() { return y; };

 public:
  QList<Point2D*> stopline;  // unused
  QList<SubLight*> sublights;
  QString id;
  double x;
  double y;

  bool trigger = false;
  double hero_car_x = 0;
  double hero_car_y = 0;
  bool is_crosswalk = false;
};