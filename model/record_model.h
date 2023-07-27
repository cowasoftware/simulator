#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QVariant>

#include "common_model.h"
#include "control/simulator_client.h"

class RecordModel : public QObject {
  Q_OBJECT
  Q_PROPERTY(qulonglong begin READ getBegin)
  Q_PROPERTY(qulonglong end READ getEnd)
  Q_PROPERTY(QList<QString> recordfiles READ getRecordFiles)
 public:
  virtual void onRecvRecord(std::shared_ptr<RPCReplyRecord> record);

 public:
  explicit RecordModel(QObject* parent = 0) : QObject(parent) {}
  virtual ~RecordModel() {}

  qulonglong getBegin() { return begin_time_; }
  qulonglong getEnd() { return end_time_; }
  QList<QString> getRecordFiles() { return record_files_; }

 private:
  QList<QString> record_files_;
  qulonglong begin_time_;
  qulonglong end_time_;
};
