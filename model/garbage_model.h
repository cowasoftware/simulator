#pragma once

#include <QObject>
#include <QQmlEngine>

#include "common_model.h"
#include "qpoint.h"
#include "sim-proto/rpc_client.pb.h"


using GarbageInfo = simulator::rpc::client::GarbageInfo;

class GarbageModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(int id READ getId)
    Q_PROPERTY(int type READ getType)
    Q_PROPERTY(double x READ getX WRITE setX NOTIFY xChanged)
    Q_PROPERTY(double y READ getY WRITE setY NOTIFY yChanged)
    Q_PROPERTY(double z READ getZ WRITE setZ NOTIFY zChanged)
    Q_PROPERTY(double theta READ getTheta WRITE setTheta NOTIFY thetaChanged)
    Q_PROPERTY(double width READ getWidth WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(double length READ getLength WRITE setLength NOTIFY lengthChanged)
    Q_PROPERTY(double height READ getHeight WRITE setHeight NOTIFY heightChanged)


public:
    explicit GarbageModel(QObject* parent = 0);
    virtual ~GarbageModel();
    GarbageModel(const GarbageModel& other) = default;
    GarbageModel& operator=(const GarbageModel& other) = default;

    void fromProto(const GarbageInfo& garbage_info);
    void toProto(GarbageInfo* garbage_info);

    int getId() const { return id_; }
    void setId(int id) { id_ = id; }

    int allocId() { return ++next_alloc_id_; }

    int getType() const { return static_cast<int>(type_); }
    void setType(int type) { 
        type_ = static_cast<GarbageType>(type); 
    }

    double getX() const { return p_x_; }
    void setX(double x)
    {
        if (p_x_ != x) {
            p_x_ = x;
            Q_EMIT xChanged();
        }
    }

    double getY() const { return p_y_; }
    void setY(double y)
    {
        if (p_y_ != y) {
            p_y_ = y;
            Q_EMIT yChanged();
        }
    }

    double getZ() const { return p_z_; }
    void setZ(double z)
    {
        if (p_z_ != z) {
            p_z_ = z;
            Q_EMIT zChanged();
        }
    }

    double getTheta() const { return p_theta_; }
    void setTheta(double theta)
    {
        if (p_theta_ != theta) {
        p_theta_ = theta;
        Q_EMIT thetaChanged();
        }
    }

    double getWidth() const { return width_; }
    void setWidth(double width)
    {
        if (width_ != width) {
            width_ = width;
            Q_EMIT widthChanged(width);
        }
    }

    double getLength() const { return length_; }
    void setLength(double length)
    {
        if (length_ != length) {
            length_ = length;
            Q_EMIT lengthChanged();
        }
    }
    
    double getHeight() const { return height_; }
    void setHeight(double height)
    {
        if (height_ != height) {
            height_ = height;
            Q_EMIT heightChanged();
        }
    }

public:
 Q_SIGNALS:
  void xChanged();
  void yChanged();
  void zChanged();
  void thetaChanged();
  void widthChanged(double width);
  void lengthChanged();
  void heightChanged();

private:
    int id_ = 0;
    int next_alloc_id_ = 0;
    float confidence_ = 1.0f;
    GarbageType type_;
    float length_ = 1.0f;
    float width_ = 1.0f;
    float height_ = 1.0f;
    float p_theta_ = 0.0f;
    double p_x_ = 0.0f;
    double p_y_ = 0.0f;
    double p_z_ = 0.0f;
    // std::vector<Point2D> cv_polygons_; // 世界坐标系下的bounding
};