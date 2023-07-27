#pragma once
#include <QObject>
#include "common_model.h"

namespace simulator{
namespace manager{
    struct Circle
    {
        int id;
        Point2D center;
        double radius;
        void fromProto(const simulator::rpc::client::ParkingArea::Circle& circle_pb)
        {
            id = circle_pb.id();
            center.x_ = circle_pb.center().x();
            center.y_ = circle_pb.center().y();
            radius = circle_pb.radius();
        }
        void toProto(simulator::rpc::client::ParkingArea::Circle* circle_pb)
        {
            circle_pb->set_id(id);
            auto circle_center = circle_pb->mutable_center();
            circle_center->set_x(center.getX());
            circle_center->set_y(center.getY());
            circle_pb->set_radius(radius);
        }
    };
}
}

class ParkingCircleModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList circle_ids READ getIds)
    Q_PROPERTY(QVariantList circle_points READ getPoints)
    Q_PROPERTY(QVariantList circle_raduii READ getRaduii)

public:
    explicit ParkingCircleModel(QObject* parent = 0) : QObject(parent) {}
    ParkingCircleModel(const ParkingCircleModel& other) = default;
    ParkingCircleModel& operator=(const ParkingCircleModel& other) = default;
    virtual ~ParkingCircleModel() {}

    Q_INVOKABLE QVariantList getIds() { return ids_; }
    Q_INVOKABLE QVariantList getPoints() { return points_; }
    Q_INVOKABLE QVariantList getRaduii() { return raduii_; }

    void addParkingArea(const QVariantList& ids, const QVariantList& points, const QVariantList& radii);
    bool deleteCircleById(int id);
    bool deleteParkingArea();
    void fromProto(const simulator::rpc::client::ParkingArea & parking_area);
    void toProto(simulator::rpc::client::ParkingArea* parking_area);
    QVariantList getIds() const { return ids_;}
    QVariantList getPoints() const { return points_;}
    QVariantList getRaduii() const { return raduii_;}


private:
    std::map<int, simulator::manager::Circle> parking_area_;
    QVariantList ids_;
    QVariantList points_;
    QVariantList raduii_;
};