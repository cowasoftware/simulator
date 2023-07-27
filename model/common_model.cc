#include "common_model.h"

#include "common/Util.h"
#include <cmath>

// 过滤掉车道线上 多余的点
bool samePoint(const Point2D& a, const Point2D& b)
{
  const double EPSINON = 0.00001;
  return (abs(a.x_ - b.x_) < EPSINON && abs(a.y_ - b.y_) < EPSINON);
}
bool sameLine(const Point2D& a, const Point2D& b, const Point2D& c)
{
  double x1 = b.x_ - a.x_;
  double y1 = b.y_ - a.y_;
  double x2 = c.x_ - b.x_;
  double y2 = c.y_ - b.y_;
  return ((x1 * x2 + y1 * y2) / (std::sqrt(x1 * x1 + y1 * y1) * std::sqrt(x2 * x2 + y2 * y2))) > 0.999999;
}

std::vector<Point2D> filterPoint(const std::vector<Point2D>& lines)
{
  std::set<int> unused;
  std::vector<Point2D> result;
  for (unsigned int i = 0; i < lines.size(); ++i) {
    if (result.empty()) { result.emplace_back(lines[i]); }
    else if (result.size() == 1) {
      if (!samePoint(result.back(), lines[i])) {
        //
        result.emplace_back(lines[i]);
      }
    }
    else {
      // 判断是否是一条直线
      auto& back1 = result.back();
      if (!samePoint(back1, lines[i])) {
        result.pop_back();
        auto& back2 = result.back();
        if (!sameLine(back2, back1, lines[i]) ||
          lines[i].getType() != back1.getType() ||  lines[i].getType() != back2.getType()) {
          // back1、back2、lines[i]三点不在同一条线上或者back1为CURB
          result.emplace_back(back1);
        }
        result.emplace_back(lines[i]);
      }
    }
  }
  return result;
}
///

double calculateDistance(const Point2D& p1, const Point2D& p2) {
  double result = 0.0;
  result = std::sqrt(std::pow(p1.getX()-p2.getX(),2) + std::pow(p1.getY()-p2.getY(),2));
  return result;
}

Point2D::Point2D() {}
Point2D::Point2D(double x, double y) : x_(x), y_(y) {}
Point2D::Point2D(double x, double y, LanePoint_Type type) : x_(x), y_(y), type_(type) {}
Point2D::~Point2D() {}

std::string Point2D::toString()
{
  std::string type;
  switch (type_) {
  case LanePoint_Type::LanePoint_Type_UNKNOWN: {
    type = "LanePoint_Type_UNKNOWN";
  } break;
  case LanePoint_Type::LanePoint_Type_DOTTED_YELLOW: {
    type = "LanePoint_Type_DOTTED_YELLOW";
  } break;
  case LanePoint_Type::LanePoint_Type_DOTTED_WHITE: {
    type = "LanePoint_Type_DOTTED_WHITE";
  } break;
  case LanePoint_Type::LanePoint_Type_SOLID_YELLOW: {
    type = "LanePoint_Type_SOLID_YELLOW";
  } break;
  case LanePoint_Type::LanePoint_Type_SOLID_WHITE: {
    type = "LanePoint_Type_SOLID_WHITE";
  } break;
  case LanePoint_Type::LanePoint_Type_DOUBLE_YELLOW: {
    type = "LanePoint_Type_DOUBLE_YELLOW";
  } break;
  case LanePoint_Type::LanePoint_Type_CURB: {
    type = "LanePoint_Type_CURB";
  } break;
  case LanePoint_Type::LanePoint_Type_BLANK: {
    type = "LanePoint_Type_BLANK";
  } break;
  case LanePoint_Type::LanePoint_Type_VIRTUAL: {
    type = "LanePoint_Type_VIRTUAL";
  } break;
  default: break;
  }
  return Util::Format("{\"x\":%lf, \"y\":%lf, \"type\":\"%s\"}", x_, y_, type.c_str()).c_str();
}

