
#include "map_model.h"

#include "client/logger.h"
#include <cmath>
#include <set>
#include <iostream>
#include <sstream>

void MapModel::clear()
{
  lanes_.clear();
  crosswalks_.clear();
  ramps_.clear();
  signals_.clear();
  laneStripVector.clear();
  crossroads_.clear();
  spObjects_.clear();

  x_min_ = std::numeric_limits<double>::max();
  x_max_ = -std::numeric_limits<double>::max();
  y_min_ = std::numeric_limits<double>::max();
  y_max_ = -std::numeric_limits<double>::max();
}

void MapModel::onRecvMap(std::shared_ptr<HdMap> hdmap)
{
  if (hdmap == nullptr) { return; }
  SINFO << "MapModel::onRecvMap ";
  // hdmap_ = hdmap;

  clear();

  std::unordered_map<std::string, COWA::MapData::LaneCurve> id_curves;
  std::unordered_map<std::string, std::vector<Point2D>> id_lines;
  std::unordered_map<std::string, int> lane_curve_types;
  for (auto cowa_lane_curve : hdmap->lane_curve()) {
    std::vector<Point2D> line;
    for (auto& point : cowa_lane_curve.point()) {
      auto x = cowa_lane_curve.offset_x() + point.x();
      auto y = cowa_lane_curve.offset_y() + point.y();
      Point2D point2d(x, y, point.type());
      x_min_ = std::min(x, x_min_);
      x_max_ = std::max(x, x_max_);
      y_min_ = std::min(y, y_min_);
      y_max_ = std::max(y, y_max_);

      line.emplace_back(point2d);
    }

    // 过滤多余的点
    std::vector<Point2D> strip_line = std::move(filterPoint(line));
    std::map<double, Point2D> laneDistanceMap;  // 车道上每个点距离车道原点距离的map

    Point2D point0(cowa_lane_curve.offset_x(), cowa_lane_curve.offset_y());
    std::vector<std::vector<Point2D>> lane_strip_each_curve;
    createLaneDistanceMap(laneDistanceMap, line, point0);
    for (auto cowa_lane_strip : cowa_lane_curve.strip()) {
      // LaneStrip lane_strip;
      // lane_strip.start_ = cowa_lane_strip.start_s();
      // lane_strip.end_ = cowa_lane_strip.end_s();
      // lane_strip.height_ = cowa_lane_strip.height();
      // lane_strip.type_ = cowa_lane_strip.type();
      recordLaneStrip(laneDistanceMap, lane_strip_each_curve, cowa_lane_strip.start_s(), cowa_lane_strip.end_s());
    }
    laneStripVector.push_back(lane_strip_each_curve);

    if (cowa_lane_curve.has_id()) {
      id_curves.emplace(cowa_lane_curve.id().id(), cowa_lane_curve);
      id_lines.emplace(cowa_lane_curve.id().id(), strip_line);
      lane_curve_types.emplace(cowa_lane_curve.id().id(), (int)(cowa_lane_curve.type()));
    }
  }

  SINFO << "lane num: " << hdmap->lane_size();
  // SINFO << hdmap->lane(100).DebugString();
  for (auto& cowa_lane : hdmap->lane()) {
    if (cowa_lane.left_line_size() < 1 || cowa_lane.right_line_size() < 1) {
      SWARN << "lane: " << cowa_lane.id().id() << "左中右缺失";
      continue;
    }
    LaneLine lane;
    COWA::MapData::Lane clip_lane = cowa_lane;
    clip_lane.clear_mark();
    lane.display = clip_lane.DebugString();
    double x_min = std::numeric_limits<double>::max();
    double x_max = -std::numeric_limits<double>::max();
    double y_min = std::numeric_limits<double>::max();
    double y_max = -std::numeric_limits<double>::max();
    auto left_line_id = cowa_lane.left_line(cowa_lane.left_line_size() - 1).id();
    auto right_line_id = cowa_lane.right_line(cowa_lane.right_line_size() - 1).id();

    if (id_curves.find(left_line_id) != id_curves.end() && id_curves.find(right_line_id) != id_curves.end()) {
      lane.left = id_lines.find(left_line_id)->second;
      lane.right = id_lines.find(right_line_id)->second;
    }

    int markSize = cowa_lane.mark_size();
    if (markSize > 0) {
      // SINFO << "lanemark num: " << markSize;
      for (auto& mark : cowa_lane.mark()) {
        LaneMark laneMark;
        for (auto& point : mark.polygon().point()) {
          Point2D point2d(point.x(), point.y(), COWA::MapData::LanePoint_Type_UNKNOWN);
          laneMark.polygon.emplace_back(point2d);
        }
        laneMark.polygon = std::move(filterPoint(laneMark.polygon));
        lane.laneMarkVect.emplace_back(laneMark);
      }
    }

    if ((lane.left.size() == 0 || lane.right.size() == 0)) {
      SWARN << "lane: " << cowa_lane.id().id() << "线内点数量为0";
      continue;
    }

    lane.id = cowa_lane.id().id();
    lane.lane_type = static_cast<Lane_LaneType>(cowa_lane.type());
    lane.is_left_reality_line = lane_curve_types[left_line_id] == COWA::MapData::LaneCurve_Type_REALITY;
    lane.is_right_reality_line = lane_curve_types[right_line_id] == COWA::MapData::LaneCurve_Type_REALITY;
    lane.has_turn = cowa_lane.has_turn() ? true : false;
    lane.lane_turn =
        cowa_lane.has_turn() ? static_cast<Lane_LaneTurn>(cowa_lane.turn()) : Lane_LaneTurn::Lane_LaneTurn_NO_TURN;

    // SWARN << lanes_.size();
    // SWARN << "lane.left = " << lane.left.size() << ",   lane.right =  " << lane.right.size();
    lanes_.emplace_back(lane);
  }

  SINFO << "crosswalk num: " << hdmap->crosswalk_size();
  for (auto& cowa_crosswalk : hdmap->crosswalk()) {
    CrossWalk crossWalk;
    for (auto& point : cowa_crosswalk.polygon().point()) {
      Point2D point2d(point.x(), point.y(), COWA::MapData::LanePoint_Type_UNKNOWN);
      crossWalk.polygon.emplace_back(point2d);
    }
    crossWalk.polygon = std::move(filterPoint(crossWalk.polygon));
    crossWalk.id = cowa_crosswalk.id().id();
    crosswalks_.emplace_back(crossWalk);
  }

  SINFO << "crossroad num: " << hdmap->crossroad_size();
  for(auto& cowa_crossroad : hdmap->crossroad()) {
    Crossroad crossroad;
    for(auto& point : cowa_crossroad.boundary().point()) {
      Point2D point2d(point.x(), point.y(), COWA::MapData::LanePoint_Type_UNKNOWN);
      crossroad.boundary.emplace_back(point2d);
    }
    crossroad.boundary = std::move(filterPoint(crossroad.boundary));
    crossroad.id = cowa_crossroad.id().id();
    crossroads_.emplace_back(crossroad);
  }

  SINFO << "special object num: " << hdmap->objects_size();
  for(auto& cowa_object : hdmap->objects()) {
    if(std::find(objectTypes.begin(), objectTypes.end(), cowa_object.type()) == objectTypes.end()) {
      // 排除不在特殊物体集合中的类型
      continue;
    }
    SpecialObject spObject;
    for(auto& point : cowa_object.polygon().point()) {
      Point2D point2d(point.x(), point.y(), COWA::MapData::LanePoint_Type_UNKNOWN);
      spObject.polygon.emplace_back(point2d);
    }
    spObject.polygon = std::move(filterPoint(spObject.polygon));
    spObject.id = cowa_object.id().id();
    spObject.type_ = cowa_object.type();
    spObjects_.emplace_back(spObject);
  }
  SINFO << "special object needed to paint num: " << spObjects_.size();

  SINFO << "ramp num: " << hdmap->ramp_size();
  for (auto& cowa_ramp : hdmap->ramp()) {
    Ramp ramp;
    for (auto& point : cowa_ramp.polygon().point()) {
      Point2D point2d(point.x(), point.y(), COWA::MapData::LanePoint_Type_UNKNOWN);
      ramp.polygon.emplace_back(point2d);
    }
    ramp.polygon = std::move(filterPoint(ramp.polygon));
    ramp.id = cowa_ramp.id().id();
    ramps_.emplace_back(ramp);
  }

  SINFO << "signal num: " << hdmap->signal_size();
  for (auto& cowa_signal : hdmap->signal()) {
    if (!cowa_signal.has_id() || !cowa_signal.id().has_id()) {
      SINFO << "cowa_signal no id";
      continue;
    }
    // Signal有三种情况
    // 1、无stop line,无subsignal
    // 2、无stop line,有subsignal
    // 3、有stop line,有subsignal
    // 只考虑第二种中subsignal只有一个，即人行道和第三种
    Signal sig;

    if (cowa_signal.subsignal_size() < 1) {
      continue;
    }
    
    if (cowa_signal.stop_line_size() < 2) {
      // 没有stop line
      if (cowa_signal.subsignal_size() == 1) {
        // 人行道上的红绿灯
        auto sub_signal = cowa_signal.subsignal(0);
        if (sub_signal.has_boundary()) {
          auto polygon = sub_signal.boundary();
          // 取boundary前2个点
          Point2D point1(polygon.point(0).x(), polygon.point(0).y(), COWA::MapData::LanePoint_Type_UNKNOWN);
          Point2D point2(polygon.point(1).x(), polygon.point(1).y(), COWA::MapData::LanePoint_Type_UNKNOWN);
          sig.stop_line.emplace_back(point1);
          sig.stop_line.emplace_back(point2);

          sig.stop_line = std::move(filterPoint(sig.stop_line));
          sig.id = cowa_signal.id().id();
          sig.has_subsignal = cowa_signal.subsignal_size() > 0;
          sig.is_crosswalk = true;
          signals_.emplace_back(sig);
        }
      }
      continue;
    }

    // 有stop line,有subsignal
    for (auto& point : cowa_signal.stop_line()) {
      Point2D point2d(point.x(), point.y(), COWA::MapData::LanePoint_Type_UNKNOWN);
      sig.stop_line.emplace_back(point2d);
    }
    sig.stop_line = std::move(filterPoint(sig.stop_line));
    // SINFO << "stop_line point num: " << cowa_signal.stop_line_size() << ", filterPoint " << sig.stop_line.size();
    sig.id = cowa_signal.id().id();
    sig.has_subsignal = cowa_signal.subsignal_size() > 0;
    signals_.emplace_back(sig);
    // SINFO << ss.str();
  }

  ready_ = true;
}

void MapModel::createLaneDistanceMap(std::map<double, Point2D>& laneDistanceMap,
                                     std::vector<Point2D>& points,
                                     const Point2D& point2d)
{
  for (auto& point : points) {
    // 1、计算point0与point2d的距离
    auto distance = calculateDistance(point2d, point);
    // 2、构造map{distance: point}
    laneDistanceMap.emplace(distance, point);
  }
}

// 计算并记录LaneCurve中LaneStrip所在的point范围
void MapModel::recordLaneStrip(std::map<double, Point2D>& laneDistanceMap,
                               std::vector<std::vector<Point2D>>& lane_strips,
                               const float start,
                               const float end)
{
  if (end <= start) { return; }
  std::vector<Point2D> lane_strip;
  for (auto it = laneDistanceMap.begin(); it != laneDistanceMap.end(); ++it) {
    if (it->first >= start && it->first <= end) { lane_strip.push_back(it->second); }
  }
  lane_strips.push_back(lane_strip);
}