#pragma once

#include <QObject>
#include <QQmlEngine>

#include "Util.h"
#include "sim-proto/hdmap.pb.h"
#include "sim-proto/hdmap_common.pb.h"
#include "sim-proto/obstacle.pb.h"
#include "sim-proto/pose.pb.h"
#include "sim-proto/rpc_client.pb.h"
#include "sim-proto/trafficlight.pb.h"

using HdMap = COWA::MapData::HdMap;
using Obstacle = COWA::NavMsg::Obstacle;
using Obstacles = COWA::NavMsg::Obstacles;

using LanePoint_Type = COWA::MapData::LanePoint_Type;
using Lane_LaneType = COWA::MapData::Lane_LaneType;
using Lane_LaneTurn = COWA::MapData::Lane_LaneTurn;
using LaneMark_Type = COWA::MapData::Lane_LaneMark_Type;
using LaneStrip_Type = COWA::MapData::LaneStrip_Type;
using Signal_Type = COWA::MapData::Signal_Type;

using ObstacleControlMode = simulator::rpc::client::ControlMode_Mode;

using ObstacleType = COWA::NavMsg::Obstacle_Type;
using GarbageType = COWA::DetectMsg::DetObject_Category;
using TrafficLight2 = COWA::NavMsg::TrafficLight2;
using TrafficLight2_State = COWA::NavMsg::TrafficLight2_State;
using TrafficLight2_Direction = COWA::NavMsg::TrafficLight2_Direction;

using Crossroad_Type = COWA::MapData::Crossroad_Type;
using Object_type = COWA::MapData::Object_Type;


class Point2D {
 public:
  explicit Point2D();
  explicit Point2D(double x, double y);
  explicit Point2D(double x, double y, LanePoint_Type type);
  virtual ~Point2D();
  Point2D(const Point2D& other) = default;
  Point2D& operator=(const Point2D& other) = default;

  double getX() const { return x_; }
  double getY() const { return y_; }
  int getType() const { return type_; }

  std::string toString();

 public:
  double x_;
  double y_;
  LanePoint_Type type_;
};

class LaneMark {
  public:
    explicit LaneMark();
    virtual ~LaneMark();
    LaneMark(const LaneMark& other) = default;
    LaneMark& operator=(const LaneMark& other) = default;

    std::string getId() const { return id; }
    int getLaneMarkType() const { return lanemark_type_; }
    const std::vector<Point2D>& getPolygon() const { return polygon; }

    std::string toString();
  
  public:
    std::string id;
    LaneMark_Type lanemark_type_;
    std::vector<Point2D> polygon;
};

class LaneStrip {
  public:
    explicit LaneStrip();
    virtual ~LaneStrip();
    LaneStrip(const LaneStrip& other) = default;
    LaneStrip& operator=(const LaneStrip& other) = default;

    std::string getId() const { return id; }
    float getStart() { return start_; }
    float getEnd() { return end_; }
    float getHeight() { return height_; }
    int getType() const { return type_; }
    std::string toString();

  public:
    std::string id;
    float start_;
    float end_;
    float height_;
    LaneStrip_Type type_;
};

class LaneLine {
 public:
  explicit LaneLine();
  virtual ~LaneLine();
  LaneLine(const LaneLine& other) = default;
  LaneLine& operator=(const LaneLine& other) = default;

  std::string getId() const { return id; }
  const std::vector<Point2D>& getLeft() const { return left; }
  // const std::vector<Point2D>& getMid() const { return mid; }
  const std::vector<Point2D>& getRight() const { return right; }

  int getLaneType() const { return lane_type; }
  bool getHasTurn() const { return has_turn; }
  int getLaneTurn() const { return lane_turn; }

  const std::vector<LaneMark>& getLaneMarkVect() const {return laneMarkVect;}

  std::string toString();

 public:
  std::string id;
  std::vector<Point2D> left;
  bool is_left_reality_line;
  // std::vector<Point2D> mid;
  std::vector<Point2D> right;
  bool is_right_reality_line;

  Lane_LaneType lane_type;
  bool has_turn;
  Lane_LaneTurn lane_turn;
  std::string display;

  std::vector<LaneMark> laneMarkVect;
};

class Signal {
 public:
  explicit Signal();
  virtual ~Signal();
  Signal(const Signal& other) = default;
  Signal& operator=(const Signal& other) = default;

  std::string getId() const { return id; }
  std::vector<Point2D> getStopLine() const { return stop_line; }

 public:
  std::string id;
  std::vector<Point2D> stop_line;
  bool has_subsignal = false;
  bool is_crosswalk = false;
};

class CrossWalk {
 public:
  explicit CrossWalk();
  virtual ~CrossWalk();
  CrossWalk(const CrossWalk& other) = default;
  CrossWalk& operator=(const CrossWalk& other) = default;

  std::string getId() const { return id; }
  std::vector<Point2D> getPolygon() const { return polygon; }

 public:
  std::string id;
  std::vector<Point2D> polygon;
};

class Ramp {
 public:
  explicit Ramp();
  virtual ~Ramp();
  Ramp(const Ramp& other) = default;
  Ramp& operator=(const Ramp& other) = default;

  std::string getId() const { return id; }
  std::vector<Point2D> getPolygon() const { return polygon; }

 public:
  std::string id;
  std::vector<Point2D> polygon;
};


class Crossroad {
  public:
    explicit Crossroad();
    virtual ~Crossroad();
    Crossroad(const Crossroad& other) = default;
    Crossroad& operator=(const Crossroad& other) = default;

    std::string getId() const { return id; }
    Crossroad_Type getType() const { return type; }
    std::vector<Point2D> getBoundary() const { return boundary; }

  public:
    std::string id;
    std::vector<Point2D> boundary;
    Crossroad_Type type;
};

class SpecialObject {
  public:
    explicit SpecialObject();
    virtual ~SpecialObject();
    SpecialObject(const SpecialObject& other) = default;
    SpecialObject& operator=(const SpecialObject& other) = default;

    std::string getId() const { return id; }
    Object_type getType() const { return type_; }
    std::vector<Point2D> getPolygon() const { return polygon; }
    std::string toString();

  public:
    std::string id;
    Object_type type_;
    std::vector<Point2D> polygon;
};

std::vector<Point2D> filterPoint(const std::vector<Point2D>& lines);

// 计算两点距离
double calculateDistance(const Point2D& p1, const Point2D& p2);