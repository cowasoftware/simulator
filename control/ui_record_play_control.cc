#include "ui_record_play_control.h"

RecordPlayControl::RecordPlayControl(QObject* parent) : QObject(parent)
{
  ui_record_list_model_ = new RecordListModel(this);
  ui_record_model_ = new RecordModel(this);
  scenario_control_ = SingletonScenarioControl::getInstance();

  const MainThreadNotifier* notifer = SimulatorClient::GetInstance()->getNotifier();
  QObject::connect(notifer, SIGNAL(onRecvRecordList(std::shared_ptr<QList<QString>>)), this,
                   SLOT(onRecvRecordList(std::shared_ptr<QList<QString>>)), Qt::QueuedConnection);
  qRegisterMetaType<std::shared_ptr<RPCReplyRecord>>("std::shared_ptr<RPCReplyRecord>)");
  QObject::connect(notifer, SIGNAL(onRecvRecord(std::shared_ptr<RPCReplyRecord>)), this,
                   SLOT(onRecvRecord(std::shared_ptr<RPCReplyRecord>)), Qt::QueuedConnection);
}

RecordPlayControl::~RecordPlayControl()
{
  delete ui_record_list_model_;
  delete ui_record_model_;
}

RecordListModel* RecordPlayControl::acquireRecordList()
{
  if (!ui_record_list_model_->ready()) { SimulatorClient::GetInstance()->acquireRecordList(); }
  return ui_record_list_model_;
}

RecordModel* RecordPlayControl::acquireRecord(const QString& record_name)
{
  const std::string& record = record_name.toStdString();
  if (!record.empty()) {
    SINFO << "acquireRecord " << record;
    SimulatorClient::GetInstance()->setRecordPlayerTopics();
    SimulatorClient::GetInstance()->acquireRecord(record);
  }
  return ui_record_model_;
}

void RecordPlayControl::recordPlayerStart()
{
  SINFO << "syncSceneToServer";
  SimulatorClient::GetInstance()->setObstacles(scenario_control_->getCurrentObstaclesInfo());
  SINFO << "recordPlayerStart";
  SimulatorClient::GetInstance()->sendCommandToRecordPlayer(COM_start_play_record);
}

void RecordPlayControl::recordPlayerPause()
{
  SINFO << "recordPlayerPause";
  SimulatorClient::GetInstance()->sendCommandToRecordPlayer(COM_stop_play_record);
}

void RecordPlayControl::recordPlayerSeekTo(int timestamp)
{
  SimulatorClient::GetInstance()->sendRecordPlayerStartTime(timestamp);
}

void RecordPlayControl::onRecvRecordList(std::shared_ptr<QList<QString>> record_list)
{
  SINFO << "onRecvRecordList " << record_list->size();
  ui_record_list_model_->flush(record_list);
  Q_EMIT notifyRecordList(ui_record_list_model_);
}

void RecordPlayControl::onRecvRecord(std::shared_ptr<RPCReplyRecord> record)
{
  if (record == nullptr) { return; }

  ui_record_model_->onRecvRecord(record);
  is_record_loaded_ = true;
  Q_EMIT notifyRecord(ui_record_model_);
}

void RecordPlayControl::onFrame(int frame_id) {}