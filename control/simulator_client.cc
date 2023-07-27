
#include "simulator_client.h"

#include "client/context.h"
#include "client/logger.h"

SimulatorClient* SimulatorClient::instance_ = nullptr;
SimulatorClient* SimulatorClient::GetInstance()
{
  static std::once_flag of;
  std::call_once(of, [&]() {
    instance_ = new (std::nothrow) SimulatorClient();
    // 监听socket连接
    if (instance_ != nullptr)
    {
      std::function<void()> task = [&](){
        SINFO << "notify ui back to home";
        Q_EMIT instance_->notifier_.notifyBackToHome();
      };
      instance_->set_socket_listener(task);
    }
  });
  return instance_;
}

SimulatorClient::SimulatorClient()
{
  // new thread and loop,  run all task from main thread
  std::thread work_thread([this]() {
    while (true) {
      func_task task;
      task_queue_.wait_dequeue(task);
      task();
    }
  });
  work_thread.detach();
}

SimulatorClient::~SimulatorClient() {}

void SimulatorClient::acquireMapList()
{
  func_task task = [this]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_acquire_map_list);
    std::string params;
    rpcRequest.SerializeToString(&params);
    const std::string reply_str = std::move(request(params));
    RPCReplyMapList reply;
    reply.ParseFromString(reply_str);
    SINFO << "SimulatorClient acquireMapList: "
          << " map nums " << reply.maps_size();
    std::shared_ptr<QList<QString>> maps = std::shared_ptr<QList<QString>>(new QList<QString>());
    for (int i = 0; i < reply.maps_size(); ++i) { maps->push_back(QString::fromStdString(reply.maps(i))); }
    Q_EMIT notifier_.onRecvMapList(maps);
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::acquireMap(const std::string& map_name)
{
  func_task task = [this, map_name]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_acquire_map);
    rpcRequest.add_params_str(map_name);
    std::string params;
    rpcRequest.SerializeToString(&params);
    request(params);
    // const std::string& reply_str = request(params);
    // std::shared_ptr<HdMap> hdmap = std::make_shared<HdMap>();
    // hdmap->ParseFromString(reply_str);
    // required_map_name_ = map_name;
    // Q_EMIT notifier_.onRecvMap(hdmap);
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::sendCommandToSimulator(Command command, std::vector<std::string> const& param_list)
{
  func_task task = [this, command,param_list]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_send_command);
    rpcRequest.add_params_int(command);
    for(auto param: param_list){
      rpcRequest.add_params_str(param);
    }
    std::string params;
    rpcRequest.SerializeToString(&params);
    const std::string& reply_str = request(params);
    Result result = Result();
    result.ParseFromString(reply_str);
    if (result.result_code() == ResultCode::success) { SINFO << "SimulatorClient sendCommandToSimulator: success"; }
    else {
      SINFO << "SimulatorClient sendCommandToSimulator: error code:" << result.result_code()
            << ", msg:" << result.result_msg();
    }
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::sendCommandToRecordPlayer(RecordCommand command)
{
  func_task task = [this, command]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_send_record_command);
    rpcRequest.add_params_int(command);
    std::string params;
    rpcRequest.SerializeToString(&params);
    const std::string& reply_str = request(params);
    Result result = Result();
    result.ParseFromString(reply_str);
    if (result.result_code() == ResultCode::success) { SINFO << "SimulatorClient sendCommandToRecordPlayer: success"; }
    else {
      SINFO << "SimulatorClient sendCommandToRecordPlayer: error code:" << result.result_code()
            << ", msg:" << result.result_msg();
    }
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::sendRecordPlayerStartTime(int second)
{
  func_task task = [this, second]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_set_play_start_time);
    rpcRequest.add_params_int(second);
    std::string params;
    rpcRequest.SerializeToString(&params);
    const std::string& reply_str = request(params);
    Result result = Result();
    result.ParseFromString(reply_str);
    if (result.result_code() == ResultCode::success) { SINFO << "SimulatorClient sendRecordPlayerStartTime: success"; }
    else {
      SINFO << "SimulatorClient sendRecordPlayerStartTime: error code:" << result.result_code()
            << ", msg:" << result.result_msg();
    }
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::setRecordPlayerTopics()
{
  func_task task = [this]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_set_record_topic);
    rpcRequest.add_params_str("/predict");
    std::string params;
    rpcRequest.SerializeToString(&params);
    const std::string& reply_str = request(params);
    Result result = Result();
    result.ParseFromString(reply_str);
    if (result.result_code() == ResultCode::success) { SINFO << "SimulatorClient setRecordPlayerTopics: success"; }
    else {
      SINFO << "SimulatorClient setRecordPlayerTopics: error code:" << result.result_code()
            << ", msg:" << result.result_msg();
    }
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::setObstacles(const ObstaclesInfo& obstacles_info)
{
  std::shared_ptr<ObstaclesInfo> shared_obstacles_info = std::make_shared<ObstaclesInfo>(obstacles_info);
  func_task task = [this, shared_obstacles_info]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_set_obstacles);
    ObstaclesInfo* mutable_obstacles_info = rpcRequest.mutable_obstacles_info();
    *mutable_obstacles_info = *shared_obstacles_info.get();

    std::string str_request;
    rpcRequest.SerializeToString(&str_request);
    const std::string& reply_str = request(str_request);
    Result result = Result();
    result.ParseFromString(reply_str);
    if (result.result_code() == ResultCode::success) {
      SINFO << "SimulatorClient setObstacles: success ";
      // SINFO << "SimulatorClient setObstacles: success " << mutable_obstacles_info->DebugString();
    }
    else {
      SINFO << "SimulatorClient setObstacles: error code:" << result.result_code() << ", msg:" << result.result_msg();
    }
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::setSignalConfig(const SignalConfig& signal_config)
{
  std::shared_ptr<SignalConfig> shared_signal_config = std::make_shared<SignalConfig>(signal_config);
  func_task task = [this, shared_signal_config]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_set_signal_config);
    SignalConfig* mutable_signal_config = rpcRequest.mutable_signal_config();
    *mutable_signal_config = *shared_signal_config.get();

    std::string str_request;
    rpcRequest.SerializeToString(&str_request);
    const std::string& reply_str = request(str_request);
    Result result = Result();
    result.ParseFromString(reply_str);
    if (result.result_code() == ResultCode::success) {
      SINFO << "SimulatorClient setSignalConfig: success ";
      // SINFO << "SimulatorClient setSignalConfig: success " <<
      // mutable_signal_config->DebugString ();
    }
    else {
      SINFO << "SimulatorClient setSignalConfig: error code:" << result.result_code() << ", msg:" << result.result_msg();
    }
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::setSimulateRate(int rate)
{
  func_task task = [this, rate]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_set_time_acc_rate);
    rpcRequest.add_params_int(rate);
    std::string params;
    rpcRequest.SerializeToString(&params);

    const std::string& reply_str = request(params);
    Result result = Result();
    result.ParseFromString(reply_str);
    if (result.result_code() == ResultCode::success) {
      SINFO << "SimulatorClient setSimulateRate " << rate << ": success ";
    }
    else {
      SINFO << "SimulatorClient setSimulateRate: error code:" << result.result_code()
            << ", msg:" << result.result_msg();
    }
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::setKeepTrafficLightGreen(int keep)
{
  func_task task = [this, keep]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_set_keep_trafficelight_green);
    rpcRequest.add_params_int(keep);
    std::string params;
    rpcRequest.SerializeToString(&params);

    const std::string& reply_str = request(params);
    Result result = Result();
    result.ParseFromString(reply_str);
    if (result.result_code() == ResultCode::success) {
      SINFO << "SimulatorClient setKeepTrafficLightGreen " << keep << ": success ";
    }
    else {
      SINFO << "SimulatorClient setKeepTrafficLightGreen: error code:" << result.result_code()
            << ", msg:" << result.result_msg();
    }
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::acquireRecordList()
{
  func_task task = [this]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_acquire_all_record);
    std::string params;
    rpcRequest.SerializeToString(&params);
    const std::string reply_str = request(params);
    RPCReplyRecordList reply;
    reply.ParseFromString(reply_str);
    SINFO << "SimulatorClient acquireRecordList: "
          << " record nums " << reply.records_size();
    std::shared_ptr<QList<QString>> records = std::shared_ptr<QList<QString>>(new QList<QString>());
    for (int i = 0; i < reply.records_size(); ++i) { records->push_back(QString::fromStdString(reply.records(i))); }
    Q_EMIT notifier_.onRecvRecordList(records);
  };
  task_queue_.enqueue(std::move(task));
}

