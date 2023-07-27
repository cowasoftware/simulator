#pragma once

#include <QObject>
#include <fstream>
#include <functional>
#include <list>
#include <mutex>
#include <string>
#include <thread>

#include "client/blockingconcurrentqueue.h"
#include "client/context.h"
#include "client/handler_client.h"
#include "common_model.h"
#include "sim-proto/pub_server.pb.h"
#include "sim-proto/rpc_client.pb.h"
#include "sim-proto/rpc_server.pb.h"

using namespace simulator::rpc::client;
using namespace simulator::pub::server;
using namespace simulator::rpc::server;
using PoseStamped = COWA::NavMsg::PoseStamped;
using SignalState = simulator::rpc::client::SignalState;
using SignalConfig = simulator::rpc::client::SignalConfig;

// for notify something to main thread
class MainThreadNotifier : public QObject {
  Q_OBJECT
 public:
  explicit MainThreadNotifier(QObject* parent = 0) : QObject(parent) {}
  virtual ~MainThreadNotifier() {}

 public:
 Q_SIGNALS:
  void onRecvMapList(std::shared_ptr<QList<QString>>);
  void onRecvMap(std::shared_ptr<HdMap> hdmap);
  void onRecvSignalConfig(std::shared_ptr<std::vector<SignalConfig>> signal_configs);
  void onPoseUpdate(std::shared_ptr<ObstaclesInfo> obstacles_info);
  void onRecordPoseUpdate(std::shared_ptr<PoseStamped> pose_stamped);
  void onFrame(int frame_id);
  void onSignalStateUpdate(std::vector<SignalState> vec_light_info);

  void onRecvRecordList(std::shared_ptr<QList<QString>>);
  void onRecvRecord(std::shared_ptr<RPCReplyRecord> record);
  void notifyBackToHome();
};

/* class for connection with server */
class SimulatorClient : public HandlerClient {
 public:
  static SimulatorClient* GetInstance();
  const MainThreadNotifier* getNotifier() const { return &notifier_; }

  void acquireMapList();
  void acquireMap(const std::string& map_name);
  void sendCommandToSimulator(Command command, std::vector<std::string> const& param_list = std::vector<std::string>());
  void setObstacles(const ObstaclesInfo& obstacles_info);
  void setSignalConfig(const SignalConfig& signal_config);
  void setSimulateRate(int rate);
  void setKeepTrafficLightGreen(int keep);
  // void notifyLightInfo(const std::string& id, SignalState::Direction type, SignalState::State color, int remainTime);

  void acquireRecordList();
  void acquireRecord(const std::string& record_name);
  void setRecordPlayerTopics();
  void sendCommandToRecordPlayer(RecordCommand command);
  void sendRecordPlayerStartTime(int second);

  // a debug function,  dump everything to file
  void dumpsys();

  virtual void onRecv(const std::string& data);
  virtual void onError(Errno err);

  std::string getRequiredMapName() { return required_map_name_; }

 private:
  SimulatorClient();
  ~SimulatorClient();
  SimulatorClient(const SimulatorClient& other) = delete;
  const SimulatorClient& operator=(const SimulatorClient& other) = delete;

  // 唯一单实例对象指针
  static SimulatorClient* instance_;
  MainThreadNotifier notifier_;
  std::string required_map_name_;
  using func_task = std::function<void()>;
  moodycamel::BlockingConcurrentQueue<func_task> task_queue_;
};
