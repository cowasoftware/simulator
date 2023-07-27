#pragma once

#include <QAbstractListModel>
#include <QQmlEngine>
#include <vector>

class MapItem : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString title READ getTitle WRITE setTitle NOTIFY titleChanged)
 public:
  explicit MapItem(QObject* parent = 0) : QObject(parent) {}

  ~MapItem() = default;

  MapItem(const MapItem& other, QObject* parent = 0) : QObject(parent) { title_ = other.getTitle(); }
  MapItem& operator=(const MapItem& other)
  {
    title_ = other.getTitle();
    return *this;
  }

  QString getTitle() const { return title_; }
  void setTitle(const QString& title) { title_ = title; }

 public:
 Q_SIGNALS:
  void titleChanged();

 private:
  QString title_;
  // todo : add more attribute
};

/* for QML read */
class MapListModel : public QAbstractListModel {
  Q_OBJECT
 public:
  virtual int rowCount(const QModelIndex& parent) const;
  virtual QVariant data(const QModelIndex& index, int role) const;
  virtual QHash<int, QByteArray> roleNames() const;

 public:
  explicit MapListModel(QObject* parent = 0);
  virtual ~MapListModel();

  bool ready() { return ready_; }
  void flush(std::shared_ptr<QList<QString>> map_list);

 private:
  QHash<int, QByteArray> rolesNames_;

  std::vector<MapItem*> map_items_;
  bool ready_ = false;
};
