
#include "ui_scenario_control.h"
#include "ui_simulator_control.h"

#include "config.h"
#include "google/protobuf/io/coded_stream.h"
#include "google/protobuf/io/zero_copy_stream.h"
#include "google/protobuf/io/zero_copy_stream_impl.h"
#include "google/protobuf/text_format.h"
#include "logger.h"
#include "qpoint.h"
#include "simulator_client.h"
#include <chrono>
#include <fcntl.h>
#include <fstream>
#include <sstream>
#include <unistd.h>

#include <sys/time.h>

#include "FileCommon.h"
#include "Util.h"
#include "routing.pb.h"
#include <QClipboard>
#include <QFileInfo>
#include <QtWidgets/QApplication>

// #include <QFileDialog>
// #include <QMessageBox>

using HeroCar = simulator::rpc::client::HeroCar;
using ObstacleInfo = simulator::rpc::client::ObstacleInfo;
using ObstaclesInfo = simulator::rpc::client::ObstaclesInfo;

using std::ifstream;
using std::ios;
using std::ofstream;
using std::stringstream;
using std::chrono::duration_cast;
using std::chrono::milliseconds;
using std::chrono::seconds;
using std::chrono::system_clock;

static int alloc_curve_id = 0;

ScenarioControl::ScenarioControl(QObject* parent) : QObject(parent)
{
  QObject::connect(this, &ScenarioControl::notifyDeleteCurveModel, this, &ScenarioControl::onNotifyDeleteCurveModel);
}

// private
ObstacleModel* ScenarioControl::addObstacle(int type, int id, double x, double y, int mode, bool isstatic)
{
  auto itData = g_obstacleDefaultDataMap.find(static_cast<ObstacleType>(type));
  if (itData == g_obstacleDefaultDataMap.end()) {
    SINFO << "onAddObstacle unknown obstacle type:" << type;
    return nullptr;
  }

  ObstacleModel* model = new ObstacleModel(this);
  if (isstatic) {
    model->setIsStatic(true);
    model->setAcc(0.0);
    model->setTargetSpeed(0.0);
    model->setMode(1);
  }
  else {
    model->setIsStatic(false);
    model->setAcc(3.0);
    model->setTargetSpeed(3.0);
    model->setMode(mode);
  }
  model->setId(id);
  model->setX(x);
  model->setY(y);
  model->setZ(0);
  model->setWidth(itData->second.width_);
  model->setLength(itData->second.length_);
  model->setTheta(0);
  model->setType(static_cast<ObstacleType>(type));
  // SINFO << "onAddObstacle type " << type << " id " << model->getId();
  return model;
}

int ScenarioControl::addObstacle(int type, double x, double y, int mode)
{
  ObstacleModel* model = addObstacle(type, allocId(), x, y, mode, false);
  if (model != nullptr) {
    obstacles_data_map_.emplace(model->getId(), model);
    Q_EMIT notifyAddObstacle(model->getId(), model);
    return model->getId();
  }
  return -1;
}

int ScenarioControl::addObstacleStatic(int type, double x, double y)
{
  ObstacleModel* model = addObstacle(type, allocId(), x, y, 0, true);
  if (model != nullptr) {
    obstacles_data_map_.emplace(model->getId(), model);
    Q_EMIT notifyAddObstacle(model->getId(), model);
    return model->getId();
  }
  return -1;
}

int ScenarioControl::copyObstacle(int obs_id)
{
  auto old = findObstacleModel(obs_id);
  if (old == nullptr) { return -1; }

  ObstacleModel* model = new ObstacleModel(this);
  model->setIsStatic(old->getIsStatic());
  model->setAcc(old->getAcc());
  model->setTargetSpeed(old->getTargetSpeed());
  model->setMode(old->getMode());
  model->setId(allocId());
  model->setX(old->getX() + 5.0);
  model->setY(old->getY());
  model->setZ(0);
  model->setWidth(old->getWidth());
  model->setLength(old->getLength());
  model->setTheta(old->getTheta());
  model->setType(old->getType());
  SINFO << "copyObstacle "
        << " id " << model->getId();

  obstacles_data_map_.emplace(model->getId(), model);
  Q_EMIT notifyAddObstacle(model->getId(), model);
  return model->getId();
}

void ScenarioControl::addHeroCar(int type, double x, double y)
{
  if (hero_car_model_ != nullptr) {
    delete hero_car_model_;
    hero_car_model_ = nullptr;
    Q_EMIT notifyDeleteHeroCar();
  }
  
  hero_car_model_ = new HeroCarModel(type, x, y, this);
  Q_EMIT notifyAddHeroCar(hero_car_model_);

  // QVariantList empty;
  // setHeroRoutingPoints(empty);
  // SINFO << "onAddHeroCar";
}

void ScenarioControl::addGarbage(int type, double x, double y)
{
  auto itData = g_garbageDefaultDataMap.find(static_cast<GarbageType>(type - GARBAGE_TYPE_START));
  if (itData == g_garbageDefaultDataMap.end()) {
    SINFO << "add unknown garbage type:" << type;
    return;
  }
  GarbageModel* garbage_model = new GarbageModel(this);
  garbage_model->setId(allocId());
  garbage_model->setType(type);
  garbage_model->setWidth(itData->second.width_);
  garbage_model->setLength(itData->second.length_);
  garbage_model->setTheta(0);
  garbage_model->setX(x);
  garbage_model->setY(y);
  garbage_model->setZ(0);
  garbages_data_map_.emplace(garbage_model->getId(), garbage_model);
  Q_EMIT notifyAddGarbage(garbage_model->getId(), garbage_model);
  SINFO << "addGarbage";
}

void ScenarioControl::deleteHeroCar()
{
  if (hero_car_model_ != nullptr) {
    delete hero_car_model_;
    hero_car_model_ = nullptr;
    Q_EMIT notifyDeleteHeroCar();
  }
}

void ScenarioControl::deleteObstacle(int id)
{
  auto it = obstacles_data_map_.find(id);
  if (it != obstacles_data_map_.end()) {
    SINFO << "deleteObstacle, id=" << id;
    Q_EMIT notifyDeleteObstacle(id);

    auto curveid = it->second->getCurveId();
    if (curveid >= 0) { unbindCurvePoints(curveid, id); }

    delete it->second;
    obstacles_data_map_.erase(it);
  }
}

