
#include "routing_model.h"

#include <QVariant>
#include <iostream>

void RoutingModel::setRoutingPoints(const QVariantList& line_curve)
{
  if (line_curve.length() > 0) {
    routing_points_.clear();
    for (auto it = line_curve.begin(); it != line_curve.end(); ++it) {
      auto x = it->toPointF().x();
      auto y = it->toPointF().y();
      std::cout << "x" << x << ", y" << y;
      routing_points_.push_back(x);
      routing_points_.push_back(y);
    }

    work_mode_.resize(routing_points_.size() / 2, 0);
    work_side_.resize(routing_points_.size() / 2, 0);
  }
}

void RoutingModel::fromProto(const COWA::routing::RoutingRequest& routing_request)
{
  routing_points_.clear();
  for (int i = 0; i < routing_request.waypoint_size(); i++) {
    auto& point = routing_request.waypoint(i).pose();
    routing_points_.push_back(point.x());
    routing_points_.push_back(point.y());
  }

  work_mode_.resize(routing_points_.size() / 2, 0);
  work_side_.resize(routing_points_.size() / 2, 0);

  for (int i = 0; i < routing_request.waypoint_size(); i++) {
    auto& point = routing_request.waypoint(i);
    if (point.has_work()) {
      auto work = point.work();
      if (work.has_mode()) { this->setWorkMode(i, work.mode()); }
      if (work.has_side()) { this->setWorkSide(i, work.side()); }
    }
  }
}

void RoutingModel::toProto(COWA::routing::RoutingRequest* routing_request)
{
  routing_request->Clear();

  int index = 0;
  for (int index = 0; index < routing_points_.size() / 2; ++index) {
    auto waypoint = routing_request->add_waypoint();
    auto x = routing_points_[2 * index];
    auto y = routing_points_[2 * index + 1];
    waypoint->mutable_pose()->set_x(x);
    waypoint->mutable_pose()->set_y(y);

    if (work_mode_[index] > 0) {
      auto work = waypoint->mutable_work();
      std::cout << "work_mode_[index] " << work_mode_[index] << std::endl;
      work->set_mode(static_cast<COWA::routing::LaneWaypoint_WorkMode>(work_mode_[index]));
    }

    if (work_side_[index] > 0) {
      auto work = waypoint->mutable_work();
      std::cout << "work_side_[index] " << work_side_[index] << std::endl;
      work->set_side(static_cast<COWA::routing::LaneWaypoint_WorkSide>(work_side_[index]));
    }
  }
}
