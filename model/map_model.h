#pragma once

#include <QObject>
#include <QPolygonF>
#include <QQmlEngine>
#include <mutex>

#include "common_model.h"
#include "control/simulator_client.h"

class MapModel {
 public:
  virtual void onRecvMap(std::shared_ptr<HdMap> hdmap);
  double getXmin() const { return x_min_; }
  double getXmax() const { return x_max_; }
  double getYmin() const { return y_min_; }
  double getYmax() const { return y_max_; }
  void createLaneDistanceMap(std::map<double, Point2D>& laneDistanceMap, std::vector<Point2D>& points, const Point2D& point2d);
  // 记录laneStrip
  void recordLaneStrip(std::map<double, Point2D>& laneDistanceMap, std::vector<std::vector<Point2D>>& lane_strips, const float start, const float end);

  // 地图解析出来的数据
  std::vector<LaneLine> lanes_;  // 线
  std::vector<CrossWalk> crosswalks_;  // 人行道
  std::vector<Ramp> ramps_;  // 坡道
  std::vector<Signal> signals_;  // 信号灯
  std::vector<Crossroad> crossroads_; // 十字路口
  std::vector<SpecialObject> spObjects_;  // 特殊物体
  std::vector<Object_type> objectTypes {
    Object_type::Object_Type_TREE_TRUNK,    // 圆形，树躯干
    Object_type::Object_Type_POLE,          // 圆形，电线杆、路灯杆等
    Object_type::Object_Type_PILES,         // 圆形，固定的路桩
    Object_type::Object_Type_DUSTBIN,       // 多边形，垃圾桶，果皮箱
    Object_type::Object_Type_BLOCK,         // 多边形，小型的石墩
    Object_type::Object_Type_BUILDING,      // 建筑物
    Object_type::Object_Type_CURB,          // 路牙
    Object_type::Object_Type_TREE_PIT,//树坑
    Object_type::Object_Type_WALL,//墙
  }; // 特殊物体类型集
  std::vector<std::vector<std::vector<Point2D>>> laneStripVector;

 public:
  explicit MapModel() {}
  virtual ~MapModel() {}

  void clear();  // for memory saving, after UI draw map. the data can be clear
  std::string map_name_;
  
 private:
  // 地图区域 坐标
  double x_min_ = std::numeric_limits<double>::max();
  double x_max_ = -std::numeric_limits<double>::max();
  double y_min_ = std::numeric_limits<double>::max();
  double y_max_ = -std::numeric_limits<double>::max();
  bool ready_ = false;
};