void ScenarioControl::deleteGarbage(int id)
{
  auto it = garbages_data_map_.find(id);
  if (it != garbages_data_map_.end()) {
    SINFO << "deleteGarbage, id=" << id;
    Q_EMIT notifyDeleteGarbage(id);
    delete it->second;
    garbages_data_map_.erase(it);
  }
}

void ScenarioControl::clear()
{
  obstacles_info_history_.clear();
  alloc_curve_id = 0;
  if (hero_car_model_ != nullptr) {
    delete hero_car_model_;
    hero_car_model_ = nullptr;
  }
  for (auto it : obstacles_data_map_) { delete it.second; }
  obstacles_data_map_.clear();

  for (auto it : garbages_data_map_) { delete it.second; }
  garbages_data_map_.clear();

  for (auto it : curves_model_) {
    Q_EMIT notifyDeleteCurveModel(it.first);
    delete it.second;
  }
  curves_model_.clear();
  if (parking_circle_model_ != nullptr)
  {
    delete parking_circle_model_;
    parking_circle_model_ = nullptr;
  }
  
  Q_EMIT notifyClear();
}

bool ScenarioControl::openScenarioFile(const QString& filename)
{
  SINFO << "openScenarioFile: " << filename.toStdString();
  // read binary data from file
  std::string path = filename.toStdString();
  QString qstr = QString::fromStdString(path);

  int fd = open(path.c_str(), O_RDONLY);
  if (fd < 0) return false;
  google::protobuf::io::ZeroCopyInputStream* stream = new google::protobuf::io::FileInputStream(fd);
  // parse string to proto structure
  auto scenario_save = ScenarioSave();
  bool has_hero_car = false;
  VehicleType vehicle_type = VehicleType::HeroCar_VehicleType_X3;

  if (Util::endsWith(path, ".str")) { bool ok = google::protobuf::TextFormat::Parse(stream, &scenario_save); }
  else {
    scenario_save.ParseFromZeroCopyStream(stream);
  }
  close(fd);
  delete stream;
  // if (!ok) return ok;

  auto obstacles_info = scenario_save.obstacles_info();

  //  translate  proto stucture to UI model data
  clear();
  if (obstacles_info.has_hero_car()) {
    has_hero_car = true;
    auto& hero_car = obstacles_info.hero_car();
    vehicle_type = hero_car.vehicle_type();
    if (hero_car_model_ != nullptr) { delete hero_car_model_; }
    hero_car_model_ = new HeroCarModel(this);
    hero_car_model_->fromProto(hero_car);
    // SINFO << "obstacles_info.hero_car()" << obstacles_info.hero_car().DebugString();
    Q_EMIT notifyAddHeroCar(hero_car_model_);

    // 主车的 目的点
    QVariantList points;

    if (hero_car.has_routing()) {
      // 主车有routing request
      points = parseRoutingRequest(hero_car.routing());
      if (!points.empty()) {
        Q_EMIT notifySetHeroRoutingPoints(points);  // 通知UI 绘制红点
        printf("set routing request success\n");
      }
    }
    else {
      // 主车不存在routing request
      for (auto& p3d : hero_car.target_curve_points()) {
        QVariant point = QVariant::fromValue(QPointF(p3d.x(), p3d.y()));
        points.append(point);
      }
      this->setHeroRoutingPoints(points);
    }
  }

  for (int i = 0; i < obstacles_info.obstacle_info_size(); ++i) {
    auto obstacle_info = obstacles_info.obstacle_info(i);
    ObstacleModel* model = new ObstacleModel(this);
    model->fromProto(obstacle_info);
    obstacles_data_map_.emplace(model->getId(), model);
    Q_EMIT notifyAddObstacle(model->getId(), model);
    if (next_alloc_id_ <= model->getId()) { next_alloc_id_ = model->getId() + 1; }

    // 他车的 目的轨迹线
    auto& ctl_mode = obstacle_info.control_mode();
    if (ctl_mode.mode() == ControlMode::FOLLOW_CURVE || ctl_mode.mode() == ControlMode::PNC) {
      if (ctl_mode.mode() == ControlMode::FOLLOW_CURVE) {
        QVariantList points;
        auto& orgins = ctl_mode.param_follow_curve().curve_points();
        for (auto& p3d : orgins) {
          QVariant point = QVariant::fromValue(QPointF(p3d.x(), p3d.y()));
          points.append(point);
        }
        QVariantList speeds;
        auto& pb_speeds = ctl_mode.param_follow_curve().speed_points();
        for (double v : pb_speeds) { speeds.append(v); }
        int curve_id = this->addObstacleCurveModel(points, speeds);
        this->bindCurvePoints(curve_id, model->getId());
      }
      else if (ctl_mode.mode() == ControlMode::PNC) {
        QVariantList points;
        auto& orgins = ctl_mode.param_pnc().routing_points();
        for (auto& p3d : orgins) {
          QVariant point = QVariant::fromValue(QPointF(p3d.x(), p3d.y()));
          points.append(point);
        }
        QVariantList speeds;
        int curve_id = this->addObstacleCurveModel(points, speeds);
        this->bindCurvePoints(curve_id, model->getId());
      }
    }
  }

  // 垃圾
  for (int i = 0; i < obstacles_info.garbage_info_size(); ++i) {
    auto garbage_info = obstacles_info.garbage_info(i);
    GarbageModel* model = new GarbageModel(this);
    model->fromProto(garbage_info);
    garbages_data_map_.emplace(model->getId(), model);
    Q_EMIT notifyAddGarbage(model->getId(), model);
  }

  simulation_test_context_ = obstacles_info.simulation_evaluation();
  if (!parseSimulationTestContext()) { return false; }

  // 红绿的设置信息
  auto simulatorControl = SingletonSimulatorControl::getInstance();
  SINFO << "parse signal config in scenario file.";
  for (int i = 0; i < scenario_save.signalconfig_size(); ++i) {
    auto& config = scenario_save.signalconfig(i);
    TrafficLightModel* model = simulatorControl->acquireTrafficLight(config.id());
    // 清除上一次的signal config信息
    model->clear();
    // SINFO << "signal config: " << config.DebugString();
    model->fromSignalConfig(config);
    simulatorControl->markTrafficLightDirty(QString::fromStdString(config.id()));
  }

  // 小巴的parking area
  if (has_hero_car && vehicle_type == VehicleType::HeroCar_VehicleType_MINI_BUS &&
     scenario_save.has_parking_area())
  {
    if(parseParkingArea(scenario_save.parking_area()))
    {
      // 通知UI绘制圈
      Q_EMIT notifySetParkingArea(parking_circle_model_->getIds(), 
                                  parking_circle_model_->getPoints(), 
                                  parking_circle_model_->getRaduii());
    }
  }

  return true;
}

