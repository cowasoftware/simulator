#pragma once

#include <QObject>

#include "common/Singleton.h"
#include "record_list_model.h"
#include "record_model.h"
#include "simulator_client.h"
#include "ui_scenario_control.h"

class RecordPlayControl final : public QObject {
  Q_OBJECT
 public:
  RecordPlayControl(QObject* parent = nullptr);
  ~RecordPlayControl();
  RecordPlayControl(const RecordPlayControl& other) = delete;
  const RecordPlayControl& operator=(const RecordPlayControl& other) = delete;

 public:
 Q_SIGNALS:
  // notify to qml UI
  void notifyRecordList(RecordListModel* model);
  void notifyRecord(RecordModel* model);

 private Q_SLOTS:
  // reply from server
  void onRecvRecordList(std::shared_ptr<QList<QString>> record_list);
  void onRecvRecord(std::shared_ptr<RPCReplyRecord> record);
  void onFrame(int frame_id);

 public:
  // fetch records file
  Q_INVOKABLE RecordListModel* acquireRecordList();
  Q_INVOKABLE RecordModel* acquireRecord(const QString& record_name = "");

  // send command to server
  Q_INVOKABLE void recordPlayerStart();
  Q_INVOKABLE void recordPlayerPause();
  Q_INVOKABLE void recordPlayerSeekTo(int timestamp);

 private:
  RecordListModel* ui_record_list_model_;
  RecordModel* ui_record_model_;

  bool is_record_loaded_ = false;

  // scenario信息
  ScenarioControl* scenario_control_;
};

typedef Singleton<RecordPlayControl> SingletonRecordPlayControl;