LaneLine::LaneLine() {}
LaneLine::~LaneLine() {}

std::string LaneLine::toString()
{
  return display;
}

LaneMark::LaneMark() {}
LaneMark::~LaneMark() {}
std::string LaneMark::toString()
{
  std::string type;
  switch(lanemark_type_) {
    case LaneMark_Type::Lane_LaneMark_Type_TEXT: {
      type = "Lane_LaneMark_Type_TEXT";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_FORWORD: {
      type = "Lane_LaneMark_Type_TURN_FORWORD";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_FORWORD_LEFT: {
      type = "Lane_LaneMark_Type_TURN_FORWORD_LEFT";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_FORWORD_RIGHT: {
      type = "Lane_LaneMark_Type_TURN_FORWORD_RIGHT";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_FORWORD_UTURN: {
      type = "Lane_LaneMark_Type_TURN_FORWORD_UTURN";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_LEFT: {
      type = "Lane_LaneMark_Type_TURN_LEFT";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_LEFT_FORBIDEN: {
      type = "Lane_LaneMark_Type_TURN_LEFT_FORBIDEN";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_LEFT_RIGHT: {
      type = "Lane_LaneMark_Type_TURN_LEFT_RIGHT";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_LEFT_UTURN: {
      type = "Lane_LaneMark_Type_TURN_LEFT_UTURN";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_RIGHT: {
      type = "Lane_LaneMark_Type_TURN_RIGHT";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_RIGHT_FORBIDEN: {
      type = "Lane_LaneMark_Type_TURN_RIGHT_FORBIDEN";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_UTURN: {
      type = "Lane_LaneMark_Type_TURN_UTURN";
      break;
    }
    case LaneMark_Type::Lane_LaneMark_Type_TURN_UTURN_FORBIDEN: {
      type = "Lane_LaneMark_Type_TURN_UTURN_FORBIDEN";
      break;
    }
    default: break;
  }
  return type;
}

LaneStrip::LaneStrip() {}
LaneStrip::~LaneStrip() {}
std::string LaneStrip::toString() {
  std::string type;
  switch(type_) {
    case LaneStrip_Type::LaneStrip_Type_WALL: {
      type = "LaneStrip_Type_WALL";
      break;
    }
    case LaneStrip_Type::LaneStrip_Type_FENCE: {
      type = "LaneStrip_Type_FENCE";
      break;
    }
    case LaneStrip_Type::LaneStrip_Type_GREEN: {
      type = "LaneStrip_Type_GREEN";
      break;
    }
    default:
      break;
  }
  return type;
}

Signal::Signal() {}
Signal::~Signal() {}

CrossWalk::CrossWalk() {}
CrossWalk::~CrossWalk() {}

Crossroad::Crossroad() {}
Crossroad::~Crossroad() {}

Ramp::Ramp() {}
Ramp::~Ramp() {}

SpecialObject::SpecialObject() {}
SpecialObject::~SpecialObject() {}
std::string SpecialObject::toString()
{
  std::string type;
  switch(type_) {
    case Object_type::Object_Type_TREE_TRUNK: {
      type = "Object_Type_TREE_TRUNK";
      break;
    }
    case Object_type::Object_Type_POLE: {
      type = "Object_Type_POLE";
      break;
    }
    case Object_type::Object_Type_PILES: {
      type = "Object_Type_PILES";
      break;
    }
    case Object_type::Object_Type_DUSTBIN: {
      type = "Object_Type_DUSTBIN";
      break;
    }
    case Object_type::Object_Type_BLOCK: {
      type = "Object_Type_BLOCK";
      break;
    }
    case Object_type::Object_Type_BUILDING: {
      type = "Object_Type_BUILDING";
      break;
    }
    case Object_type::Object_Type_CURB: {
      type = "Object_Type_CURB";
      break;
    }
    default:
      break;
  }
  return type;
}