bool ScenarioControl::saveScenarioFile(const QString& filename, const QString& description, const QString& total_time)
{
  ScenarioSave scenario_save;
  // 文件头部
  auto header = scenario_save.mutable_header();
  header->set_name(filename.toStdString());
  header->set_version("1.0");
  header->set_description(description.toStdString());
  qDebug() << "total_time: " << total_time << " ms " << total_time.toInt() * 1000;
  scenario_save.set_total_time(total_time.toInt() * 1000);  // to do: UI set time ms

  auto map_name = SimulatorClient::GetInstance()->getRequiredMapName();
  scenario_save.set_map_name(map_name);
  // translate UI model data to proto stucture
  ObstaclesInfo obstacles_info = std::move(getCurrentObstaclesInfo());
  for (int i = 0; i < obstacles_info.obstacle_info_size(); ++i) {
    // 回放时 保存场景，要把障碍物的控制属性改掉， 否则下次仿真该场景时不生效
    auto obstacle_info = obstacles_info.mutable_obstacle_info(i);
    auto control_mode = obstacle_info->mutable_control_mode();
    if (control_mode->mode() == ObstacleControlMode::ControlMode_Mode_REPLAY) {
      control_mode->set_mode(ObstacleControlMode::ControlMode_Mode_REINFORCEMENT);
    }
  }

  scenario_save.clear_obstacles_info();
  ObstaclesInfo* obs = scenario_save.mutable_obstacles_info();
  obs->CopyFrom(obstacles_info);

  //评价指标
  for (int m = ScenarioSave_Metric_Metric_MIN; m < ScenarioSave_Metric_Metric_MAX;
       ++m) {  // add all ScenarioSave_Metric
    scenario_save.add_metrics(static_cast<simulator::rpc::client::ScenarioSave_Metric>(m));
  }

  obs->set_simulation_evaluation(simulation_test_context_);

  // 保存parking circle
  if (parking_circle_model_ != nullptr)
  {
    scenario_save.clear_parking_area();
    auto parking_area = scenario_save.mutable_parking_area();
    parking_circle_model_->toProto(parking_area);
  }
  
  // 红绿的设置信息
  auto simulatorControl = SingletonSimulatorControl::getInstance();
  for (auto signal_id : simulatorControl->getDirtySignal()) {
    TrafficLightModel* model = simulatorControl->acquireTrafficLight(signal_id);
    SignalConfig* config = scenario_save.add_signalconfig();
    model->toSignalConfig(config);
  }

  // serialize proto and write to file
  std::string path = filename.toStdString();
  ofstream pb_ofstream(path, ios::out);
  std::string buffer;

  scenario_save.SerializeToString(&buffer);
  // google::protobuf::TextFormat::PrintToString(scenario_save, &buffer);
  //  scenario_save.SerializeToString(&buffer);
  qDebug() << "存储文件大小:" << buffer.size();
  pb_ofstream << buffer;
  pb_ofstream.flush();
  pb_ofstream.close();

  const bool debug = true;
  if (debug) {
    std::string str_buffer;
    google::protobuf::TextFormat::PrintToString(scenario_save, &str_buffer);
    std::string path = filename.toStdString() + ".str";
    ofstream str_ofstream(path, ios::out);
    str_ofstream << str_buffer;
    str_ofstream.flush();
    str_ofstream.close();
  }

  return true;
}

bool ScenarioControl::openRoutingFile(const QString& filename)
{
  if (hero_car_model_ == nullptr) {
    printf("has not hero car\n");
    return false;
  }

  std::string filePath = filename.toStdString();

  bool isFileExist = Util::DirOrFileExist(filePath);
  if (!isFileExist) {
    printf("file not exist, path = %s\n", filePath.c_str());
    return false;
  }

  std::string context = Util::ReadFile(filePath.c_str());
  if (context.empty()) {
    printf("read routing file error, path = %s\n", filePath.c_str());
    return false;
  }

  COWA::routing::RoutingRequest routingRequest;
  google::protobuf::TextFormat::Parser routingRequestTextParser;
  bool readResult = routingRequestTextParser.ParseFromString(context, &routingRequest);
  if (!readResult) {
    printf("parse routing file error\n");
    return false;
  }

  QVariantList points = parseRoutingRequest(routingRequest);
  // for (auto it = vecHeroPoint.begin(); it != vecHeroPoint.end(); ++it) {
  //   QVariant point = QVariant::fromValue(QPointF(it->first, it->second));
  //   points.append(point);
  // }

  if (!points.empty()) {
    hero_car_model_->routing_model_->fromProto(routingRequest);
    SINFO << "open routing file success";
    Q_EMIT notifySetHeroRoutingPoints(points);  // 通知UI 绘制红点
  }

  return true;
}

QVariantList ScenarioControl::parseRoutingRequest(const RoutingRequest& routingRequest)
{
  QVariantList points;
  // std::vector<std::pair<double, double>> vecHeroPoint;
  for (int index = 0; index < routingRequest.waypoint_size(); ++index) {
    ::COWA::routing::LaneWaypoint laneWayPoint = routingRequest.waypoint(index);
    if (laneWayPoint.has_pose()) {
      ::COWA::MapData::PointENU point = laneWayPoint.pose();
      // vecHeroPoint.emplace_back(std::pair<double, double>(point.x(), point.y()));
      printf("x = %lf, y = %lf\n", point.x(), point.y());
      QVariant qPoint = QVariant::fromValue(QPointF(point.x(), point.y()));
      points.append(qPoint);
    }
  }
  return points;
}

