#include "parking_circle_model.h"
#include <QVariant>
#include <QPointF>
#include <QDebug>
#include "logger.h"


void ParkingCircleModel::addParkingArea(const QVariantList& ids, const QVariantList& points, const QVariantList& radii)
{
    qDebug() << "ParkingCircleModel::addParkingArea: " << ids << Qt::endl;
    parking_area_.clear();
    for (int i = 0; i < points.size(); ++i)
    {
        auto id = ids.at(i).toInt();
        auto point = points[i].toPointF();
        auto radius = radii.at(i).toDouble();

        simulator::manager::Circle circle;
        circle.id = id;
        Point2D point2d(point.x(), point.y());
        circle.center = point2d;
        circle.radius = radius;
        parking_area_[id] = circle;
    }
}

bool ParkingCircleModel::deleteCircleById(int id)
{
    // SINFO << "deleteCircleById, id=" << id;
    auto it = parking_area_.find(id);
    if (it != parking_area_.end())
    {
        parking_area_.erase(id);
        return true;
    }
    return false;
}

bool ParkingCircleModel::deleteParkingArea()
{
    parking_area_.clear();
    return true;
}

void ParkingCircleModel::fromProto(const simulator::rpc::client::ParkingArea& parking_area)
{
    parking_area_.clear();
    ids_.clear();
    points_.clear();
    raduii_.clear();
    for (auto& circle_pb : parking_area.circle())
    {
        simulator::manager::Circle circle;
        circle.fromProto(circle_pb);
        parking_area_[circle_pb.id()] = circle;
        QVariant id = QVariant::fromValue(circle.id);
        QVariant point = QVariant::fromValue(QPointF(circle.center.getX(), circle.center.getY()));
        QVariant radius = QVariant::fromValue(circle.radius);
        ids_.append(id);
        points_.append(point);
        raduii_.append(radius);
    }
}

void ParkingCircleModel::toProto(simulator::rpc::client::ParkingArea* parking_area)
{
    parking_area->Clear();
    for (auto it = parking_area_.begin(); it != parking_area_.end(); ++it)
    {
         auto circle = parking_area->add_circle();
         it->second.toProto(circle);
    }
}