/*
 * Copyright 2012-2022
 * All rights reserved.
 */

#ifndef CLIENT_DEFINE_HEADER_
#define CLIENT_DEFINE_HEADER_

#include "sim-proto/obstacle.pb.h"
#include "sim-proto/road_detect.pb.h"
#include <map>

const bool ENABLE_DUMP_FILE = false;

struct ObstacleDefaultData
{
  double width_;
  double length_;

  ObstacleDefaultData(double width, double length) : width_(width), length_(length) {}
};

struct GarbageDefaultData
{
  double width_;
  double length_;

  GarbageDefaultData(double width, double length) : width_(width), length_(length) {}
};

const int GARBAGE_TYPE_START = 200;

const std::map<COWA::NavMsg::Obstacle_Type, ObstacleDefaultData> g_obstacleDefaultDataMap = {
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_UNKNOWN, {1, 1}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_CAR, {2, 4.5}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_TRUCK, {3, 7.5}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_MOTORCYCLIST, {1, 2}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_PEDESTRIAN, {1, 0.6}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_CYCLIST, {1, 1.5}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_DUSTBIN, {1, 1}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_TREE_TRUNK, {3, 3}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_PILES, {0.5, 0.5}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_SPECIAL, {3, 6}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_POLE, {1.0, 1.0}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_ROADBLOCK, {1, 1}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_WHEELCHAIR, {1, 1.5}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_BABYCAR, {1, 1.4}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_BLOCK, {1.0, 1.0}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_BUS, {3, 6}},
    {COWA::NavMsg::Obstacle_Type::Obstacle_Type_TRICYCLE, {1.5, 2.5}}};

    const std::map<COWA::DetectMsg::DetObject_Category, GarbageDefaultData> g_garbageDefaultDataMap = {
      {COWA::DetectMsg::DetObject_Category::DetObject_Category_CRACK, {0.5, 0.5}},
      {COWA::DetectMsg::DetObject_Category::DetObject_Category_POTHOLE, {0.5, 0.5}},
      {COWA::DetectMsg::DetObject_Category::DetObject_Category_LINEBLUR, {0.5, 0.5}},
      {COWA::DetectMsg::DetObject_Category::DetObject_Category_ROADDIRT, {0.5, 0.5}},
      {COWA::DetectMsg::DetObject_Category::DetObject_Category_BIGGARBAGE, {0.5, 0.5}},
      {COWA::DetectMsg::DetObject_Category::DetObject_Category_PONDING, {0.5, 0.5}},
      {COWA::DetectMsg::DetObject_Category::DetObject_Category_SNOW, {0.5, 0.5}},
      {COWA::DetectMsg::DetObject_Category::DetObject_Category_FALLENLEAVES, {0.5, 0.5}},
      {COWA::DetectMsg::DetObject_Category::DetObject_Category_WHITETRASH, {0.5, 0.5}},
      {COWA::DetectMsg::DetObject_Category::DetObject_Category_OTHERGARBAGE, {0.5, 0.5}}
    };

#endif