bool ScenarioControl::parseParkingArea(const ParkingArea& parkingArea)
{
  if (parking_circle_model_ != nullptr) { delete parking_circle_model_; }
  parking_circle_model_ = new ParkingCircleModel(this);
  parking_circle_model_->fromProto(parkingArea);
  SINFO << "parse parking area success";
  return true;
}

void ScenarioControl::copyToBoard(const QString& text)
{
  QClipboard* pClipboard = QApplication::clipboard();
  if (pClipboard == nullptr) { return; }
  pClipboard->setText(text);
}

ObstaclesInfo ScenarioControl::getCurrentObstaclesInfo()
{
  ObstaclesInfo obstacles_info;
  if (hero_car_model_ != nullptr) {
    HeroCar* hero_car = obstacles_info.mutable_hero_car();
    hero_car_model_->toProto(hero_car);
  }

  if (!simulation_test_context_.empty()) {
    std::string evalution = simulationTestToEvaluation();
    if (!evalution.empty()) { obstacles_info.set_simulation_evaluation(evalution); }
  }

  for (auto it : obstacles_data_map_) {
    ObstacleInfo* obstacle_info = obstacles_info.add_obstacle_info();
    ObstacleModel* model = it.second;
    model->toProto(obstacle_info);
    SINFO << "obstacle_info " << obstacle_info->DebugString();
  }

  for (auto it : garbages_data_map_) {
    GarbageInfo* garbage_info = obstacles_info.add_garbage_info();
    GarbageModel* model = it.second;
    model->toProto(garbage_info);
    SINFO << "garbage_info " << garbage_info->DebugString();
  }

  return obstacles_info;
}

void ScenarioControl::updateObstacleVisible() {
  
  for (auto it : obstacles_data_map_) {
    ObstacleModel* model = it.second;
    switch(model->getTriggerType()) {
      case ControlMode_Trigger::ControlMode_Trigger_TIME: {
        model->setVisible((model->getTriggerParameter() == 0));
        break;
      }
      case ControlMode_Trigger::ControlMode_Trigger_DISTANCE: {
        if (hero_car_model_ == nullptr) {
          model->setVisible(true);
          continue;
        }
        auto distance = std::sqrt(std::pow(hero_car_model_->get_x() - model->getX(), 2) + 
            std::pow(hero_car_model_->get_y() - model->getY(), 2));
        model->setVisible((distance <= model->getTriggerParameter()));
        break;
      }
      case ControlMode_Trigger::ControlMode_Trigger_LOCATION: {
        model->setVisible(true);
        if (hero_car_model_ == nullptr) {
          continue;
        }
        auto points = Util::Split(model->getTriggerParameterStr().toStdString(), ",");
        if (points.size() > 1) {
          auto distance = std::sqrt(std::pow(hero_car_model_->get_x() - std::stod(points[0]), 2) + 
            std::pow(hero_car_model_->get_y() - std::stod(points[1]), 2));
          model->setVisible((distance <= 1.0));
        }
        break;
      }
      default: {
        model->setVisible(true);
        break;
      }
    }
    if ((model->getTriggerType() == ControlMode_Trigger::ControlMode_Trigger_TIME && model->getTriggerParameter() > 0) ||
      (model->getTriggerType() == ControlMode_Trigger::ControlMode_Trigger_DISTANCE && model->getTriggerParameter() > 10)) {
      model->setVisible(false);
    }
    Q_EMIT notifyUpdateObstacleVisible(model->getId(), model->getVisible());
  }
}

void ScenarioControl::saveToHistory()
{
  obstacles_info_history_.emplace_back(getCurrentObstaclesInfo());
}

void ScenarioControl::restoreToHistory()
{
  if (obstacles_info_history_.empty()) {
    SINFO << "restoreToHistory error , no obstacles_info_history_ ";
    return;
  }
  auto saved_obstacles_info = obstacles_info_history_.back();
  obstacles_info_history_.pop_back();

  if (hero_car_model_ != nullptr) {
    hero_car_model_->fromProto(saved_obstacles_info.hero_car());
    SINFO << "restoreToHistory saved_obstacles_info " << saved_obstacles_info.hero_car().DebugString();
    Q_EMIT notifyUpdateHeroCar(hero_car_model_);
  }
  for (int i = 0; i < saved_obstacles_info.obstacle_info_size(); ++i) {
    auto& obs = saved_obstacles_info.obstacle_info(i);
    auto it = obstacles_data_map_.find(obs.obstacle().id());
    if (it != obstacles_data_map_.end()) {
      ObstacleModel* model = it->second;
      model->fromProto(obs);
      Q_EMIT notifyUpdateObstacle(obs.obstacle().id(), model);
    }
  }
  // 恢复garbage
  for (int i = 0; i < saved_obstacles_info.garbage_info_size(); ++i) {
    auto& garbage = saved_obstacles_info.garbage_info(i);
    auto it = garbages_data_map_.find(garbage.detect_object().track_id());
    if (it == garbages_data_map_.end()) {
      SINFO << "restoreToHistory garbage info: " << garbage.detect_object().track_id();
      GarbageModel* model = new GarbageModel(this);
      model->fromProto(garbage);
      garbages_data_map_.emplace(model->getId(), model);
      Q_EMIT notifyUpdateGarbage(garbage.detect_object().track_id(), model);
    }
  }
}

bool ScenarioControl::openSimulationTestFile(const QString& filename)
{
  if (hero_car_model_ == nullptr) {
    printf("has not hero car\n");
    return false;
  }

  std::string filePath = filename.toStdString();

  bool isFileExist = Util::DirOrFileExist(filePath);
  if (!isFileExist) {
    printf("file not exist, path = %s\n", filePath.c_str());
    return false;
  }

  simulation_test_context_ = Util::ReadFile(filePath.c_str());
  if (simulation_test_context_.empty()) {
    printf("read simulation test file error, path = %s\n", filePath.c_str());
    return false;
  }

  if (!parseSimulationTestContext()) { return false; }

  QFileInfo fileInfo(filename);
  simulation_test_name_ = fileInfo.baseName().toStdString();
  printf("open simulation test file success\n");
  return true;
}

