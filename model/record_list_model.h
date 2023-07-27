#pragma once

#include <QAbstractListModel>
#include <QQmlEngine>
#include <vector>

class RecordItem : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString title READ getTitle WRITE setTitle NOTIFY titleChanged)
 public:
  explicit RecordItem(QObject* parent = 0) : QObject(parent) {}

  ~RecordItem() = default;

  RecordItem(const RecordItem& other, QObject* parent = 0) : QObject(parent) { title_ = other.getTitle(); }
  RecordItem& operator=(const RecordItem& other)
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
class RecordListModel : public QObject {
  Q_OBJECT
  Q_PROPERTY(QList<RecordItem*> records READ getRecords)
 public:
 public:
  explicit RecordListModel(QObject* parent = 0);
  virtual ~RecordListModel();

  bool ready() { return ready_; }
  void flush(std::shared_ptr<QList<QString>> record_list);

 public:
  QList<RecordItem*> getRecords() { return record_items_; };

 private:
  void clear();

 private:
  QList<RecordItem*> record_items_;

  bool ready_ = false;
};
