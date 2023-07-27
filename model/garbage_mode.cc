#include "garbage_model.h"
#include <iostream>
#include "logger.h"
#include "config.h"


GarbageModel::GarbageModel(QObject* parent) : QObject(parent) {
}

GarbageModel::~GarbageModel(){
}

void GarbageModel::fromProto(const GarbageInfo& garbage_info) {
    auto garbage = garbage_info.detect_object();
    if (garbage.has_cate_id()) {
        type_ = static_cast<GarbageType>(garbage.cate_id() + GARBAGE_TYPE_START);
    }
    if (garbage.has_confidence()) {
        confidence_ = garbage.confidence();
    }
    if (garbage.has_track_id()) {
        id_ = garbage.track_id();
    }

    length_ = garbage_info.length();
    width_ = garbage_info.width();
    height_ = garbage_info.height();
    p_x_ = garbage_info.position().x();
    p_y_ = garbage_info.position().y();
    p_z_ = garbage_info.position().z();
    p_theta_ = garbage_info.theta();
}

void GarbageModel::toProto(GarbageInfo* garbage_info) {
    auto detect_object = garbage_info->mutable_detect_object();
    detect_object->set_cate_id(static_cast<GarbageType>(type_ - GARBAGE_TYPE_START));
    detect_object->set_confidence(confidence_);
    detect_object->set_track_id(id_);

    auto point0 = detect_object->add_cv_polygon();
    point0->set_x(0.5 * length_ * std::cos(p_theta_) - 0.5 * width_ * std::sin(p_theta_) + p_x_);
    point0->set_y(0.5 * length_ * std::sin(p_theta_) + 0.5 * width_ * std::cos(p_theta_) + p_y_);

    auto point1 = detect_object->add_cv_polygon();
    point1->set_x(0.5 * length_ * std::cos(p_theta_) + 0.5 * width_ * std::sin(p_theta_) + p_x_);
    point1->set_y(0.5 * length_ * std::sin(p_theta_) - 0.5 * width_ * std::cos(p_theta_) + p_y_);

    auto point2 = detect_object->add_cv_polygon();
    point2->set_x(-0.5 * length_ * std::cos(p_theta_) + 0.5 * width_ * std::sin(p_theta_) + p_x_);
    point2->set_y(-0.5 * length_ * std::sin(p_theta_) - 0.5 * width_ * std::cos(p_theta_) + p_y_);

    auto point3 = detect_object->add_cv_polygon();
    point3->set_x(-0.5 * length_ * std::cos(p_theta_) - 0.5 * width_ * std::sin(p_theta_) + p_x_);
    point3->set_y(-0.5 * length_ * std::sin(p_theta_) + 0.5 * width_ * std::cos(p_theta_) + p_y_);
    
    garbage_info->set_length(length_);
    garbage_info->set_width(width_);
    garbage_info->set_height(height_);
    garbage_info->set_theta(p_theta_);
    auto position = garbage_info->mutable_position();
    position->set_x(p_x_);
    position->set_y(p_y_);
    position->set_z(p_z_);
}