QString ScenarioControl::simulationTestBoardText()
{
  return FileCommon::simulationTestBoardText().c_str();
}

bool ScenarioControl::parseSimulationTestContext()
{
  simulator::rpc::client::SimulationTests simulationTests;
  google::protobuf::TextFormat::Parser simulationTestsTextParser;
  bool readResult = simulationTestsTextParser.ParseFromString(simulation_test_context_, &simulationTests);
  if (!readResult) {
    printf("parse simulation test context error\n");
    return false;
  }

  Q_EMIT notifyClearSimulationTestInfo();

  // for (int index = 0; index < simulationTests.simulation_test_size(); ++index) {
  //   ::simulator::rpc::client::SimulationTest simulationTest = simulationTests.simulation_test(index);
  //   QJsonValue id = simulationTest.id().c_str();
  //   QJsonValue name = "";
  //   if (simulationTest.has_name()) { name = simulationTest.name().c_str(); }
  //   QJsonArray circleInfo;
  //   for (int circleIndex = 0; circleIndex < simulationTest.test_circle_size(); ++circleIndex) {
  //     ::simulator::rpc::client::TestCircle testCircle = simulationTest.test_circle(circleIndex);
  //     std::string circle = testCircle.circle();
  //     std::vector<std::string> vecInfo = Util::Split(circle, ",");
  //     std::string circleColor = testCircle.circle_color();
  //     std::string circlePointColor = testCircle.circle_point_color();
  //     if (vecInfo.size() != 3) { continue; }
  //     circleInfo.push_back(QJsonValue(vecInfo[0].c_str()));
  //     circleInfo.push_back(QJsonValue(vecInfo[1].c_str()));
  //     circleInfo.push_back(QJsonValue(vecInfo[2].c_str()));
  //     circleInfo.push_back(QJsonValue(circleColor.c_str()));
  //     circleInfo.push_back(QJsonValue(circlePointColor.c_str()));
  //   }
  //   Q_EMIT notifySetSimulationTestInfo(id, name, circleInfo);
  // }

  return true;
}

std::string ScenarioControl::simulationTestToEvaluation()
{
  simulator::rpc::client::SimulationTests simulationTests;
  google::protobuf::TextFormat::Parser simulationTestsTextParser;
  bool readResult = simulationTestsTextParser.ParseFromString(simulation_test_context_, &simulationTests);
  if (!readResult) {
    printf("parse save simulation test context error\n");
    return "";
  }

  simulator::rpc::client::Evaluation evaluation;
  for (int index = 0; index < simulationTests.simulation_test_size(); ++index) {
    ::simulator::rpc::client::SimulationTest simulationTest = simulationTests.simulation_test(index);
    std::string id = simulationTest.id().c_str();
    if (id == "CollisionTest") {
      ::simulator::rpc::client::Evaluation_CollisionCase* collisionCase = evaluation.mutable_collision_case();
      if (simulationTest.has_name()) { collisionCase->set_name(simulationTest.name().c_str()); }
    }
    else if (id == "RunOutOfRoadTest") {
      ::simulator::rpc::client::Evaluation_RunOutOfRoadCase* runOutOfRoadCase =
          evaluation.mutable_run_out_of_road_case();
      if (simulationTest.has_name()) { runOutOfRoadCase->set_name(simulationTest.name().c_str()); }
    }
    else if (id == "RunRedLightTest") {
      ::simulator::rpc::client::Evaluation_RunRedLightCase* runRedLightCase = evaluation.mutable_run_red_light_case();
      if (simulationTest.has_name()) { runRedLightCase->set_name(simulationTest.name().c_str()); }
    }
    else if (id == "EndPointTest") {
      ::simulator::rpc::client::Evaluation_EndPointCase* endPointCase = evaluation.mutable_end_point_case();
      if (simulationTest.has_name()) { endPointCase->set_name(simulationTest.name().c_str()); }
    }
    else if (id == "NavigationFailTest") {
      ::simulator::rpc::client::Evaluation_NavigationFailCase* navigationFailCase =
          evaluation.mutable_navigation_fail_case();
      if (simulationTest.has_name()) { navigationFailCase->set_name(simulationTest.name().c_str()); }
    }
    else if (id == "EdgeTest") {
      ::simulator::rpc::client::Evaluation_EdgeCase* edgeCase = evaluation.mutable_edge_case();
      if (simulationTest.has_name()) { edgeCase->set_name(simulationTest.name().c_str()); }
      if (simulationTest.has_param()) { edgeCase->set_distance(atof(simulationTest.param().c_str())); }
    }
    else if (id == "StopTest") {
      ::simulator::rpc::client::Evaluation_StopCase* stopCase = evaluation.mutable_stop_case();
      if (simulationTest.has_name()) { stopCase->set_name(simulationTest.name().c_str()); }
    }
    else if (id == "PredictionSteadyTest") {
      ::simulator::rpc::client::Evaluation_PredictionSteadyCase* predictionSteadyCase =
          evaluation.mutable_prediction_steady_case();
      if (simulationTest.has_name()) { predictionSteadyCase->set_name(simulationTest.name().c_str()); }
    }
    else if (id == "CustomTest") {
      ::simulator::rpc::client::Evaluation_CustomCase* customCase = evaluation.add_custom_cases();
      if (simulationTest.has_name()) { customCase->set_name(simulationTest.name().c_str()); }
      // for (int index = 0; index < simulationTest.test_circle_size(); ++index) {
      //   ::simulator::rpc::client::Evaluation_CustomCase_CircleParam* circleParam = customCase->add_circle_params();
      //   auto& testCircle = simulationTest.test_circle(index);
      //   std::string circle = testCircle.circle();
      //   std::vector<std::string> vecCircleParam = Util::Split(circle, ",");
      //   if (vecCircleParam.size() != 3) { continue; }
      //   circleParam->set_x(atof(vecCircleParam[0].c_str()));
      //   circleParam->set_y(atof(vecCircleParam[1].c_str()));
      //   circleParam->set_radius(atof(vecCircleParam[2].c_str()));

      //   if (testCircle.has_is_pass()) { circleParam->set_is_pass(testCircle.is_pass()); }
      //   if (testCircle.has_min_speed()) { circleParam->set_min_speed(testCircle.min_speed()); }
      //   if (testCircle.has_max_speed()) { circleParam->set_max_speed(testCircle.max_speed()); }
      //   if (testCircle.has_max_deceleration()) { circleParam->set_max_deceleration(testCircle.max_deceleration()); }
      //   if (testCircle.has_max_accleration()) { circleParam->set_max_accleration(testCircle.max_accleration()); }
      //   if (testCircle.has_grap_obstacles()) {
      //     std::vector<std::string> vecGrap = Util::Split(testCircle.grap_obstacles(), ",");
      //     for (std::size_t grapIndex = 0; grapIndex < vecGrap.size(); ++grapIndex) {
      //       circleParam->add_grap_obstacles(vecGrap[grapIndex]);
      //     }
      //   }
      //   if (testCircle.has_giveaway_obstacles()) {
      //     std::vector<std::string> vecGiveaway = Util::Split(testCircle.giveaway_obstacles(), ",");
      //     for (std::size_t giveawayIndex = 0; giveawayIndex < vecGiveaway.size(); ++giveawayIndex) {
      //       circleParam->add_giveaway_obstacles(vecGiveaway[giveawayIndex]);
      //     }
      //   }
      //   if (testCircle.has_change_lane()) { circleParam->set_change_lane(testCircle.change_lane()); }
      // }
    }
  }

  std::string result;
  if (!evaluation.SerializeToString(&result)) { return ""; }
  // printf("debug = %s\n", evaluation.DebugString().c_str());
  return result;
}