void SimulatorClient::acquireRecord(const std::string& record_name)
{
  func_task task = [this, record_name]() {
    RPCRequest rpcRequest;
    rpcRequest.set_type(RPCRequest::FUNC_set_play_record_list);
    rpcRequest.add_params_str(record_name);
    std::string params;
    rpcRequest.SerializeToString(&params);
    const std::string& reply_str = request(params);
    std::shared_ptr<RPCReplyRecord> record = std::make_shared<RPCReplyRecord>();
    record->ParseFromString(reply_str);

    Q_EMIT notifier_.onRecvRecord(record);
  };
  task_queue_.enqueue(std::move(task));
}

///// for Subscripter from server pub
void SimulatorClient::onRecv(const std::string& data)
{
  ServerPublish publish;
  publish.ParseFromString(data);
  switch (publish.type()) {
    case ServerPublish::LOAD_MAP: {
      std::shared_ptr<HdMap> hdmap = std::make_shared<HdMap>();
      hdmap->ParseFromString(publish.map_content());
      required_map_name_ = publish.map_name();
      Q_EMIT notifier_.onRecvMap(hdmap);
      break;
    }
    case ServerPublish::FRAME_SYNC: {
      if (publish.has_frame_sync()) {
        const FrameSync& frame_sync = publish.frame_sync();
        // SINFO << "SimulatorClient subscripter FrameSync: "
        //       << frame_sync.frame_id();
        Q_EMIT notifier_.onFrame(frame_sync.frame_id());
      }
      break;
    }
    case ServerPublish::OBSTACLE_INFO: {
      if (publish.has_obstacles_info()) {
        const ObstaclesInfo& obstacles_info = publish.obstacles_info();
        SINFO << "SimulatorClient subscripter ObstaclesInfo: yes";
        for (int i = 0; i < obstacles_info.obstacle_info_size(); ++i) {
          auto obstacle_info = obstacles_info.obstacle_info(i);
          const ControlMode& mode = obstacle_info.control_mode();
          SINFO << "obstacles_info mode " << mode.mode();
        }
      }
      break;
    }
    case ServerPublish::POSE_INFO: {
      if (publish.has_obstacles_info()) {
        // SINFO << "SimulatorClient subscripter POSE_INFO ";
        // SINFO << publish.obstacles_info().hero_car().DebugString ();
        //  todo show pose on UI
        std::shared_ptr<ObstaclesInfo> participants_pose = std::make_shared<ObstaclesInfo>();  //std::shared_ptr<ObstaclesInfo>(new ObstaclesInfo());
        participants_pose->CopyFrom(publish.obstacles_info());
        Q_EMIT notifier_.onPoseUpdate(participants_pose);
      }

      if (publish.has_record_car_pose()) {
        std::shared_ptr<PoseStamped> record_car_pose = std::shared_ptr<PoseStamped>(new PoseStamped());
        record_car_pose->CopyFrom(publish.record_car_pose());
        Q_EMIT notifier_.onRecordPoseUpdate(record_car_pose);
      }
      break;
    }
    case ServerPublish::SIGNAL_STATE: {
      int size = publish.signal_state_size();
      // qDebug() << "size = " << size << Qt::endl;
      if (size > 0) {
        std::vector<SignalState> vecSignalState;
        for (auto index = 0; index < size; ++index) {
          vecSignalState.emplace_back(publish.signal_state(index));
        }
        // qDebug() << "vecSignalState size = " << vecSignalState.size() << Qt::endl;
        Q_EMIT notifier_.onSignalStateUpdate(vecSignalState);
      }
      break;
    }
    case ServerPublish::SIGNAL_CONFIG: {
      int size = publish.signal_config_size();
      qDebug() << "OnRecv:SIGNAL_CONFIG" << Qt::endl;
      if (size > 0) { 
        std::shared_ptr<std::vector<SignalConfig>> signal_configs = std::make_shared<std::vector<SignalConfig>>();
        for (auto index = 0; index < size; ++index) {
          signal_configs->emplace_back(publish.signal_config(index));
        }
        // qDebug() << "vecSignalState size = " << vecSignalState.size() << Qt::endl;
        Q_EMIT notifier_.onRecvSignalConfig(signal_configs);
      }
      break;
    }
    default: break;
  }
}

void SimulatorClient::onError(Errno err)
{
  // todo
}