std::string ScenarioControl::getSimulationTestName()
{
  return simulation_test_name_;
}

void ScenarioControl::onPoseUpdate(std::shared_ptr<ObstaclesInfo> obstacles_info)
{
  // SINFO << "new ObstaclesInfo "<< obstacles_info->DebugString();
  // auto now = std::chrono::duration_cast<std::chrono::milliseconds>(system_clock::now().time_since_epoch()).count();
  // if (now - now_t < 20) { return; }
  // now_t = now;

  if (obstacles_info->has_hero_car()) {
    const HeroCar& hero_car = obstacles_info->hero_car();
    if (hero_car_model_ != nullptr) {
      double origin_x = hero_car_model_->get_x();
      double origin_y = hero_car_model_->get_y();
      bool has_big_move = false;
      double distance = 0.0;

      if (is_simulate_mode_ ||
          enable_simulator_when_replay_) {  // 仿真模式下主车由仿真控制； 回放模式下，开启了仿真 也归仿真管
        auto position = hero_car.position();

        hero_car_model_->set_x(position.x());
        hero_car_model_->set_y(position.y());
        hero_car_model_->set_z(position.z());
        hero_car_model_->set_theta(hero_car.heading());
        hero_car_model_->set_speed(hero_car.speed());
        hero_car_model_->set_throttle(hero_car.throttle());
        hero_car_model_->set_steer(hero_car.steer());

        //直接从服务端取，需要转化为指针
        // planning
        if (hero_car.prediction_curve_points_size() != 0) {
          std::vector<Point2D> origin_points;
          for (auto point : hero_car.prediction_curve_points()) {
            origin_points.emplace_back(Point2D(point.x(), point.y()));
          }
          std::vector<Point2D> strip_points = std::move(filterPoint(origin_points));
          QVariantList target;
          for (auto point : strip_points) { target.push_back(QPointF(point.getX(), point.getY())); }
          hero_car_model_->setPredictionCurvePoints(target);

          // 判断主车位置是否 飘逸太大
          distance = std::sqrt(std::pow(hero_car_model_->get_x() - origin_x, 2) +
                               std::pow(hero_car_model_->get_y() - origin_y, 2));
          if (distance > 0.3) {
            SINFO << "onPoseUpdate 主车速度和位置更新不匹配 " << distance;
            has_big_move = true;
          }
        }
        // routing response
        if (hero_car.planning_curve_points_size() != 0) {
          hero_car_model_->routing_response_points_.clear();
          std::vector<Point2D> origin_points;
          for (auto point : hero_car.planning_curve_points()) {
            origin_points.emplace_back(Point2D(point.x(), point.y()));
          }
          std::vector<Point2D> strip_points = std::move(filterPoint(origin_points));
          // SINFO << "filterPoint routing points  " << origin_points.size() << " to " << strip_points.size();
          QVariantList target;
          for (auto point : strip_points) { target.push_back(QPointF(point.getX(), point.getY())); }
          hero_car_model_->setRoutingResponsePoints(target);
        }
        // routing request from server
        // if (hero_car.has_routing()) {
        //   QVariantList points;
        //   auto req = hero_car.routing();
        //   for (int index = 0; index < req.waypoint_size(); ++index) {
        //     double x = req.waypoint(index).pose().x();
        //     double y = req.waypoint(index).pose().y();
        //     QVariant point = QVariant::fromValue(QPointF(x, y));
        //     points.append(point);
        //   }
        //   Q_EMIT notifySetHeroRoutingPoints(points);  // 通知UI 绘制红点
        // }

        if (hero_car.reference_points_size() > 0) {
          std::vector<Point2D> origin_points;
          for (auto point : hero_car.reference_points()) { origin_points.emplace_back(Point2D(point.x(), point.y())); }
          std::vector<Point2D> strip_points = std::move(filterPoint(origin_points));
          QVariantList target;
          for (auto point : strip_points) { target.push_back(QPointF(point.getX(), point.getY())); }
          hero_car_model_->setReferencePoints(target);
        }

        // SINFO << "onPoseUpdate";
        Q_EMIT notifyUpdateHeroCar(hero_car_model_);
        if (has_big_move) {
          Q_EMIT notifyUpdateHeroCarError(origin_x, origin_y, hero_car_model_->get_x(), hero_car_model_->get_y(),
                                          distance);
        }
      }
    }
    // SINFO << hero_car.DebugString();
  }
  // SINFO << obstacles_info->obstacle_info_size();

  // for replay
  std::set<int> current_replay_obstacle_id;
  for (int i = 0; i < obstacles_info->obstacle_info_size(); ++i) {
    const ObstacleInfo& obstacle_info = obstacles_info->obstacle_info(i);
    auto obs = obstacle_info.obstacle();
    auto control_mode = obstacle_info.control_mode();
    int id = obs.id();
    auto pose = obs.pose();
    // SINFO << obs.DebugString();
    auto position = pose.position();
    ObstacleModel* model = nullptr;
    if (obs.track_id() > 0) {  // for replay
      id = obs.track_id();
      model = findObstacleModel(id);
      bool isAdd = false;
      if (model == nullptr) {  // add obstacle
        model = addObstacle(obs.type(), id, position.x(), position.y(), ObstacleControlMode::ControlMode_Mode_REPLAY);
        if (model == nullptr) { continue; }
        obstacles_data_map_.emplace(model->getId(), model);
        isAdd = true;
      }
      model->setX(position.x());
      model->setY(position.y());
      model->setZ(position.z());
      model->setTheta(obs.theta());
      model->setSpeed(control_mode.speed());
      model->predict_curve_points_.clear();
      if (obs.trajectory_size() > 0) {
        for (auto& obs_trajectory : obs.trajectory()) {
          for (auto& point : obs_trajectory.point()) {
            auto p = QPointF(point.x(), point.y());
            model->addPredictionCurvePoints(p);
          }
        }
      }
      obstacles_data_map_.emplace(model->getId(), model);
      if (isAdd) { Q_EMIT notifyAddObstacle(model->getId(), model); }
      else {
        Q_EMIT notifyUpdateObstacle(model->getId(), model);
      }
      current_replay_obstacle_id.insert(id);
    }
    else {  // for simulator
      model = findObstacleModel(id);
      if (model != nullptr) {
        if ( std::abs(position.x() - model->getX()) > 0.01 || std::abs(position.y() - model->getY()) > 0.01 ) {
          model->setVisible(true);
          Q_EMIT notifyUpdateObstacleVisible(id, model->getVisible());
        }
        model->setX(position.x());
        model->setY(position.y());
        model->setZ(position.z());
        model->setTheta(obs.theta());
        model->setSpeed(control_mode.speed());
        model->setLength(obs.length());
        model->setWidth(obs.width());
        model->setHeight(obs.height());
        model->predict_curve_points_.clear();
        if (obs.trajectory_size() > 0) {
          for (auto& obs_trajectory : obs.trajectory()) {
            for (auto& point : obs_trajectory.point()) {
              model->addPredictionCurvePoints(QPointF(point.x(), point.y()));
            }
          }
        }
        Q_EMIT notifyUpdateObstacle(id, model);
      }
    }
  }

  // delete disappear item
  for (auto id : replay_obstacle_id_set_) {
    if (current_replay_obstacle_id.find(id) == current_replay_obstacle_id.end()) { deleteObstacle(id); }
  }
  replay_obstacle_id_set_ = std::move(current_replay_obstacle_id);

  for (int i = 0; i < obstacles_info->garbage_info_size(); ++i) {
    // 本次update收集到的garbage
    const GarbageInfo& garbage_info = obstacles_info->garbage_info(i);
    auto det_obj = garbage_info.detect_object();
    int id = det_obj.track_id();
    deleteGarbage(id);
  }

  Q_EMIT notifyUpdateAll();
}

void ScenarioControl::onRecordPoseUpdate(std::shared_ptr<PoseStamped> record_hero_car_pose)
{
  double x = record_hero_car_pose->pose().position().x();
  double y = record_hero_car_pose->pose().position().y();
  double z = record_hero_car_pose->pose().position().z();
  double v_x = record_hero_car_pose->velocity().linear().x();
  double v_y = record_hero_car_pose->velocity().linear().y();
  double v_z = record_hero_car_pose->velocity().linear().z();

  SINFO << "ScenarioControl onRecordPoseUpdate " << x << " " << y << " timestamp ";
  // record_hero_car_pose->timestamp();
  // Q_EMIT notifyUpdateRecordHeroCar(x, y, record_hero_car_pose->timestamp());
  using simulator::rpc::client::HeroCar_VehicleType_X3;
#define HERO_CAR_TYPE_START 101
  if (hero_car_model_ == nullptr) {
    SINFO << "onRecordPoseUpdate onAddHeroCar+++++++++++++++++++++";
    addHeroCar(HeroCar_VehicleType_X3 + HERO_CAR_TYPE_START, x, y);
    SINFO << "onRecordPoseUpdate onAddHeroCar------------------------";
    hero_car_model_->set_x(x);
    hero_car_model_->set_y(y);
    hero_car_model_->set_z(z);
    auto qx = record_hero_car_pose->pose().rotation().qx();
    auto qy = record_hero_car_pose->pose().rotation().qy();
    auto qz = record_hero_car_pose->pose().rotation().qz();
    auto qw = record_hero_car_pose->pose().rotation().qw();
    double theta = std::atan2(2.0f * (qz * qw + qx * qy), -1.0f + 2.0f * (qw * qw + qx * qx));
    hero_car_model_->set_theta(theta);

    hero_car_model_->set_speed(sqrt(v_x * v_x + v_y * v_y + v_z * v_z));
    Q_EMIT notifyUpdateHeroCar(hero_car_model_);
  }
  else {
    if (!enable_simulator_when_replay_) {  // 根据回放包里的pose来决定主车位置
      hero_car_model_->set_x(x);
      hero_car_model_->set_y(y);
      hero_car_model_->set_z(z);
      auto qx = record_hero_car_pose->pose().rotation().qx();
      auto qy = record_hero_car_pose->pose().rotation().qy();
      auto qz = record_hero_car_pose->pose().rotation().qz();
      auto qw = record_hero_car_pose->pose().rotation().qw();
      double theta = std::atan2(2.0f * (qz * qw + qx * qy), -1.0f + 2.0f * (qw * qw + qx * qx));
      hero_car_model_->set_theta(theta);

      hero_car_model_->set_speed(sqrt(v_x * v_x + v_y * v_y + v_z * v_z));
      Q_EMIT notifyUpdateHeroCar(hero_car_model_);
    }
  }
}

void ScenarioControl::onNotifyDeleteCurveModel(int id)
{
  std::vector<int> obstacleIds = SingletonScenarioControl::getInstance()->findObstacleModelIdByCurveModel(id);
  for (auto obstacleId : obstacleIds) {
    ObstacleModel* obstacleModel = SingletonScenarioControl::getInstance()->findObstacleModel(obstacleId);
    if (obstacleModel == nullptr) { continue; }
    obstacleModel->setCurveId(-1);
    obstacleModel->setMode(ControlMode_Mode_KEEP_LANE);
  }
}

void ScenarioControl::onBackToHome()
{
  Q_EMIT notifyBackToHome();
}

void ScenarioControl::setHeroRoutingPoints(QVariantList points)
{
  if (hero_car_model_ == nullptr) { return; }
  QVariantList hero_car_dest = points;
  SINFO << "setHeroRoutingPoints";
  hero_car_model_->setTargetCurvePoints(hero_car_dest);
  SINFO << "setHeroRoutingPoints";
  Q_EMIT notifySetHeroRoutingPoints(hero_car_dest);
}

int ScenarioControl::addObstacleCurveModel(const QVariantList& points, const QVariantList& speeds)
{
  ObstacleCurveModel* model = new ObstacleCurveModel(this);
  model->line_curve_ = points;
  model->speeds_ = speeds;

  int curve_id = alloc_curve_id++;
  curves_model_.emplace(curve_id, model);
  SINFO << "addObstacleCurveModel";
  Q_EMIT notifyAddCurveModel(curve_id);
  return curve_id;
}

void ScenarioControl::deleteObstacleCurveModel(int curve_id)
{
  SINFO << "deleteObstacleCurveModel";
  auto iterator = curves_model_.find(curve_id);
  if (iterator != curves_model_.end()) {
    Q_EMIT notifyDeleteCurveModel(curve_id);
    delete iterator->second;
    curves_model_.erase(iterator);
  }
}

void ScenarioControl::bindCurvePoints(int curve_id, int obs_id)
{
  auto iterator_curve = curves_model_.find(curve_id);
  auto iterator_obs = obstacles_data_map_.find(obs_id);
  SINFO << "bindCurvePoints:" << curve_id << " to obs:" << obs_id;
  if (iterator_curve == curves_model_.end() || iterator_obs == obstacles_data_map_.end()) { return; }

  iterator_obs->second->setCurveId(curve_id);
  iterator_obs->second->setCurvePoints(iterator_curve->second->line_curve_, iterator_curve->second->speeds_);

  auto iterator_curve_to_obs = curves_to_obstacle.find(curve_id);
  if (iterator_curve_to_obs == curves_to_obstacle.end()) {
    std::vector<int> t;
    t.emplace_back(obs_id);
    curves_to_obstacle.emplace(curve_id, t);
  }
  else {
    iterator_curve_to_obs->second.emplace_back(obs_id);
  }
}

void ScenarioControl::unbindCurvePoints(int curve_id, int obs_id)
{
  if (curve_id < 0) { return; }
  auto iterator = curves_to_obstacle.find(curve_id);
  if (iterator == curves_to_obstacle.end()) {
    SINFO << "unbindCurvePoints no curve_id " << curve_id;
    return;
  }
  auto iterator_obs = obstacles_data_map_.find(obs_id);
  if (iterator_obs == obstacles_data_map_.end()) {
    SINFO << "unbindCurvePoints no obs_id " << obs_id;
    return;
  }
  SINFO << "unbindCurvePoints:" << curve_id << " from obs:" << obs_id;
  iterator_obs->second->setCurveId(-1);
  auto iterator_curve_to_obs = curves_to_obstacle.find(curve_id);
  if (iterator_curve_to_obs != curves_to_obstacle.end()) {
    iterator_curve_to_obs->second.erase(
        std::find(iterator_curve_to_obs->second.begin(), iterator_curve_to_obs->second.end(), obs_id));
  }
}

void ScenarioControl::updateObstacleSpeedAtIndex(int line_id, int index, double speed)
{
  // 1、查询line_id所绑定的障碍物
  std::vector<int> obs_ids = findObstacleModelIdByCurveModel(line_id);
  if (obs_ids.size() == 0) {
    SINFO << "the curve[" << line_id << "] has not binded to an obstacle.";
    return;
  }
  // 2、查询ObstacleModel
  for (auto obs_id : obs_ids) {
    ObstacleModel* obstacleModel = findObstacleModel(obs_id);
    if (obstacleModel == nullptr) {
      SINFO << "failed to find an obstacle.";
      continue;
    }
    // 3、更新ObstacleModel的speed
    SINFO << "updateObstacleSpeedAtIndex line " << line_id << "to find an obstacle." << obs_id;
    obstacleModel->updateCurveSpeedAtIndex(index, speed);
  }
}

void ScenarioControl::addParkingArea(const QVariantList& ids, const QVariantList& points, const QVariantList& radii)
{
  if (hero_car_model_ == nullptr || hero_car_model_->getType() != 
    static_cast<int>(VehicleType::HeroCar_VehicleType_MINI_BUS) ||
    points.size() != radii.size() || points.size() <= 0) { return; }
  
  parking_circle_model_ = new ParkingCircleModel(this);
  parking_circle_model_->addParkingArea(ids, points, radii);
}

void ScenarioControl::deleteCircleById(int id)
{
  if (parking_circle_model_ != nullptr) 
  { 
    SINFO << "deleteCircleById: " << id;
    if (parking_circle_model_->deleteCircleById(id))
    {
      SINFO << "deleteCircle success, id: " << id;
      Q_EMIT notifyDeleteCircleById(id);
    }
  }
}

void ScenarioControl::deleteParkingArea()
{
  if (parking_circle_model_ != nullptr) 
  { 
    SINFO << "deleteParkingArea: ";
    if (parking_circle_model_->deleteParkingArea())
    {
      Q_EMIT notifyDeleteParkingArea();
    }
  }
}