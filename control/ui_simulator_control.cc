#include "control/ui_simulator_control.h"

#include <math.h>

#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QJsonArray>
#include <QJsonObject>
#include <fstream>
#include <QDebug>
#include <QJsonDocument>

#include "Util.h"
#include "client/logger.h"
#include "common/Util.h"
#include "config.h"
#include "simulator_client.h"
#include <math.h>
#include <stack>
#include "google/protobuf/text_format.h"
#include "unicorn_config.pb.h"
#include <iostream>

const int SIGNAL_TYPE_BEGIN = COWA::MapData::Signal_Type_FOWARD;
const int SIGNAL_TYPE_END = COWA::MapData::Signal_Type_UTURN;

// utils
template <typename T> static std::string QListArrayString(const QList<T>& list)
{
  int index = 0;
  std::string result = "[\"listLength:" + std::to_string((int32_t)list.size()) + "\",";
  for (auto it = list.begin(); it != list.end(); ++it) {
    result += (*it)->toString() + ",";
    if (++index == 3) { break; }
  }
  if (result.back() == ',') { result.pop_back(); }
  return result + "]";
}

QPointF realMapPointToNoScaleContext(const QPointF& realMapPoint, double xmapmin, double ymapmin)
{
  return QPointF(realMapPoint.x() - xmapmin, -(realMapPoint.y() - ymapmin));
}

bool sameDirection(const Point2D& a1, const Point2D& b1, const Point2D& a2, const Point2D& b2)
{
  double x1 = b1.x_ - a1.x_;
  double y1 = b1.y_ - a1.y_;
  double x2 = b2.x_ - a2.x_;
  double y2 = b2.y_ - a2.y_;
  return ((x1 * x2 + y1 * y2) / (sqrt(x1 * x1 + y1 * y1) * sqrt(x2 * x2 + y2 * y2))) > 0;
}
//

bool SimulatorControl::loadCoveragePathFile(const QString& filename) {
  std::string filePath = filename.toStdString();
  bool isFileExist = Util::DirOrFileExist(filePath);
  if (!isFileExist) {
    printf("loadCoveragePathFile file not exist, path = %s\n", filePath.c_str());
    return false;
  }

  std::string context = Util::ReadFile(filePath.c_str());
  if (context.empty()) {
    printf("read coverage path file error, path = %s\n", filePath.c_str());
    return false;
  }

  COWA::planning::UnicornMissionDeciderConfig missionDeciderConfig;
  google::protobuf::TextFormat::Parser pathConfigTextParser;
  bool readResult = pathConfigTextParser.ParseFromString(context, &missionDeciderConfig);
  if (!readResult) {
    printf("parse coverage path file error\n");
    return false;
  }

  QJsonArray emptyArray;
  coverage_paths.swap(emptyArray);
  qDebug() << "coverage path size: " << missionDeciderConfig.coverage_path_config_size();
  if(missionDeciderConfig.coverage_path_config_size() > 0) {
    for(auto& coverage_path : missionDeciderConfig.coverage_path_config()) {
      auto start_pose = coverage_path.start_pose();
      QJsonArray starts;
      QPointF&& noScaleContextPoint = realMapPointToNoScaleContext(
          QPointF(std::move(start_pose.x()), std::move(start_pose.y())), xmapmin_, ymapmin_);
      starts.push_back(noScaleContextPoint.x());
      starts.push_back(noScaleContextPoint.y());
      
      auto end_pose = coverage_path.end_pose();
      QJsonArray ends;
      QPointF&& noScaleContextPoint2 = realMapPointToNoScaleContext(
          QPointF(std::move(end_pose.x()), std::move(end_pose.y())), xmapmin_, ymapmin_);
      ends.push_back(noScaleContextPoint2.x());
      ends.push_back(noScaleContextPoint2.y());
      coverage_paths.push_back(std::move(starts));
      coverage_paths.push_back(std::move(ends));
    }
  }
  Q_EMIT notifyConveragePaths(coverage_paths);
  return true;
}

bool SimulatorControl::loadDebugFile() {
  std::string filePath = "output.txt";
  bool isFileExist = Util::DirOrFileExist(filePath);
  if (!isFileExist) {
    printf("loadDebugFile file not exist, path = %s\n", filePath.c_str());
    return false;
  }
  QJsonArray emptyArray;
  debug_points.swap(emptyArray);

  std::ifstream fin(filePath);  
  std::string s;  
  while( getline(fin, s) )
  {    
    // SINFO << "Read from file: " << s; 
    std::vector<std::string> xy = Util::Split(s, " ");
    double x = (atof(xy[0].c_str()) * 100)/100;
    double y = (atof(xy[1].c_str()) * 100)/100;
    QPointF&& noScaleContextPoint = realMapPointToNoScaleContext(QPointF(x, y), xmapmin_, ymapmin_);
    QJsonArray starts;
    starts.push_back(noScaleContextPoint.x());
    starts.push_back(noScaleContextPoint.y());
    debug_points.push_back(std::move(starts));
  }
  Q_EMIT notifyDebugPoints(debug_points);
  return true;
}

SimulatorControl::SimulatorControl(QObject* parent) : QObject(parent)
{
  xmapmin_ = 0;
  // ymapmin_ = 3449554.241393;
  ymapmin_ = 0;
  ui_map_list_model_ = new MapListModel(this);
  ui_map_model_ = new MapModel();
  scenario_control_ = SingletonScenarioControl::getInstance();

  qRegisterMetaType<std::shared_ptr<QList<QString>>>("std::shared_ptr<QList<QString>>");
  qRegisterMetaType<std::shared_ptr<HdMap>>("std::shared_ptr<HdMap>");
  qRegisterMetaType<std::vector<SignalState>>("std::vector<SignalState>");
  qRegisterMetaType<std::shared_ptr<ObstaclesInfo>>("std::shared_ptr<ObstaclesInfo>");
  qRegisterMetaType<std::shared_ptr<PoseStamped>>("std::shared_ptr<PoseStamped>");
  qRegisterMetaType<std::shared_ptr<std::vector<SignalConfig>>>("std::shared_ptr<std::vector<SignalConfig>>");
  const MainThreadNotifier* notifer = SimulatorClient::GetInstance()->getNotifier();
  QObject::connect(notifer, SIGNAL(onRecvMapList(std::shared_ptr<QList<QString>>)), this,
                   SLOT(onRecvMapList(std::shared_ptr<QList<QString>>)), Qt::QueuedConnection);
  QObject::connect(notifer, SIGNAL(onRecvMap(std::shared_ptr<HdMap>)), this, SLOT(onRecvMap(std::shared_ptr<HdMap>)),
                   Qt::QueuedConnection);
  QObject::connect(notifer, SIGNAL(onRecvSignalConfig(std::shared_ptr<std::vector<SignalConfig>>)), this, 
                   SLOT(onRecvSignalConfig(std::shared_ptr<std::vector<SignalConfig>>)),Qt::QueuedConnection);
  QObject::connect(notifer, SIGNAL(onSignalStateUpdate(std::vector<SignalState>)), this,
                   SLOT(onSignalStateUpdate(std::vector<SignalState>)), Qt::QueuedConnection);
  QObject::connect(notifer, SIGNAL(onPoseUpdate(std::shared_ptr<ObstaclesInfo>)), scenario_control_,
                   SLOT(onPoseUpdate(std::shared_ptr<ObstaclesInfo>)), Qt::QueuedConnection);

  QObject::connect(notifer, SIGNAL(onRecordPoseUpdate(std::shared_ptr<PoseStamped>)), scenario_control_,
                   SLOT(onRecordPoseUpdate(std::shared_ptr<PoseStamped>)), Qt::QueuedConnection);
  QObject::connect(notifer, SIGNAL(onFrame(int)), this, SLOT(onFrame(int)), Qt::QueuedConnection);

  QObject::connect(notifer, SIGNAL(notifyBackToHome()), scenario_control_, SLOT(onBackToHome()), Qt::QueuedConnection);

  if (ENABLE_DUMP_FILE) {
    auto now = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    std::stringstream ss;
    ss << QCoreApplication::applicationDirPath().toStdString() << "/dump/";
    if (!QDir(QString::fromStdString(ss.str())).exists()) { QDir().mkdir(QString::fromStdString(ss.str())); }
    ss << std::put_time(std::localtime(&now), "%Y-%m-%d--%T");

    dump_file_stream_.open(ss.str(), std::ios::out);
    SINFO << "the dump file is " << ss.str() << std::endl;
  }
}

SimulatorControl::~SimulatorControl()
{
  if (ENABLE_DUMP_FILE) { dump_file_stream_.close(); }
  delete ui_map_list_model_;
  delete ui_map_model_;
}

void SimulatorControl::simulatorStart()
{
  if (!is_map_loaded) return;
  if (!is_playing_) {
    // before start, sync the obstacle from UI to data, and send to server
    syncSceneToServer();
    // 刷新障碍物的可见性
    scenario_control_->updateObstacleVisible();
    is_playing_ = true;
    std::vector<std::string> params = {scenario_control_->getSimulationTestName()};
    SimulatorClient::GetInstance()->sendCommandToSimulator(COM_start_simulator, params);
  }
}

void SimulatorControl::simulatorPause()
{
  if (is_playing_) {
    is_playing_ = false;
    SimulatorClient::GetInstance()->sendCommandToSimulator(COM_stop_simulator);
  }
}

void SimulatorControl::simulatorReset()
{
  is_playing_ = false;
  scenario_control_->restoreToHistory();
  
  //syncSceneToServer();

  SimulatorClient::GetInstance()->setObstacles(scenario_control_->getCurrentObstaclesInfo());
  is_scenario_loaded = true;
}

void SimulatorControl::simulatorClear()
{
  if (is_playing_) {
    SimulatorClient::GetInstance()->sendCommandToSimulator(COM_clear_simulator);
    is_playing_ = false;
  }

  scenario_control_->clear();
  is_scenario_loaded = false;
}

void SimulatorControl::acquireMapList()
{
  if (!ui_map_list_model_->ready()) { SimulatorClient::GetInstance()->acquireMapList(); }
  else {
    Q_EMIT notifyMapList(ui_map_list_model_);
  }
}

void SimulatorControl::acquireMap(const QString& mapname)
{
  const std::string c_mapname = mapname.toStdString();
  SINFO << "c_mapname: " << c_mapname;
  if (!mapname.isEmpty() && c_mapname != ui_map_model_->map_name_) {  // 加载新的地图
    SINFO << "ui_map_model_->map_name_: " << ui_map_model_->map_name_;
    ui_map_model_->map_name_ = c_mapname;
    SimulatorClient::GetInstance()->acquireMap(c_mapname);
    m_lightInfo.clear();
  }
  else {  // 如果还是原来的地图， 并且已经加载了
    if (is_map_loaded) {
      Q_EMIT notifyMap(lane_id_, 
                      lane_polygon_, 
                      lane_mark_polygon_, 
                      lane_strip_, 
                      lane_type_,
                      lane_left_, 
                      lane_right_, 
                      signals_id_, 
                      signals_stop_line_, 
                      crosswalkid_, 
                      crosswalk_, 
                      crossroadid_, 
                      crossroad_, 
                      rampid_, 
                      ramp_, 
                      spObject_,
                      xmapmin_, ymapmin_, xmapmax_, ymapmax_);

      // qDebug() << "acquireMap, add light " << m_lightInfo.size() << Qt::endl;
      // for (auto& iterator : m_lightInfo) {
      //   TrafficLightModel* model = iterator.second;
      //   Q_EMIT addLightInfo(model);
      // }
    }
  }
}

QString SimulatorControl::acquireLaneInfo(const QString& laneid)
{
  SINFO << "SimulatorControl::acquireLaneInfo " << laneid.toStdString();
  for (auto& lane : ui_map_model_->lanes_) {
    if (lane.id == laneid.toStdString()) { return QString::fromStdString(lane.display); }
  }
  SINFO << "lane.display NONE ";
  return "";
}

// after the setting dialog finish, shoul sync to server
void SimulatorControl::syncSceneToServer()
{
  SINFO << "syncSceneToServer";
  scenario_control_->saveToHistory();
  SimulatorClient::GetInstance()->setObstacles(scenario_control_->getCurrentObstaclesInfo());
  is_scenario_loaded = true;

  syncSignalConfig();
}

void SimulatorControl::syncSignalConfig()
{
  SINFO << "syncSignalConfig ";

  for (auto signal_id : m_dirty_signal) {
    TrafficLightModel* model = m_lightInfo[signal_id];
    SignalConfig config;
    model->toSignalConfig(&config);
    // SINFO << "setSignalConfig " << config.DebugString();
    SimulatorClient::GetInstance()->setSignalConfig(config);
  }
}

void SimulatorControl::setSimulateRate(int rate)
{
  SimulatorClient::GetInstance()->setSimulateRate(rate);
}

void SimulatorControl::setKeepTrafficLightGreen(int keep)
{
  SimulatorClient::GetInstance()->setKeepTrafficLightGreen(keep);
}

void SimulatorControl::onRecvMapList(std::shared_ptr<QList<QString>> map_list)
{
  ui_map_list_model_->flush(map_list);
  Q_EMIT notifyMapList(ui_map_list_model_);
}

void SimulatorControl::onRecvMap(std::shared_ptr<HdMap> hdmap)
{
  if (hdmap == nullptr) { return; }
  ui_map_model_->onRecvMap(hdmap);

  xmapmin_ = ui_map_model_->getXmin();
  ymapmin_ = ui_map_model_->getYmin();
  xmapmax_ = ui_map_model_->getXmax();
  ymapmax_ = ui_map_model_->getYmax();

  QJsonArray emptyLaneId;
  lane_id_.swap(emptyLaneId);
  QJsonArray emptyLaneType;
  lane_type_.swap(emptyLaneType);
  QJsonArray emptyP;
  lane_polygon_.swap(emptyP);
  QJsonArray emptyLeft;
  lane_left_.swap(emptyLeft);
  QJsonArray emptyRight;
  lane_right_.swap(emptyRight);
  QJsonArray emptyLaneMark;
  lane_mark_polygon_.swap(emptyLaneMark);
  QJsonArray emptyLaneStrip;
  lane_strip_.swap(emptyLaneStrip);

  QJsonArray emptySignalsId;
  signals_id_.swap(emptySignalsId);
  QJsonArray emptySignalsStopLine;
  signals_stop_line_.swap(emptySignalsStopLine);
  QJsonArray emptyCrosswalk;
  crosswalk_.swap(emptyCrosswalk);
  QJsonArray emptyCrosswalkid;
  crosswalkid_.swap(emptyCrosswalkid);
  QJsonArray emptyCrossroad;
  crossroad_.swap(emptyCrossroad);
  QJsonArray emptyCrossroadid;
  crossroadid_.swap(emptyCrossroadid);
  QJsonArray emptyRamp;
  ramp_.swap(emptyRamp);
  QJsonArray emptyRampid;
  rampid_.swap(emptyRampid);
  QJsonArray emptyObjects;
  spObject_.swap(emptyObjects);

  m_lightInfo.clear();
  std::vector<LaneLine>& lanes = ui_map_model_->lanes_;
  for (auto&& it = lanes.begin(); it != lanes.end(); ++it) { serializeToJsonArray(*it); }

  // 红绿灯
  std::vector<Signal>& signals = ui_map_model_->signals_;
  for (auto it = signals.begin(); it != signals.end(); ++it) {
    auto&& stopLine = it->getStopLine();

    if (it->has_subsignal) {
      TrafficLightModel* model = new TrafficLightModel(this, it->is_crosswalk);
      model->x = (stopLine[0].getX() + stopLine[stopLine.size()-1].getX()) / 2.0;
      model->y = (stopLine[0].getY() + stopLine[stopLine.size()-1].getY()) / 2.0;;
      model->id = QString::fromStdString(it->getId());

      m_lightInfo[it->getId()] = model;
      signals_id_.push_back(QJsonValue(model->id));
    } else {
      signals_id_.push_back(QJsonValue("0")); // no signal
    }

    // SINFO << "it->getId()=" << it->getId();
    QJsonArray points;
    for (auto itPoint = stopLine.begin(); itPoint != stopLine.end(); ++itPoint) {
      QPointF&& noScaleContextPoint = realMapPointToNoScaleContext(
          QPointF(std::move((itPoint)->getX()), std::move((itPoint)->getY())), xmapmin_, ymapmin_);
      points.push_back(noScaleContextPoint.x());
      points.push_back(noScaleContextPoint.y());
    }
    signals_stop_line_.push_back(std::move(points));
  }

  SINFO << "lane_mark_polygon_ size is: " << lane_mark_polygon_.size();

  std::vector<std::vector<std::vector<Point2D>>>& laneStrips = ui_map_model_->laneStripVector;
  for(auto& lane_strips_each_lane : laneStrips) {
    QJsonArray laneStripForLane;
    for(auto& vec : lane_strips_each_lane) {
      // each lanestrip for each lane
      QJsonArray laneStripArray;
      for(auto& it : vec) {
        QPointF&& noScaleContextPoint1 = realMapPointToNoScaleContext(
          QPointF(std::move(it.getX()), std::move(it.getY())), xmapmin_, ymapmin_);
        QJsonArray point;
        point.push_back(noScaleContextPoint1.x());
        point.push_back(noScaleContextPoint1.y());
        // qDebug() << "point: " << QJsonDocument(point).toJson();
        laneStripArray.push_back(std::move(point));
      }
      laneStripForLane.push_back(std::move(laneStripArray));
    }
    lane_strip_.push_back(std::move(laneStripForLane));
  }

  std::vector<CrossWalk>& crosswalks = ui_map_model_->crosswalks_;
  for (auto& crosswalk : crosswalks){
    QJsonArray crossArray;
    std::vector<Point2D> polygon = crosswalk.getPolygon();
    for (auto& p: polygon) {
      QJsonArray point;
      QPointF&& noScaleContextPoint = realMapPointToNoScaleContext(
          QPointF(std::move(p.getX()), std::move(p.getY())), xmapmin_, ymapmin_);
      point.push_back(noScaleContextPoint.x());
      point.push_back(noScaleContextPoint.y());
      crossArray.push_back(std::move(point));
    }
    crosswalk_.push_back(std::move(crossArray));
    crosswalkid_.push_back(std::move(QString::fromStdString(crosswalk.id)));
  }

  std::vector<Crossroad>& crossroads = ui_map_model_->crossroads_;
  for (auto& crossroad : crossroads){
    QJsonArray crossArray;
    std::vector<Point2D> boundary = crossroad.getBoundary();
    for (auto& p: boundary) {
      QJsonArray point;
      QPointF&& noScaleContextPoint = realMapPointToNoScaleContext(
          QPointF(std::move(p.getX()), std::move(p.getY())), xmapmin_, ymapmin_);
      point.push_back(noScaleContextPoint.x());
      point.push_back(noScaleContextPoint.y());
      crossArray.push_back(std::move(point));
    }
    crossroad_.push_back(std::move(crossArray));
    crossroadid_.push_back(std::move(QString::fromStdString(crossroad.id)));
  }

  std::vector<Ramp>& ramps = ui_map_model_->ramps_;
  for(auto& ramp : ramps) {
    QJsonArray rampArray;
    std::vector<Point2D> polygon = ramp.getPolygon();
    for (auto& p: polygon) {
      QJsonArray point;
      // qDebug() << "point: " <<p.getX() << ", " << p.getY() << Qt::endl;
      QPointF&& noScaleContextPoint = realMapPointToNoScaleContext(
          QPointF(std::move(p.getX()), std::move(p.getY())), xmapmin_, ymapmin_);
      point.push_back(noScaleContextPoint.x());
      point.push_back(noScaleContextPoint.y());
      rampArray.push_back(std::move(point));
    }
    ramp_.push_back(std::move(rampArray));
    rampid_.push_back(std::move(QString::fromStdString(ramp.id)));
  }

  std::vector<SpecialObject>& spObject = ui_map_model_->spObjects_;
  for (auto& object : spObject){
    QJsonArray objectArray;
    std::vector<Point2D> polygon = object.getPolygon();
    for (auto& p: polygon) {
      QJsonArray point;
      QPointF&& noScaleContextPoint = realMapPointToNoScaleContext(
          QPointF(std::move(p.getX()), std::move(p.getY())), xmapmin_, ymapmin_);
      point.push_back(noScaleContextPoint.x());
      point.push_back(noScaleContextPoint.y());
      // qDebug() << p.getX() << "," << p.getY();
      objectArray.push_back(std::move(point));
    }
    spObject_.push_back(std::move(objectArray));
  }
  
  Q_EMIT notifyMap(lane_id_, 
                  lane_polygon_, 
                  lane_mark_polygon_, 
                  lane_strip_, 
                  lane_type_, 
                  lane_left_, 
                  lane_right_, 
                  signals_id_, 
                  signals_stop_line_, 
                  crosswalkid_, 
                  crosswalk_, 
                  crossroadid_, 
                  crossroad_, 
                  rampid_, 
                  ramp_, 
                  spObject_,
                  xmapmin_, ymapmin_, xmapmax_, ymapmax_);
  is_map_loaded = true;

  // ui_map_model_->clear();

  qDebug() << "SimulatorControl::onRecvMap " << Qt::endl;
  std::string coverage_path = std::string("coverage_path_config.pb.txt");
  loadCoveragePathFile(QString::fromStdString(coverage_path));

  loadDebugFile();
}

void SimulatorControl::onRecvSignalConfig(std::shared_ptr<std::vector<SignalConfig>> signal_configs) 
{
  if (signal_configs->empty()) { return; }
  for(std::size_t i = 0; i < signal_configs->size(); ++i)
  {
    auto& signal_config = signal_configs->at(i);
    if (!signal_config.has_id())  continue;
    std::string id = signal_config.id();
    if (m_lightInfo.find(id) != m_lightInfo.end()) {
      TrafficLightModel* model = m_lightInfo[id];
      // SINFO << "onRecvSignalConfig signal config: " << signal_config.DebugString();
      model->fromSignalConfig(signal_config);
    }

  }
}

void SimulatorControl::onSignalStateUpdate(std::vector<SignalState> signal_states)
{
  // SINFO << "onSignalStateUpdate signal_states size = " << signal_states.size();

  if (signal_states.empty()) { return; }
  for (std::size_t i = 0; i < signal_states.size(); ++i) {
    auto& signal_state = signal_states.at(i);
    if (!signal_state.has_id()) continue;
    std::string id = signal_state.id();
    if (m_lightInfo.find(id) != m_lightInfo.end()) {
      TrafficLightModel* model = m_lightInfo[id];
      // SINFO << "onSignalStateUpdate updateLightInfo" << signal_state.DebugString();
      model->fromSignalState(signal_state);
      Q_EMIT notifyTrafficLightModel(model);
    }
  }
}

void SimulatorControl::onFrame(int frame_id)
{
  frame_id_ = frame_id;
  dumpsys();
}

bool SimulatorControl::serializeToJsonArray(const LaneLine& lane)
{
  QJsonArray subArray;
  QJsonArray leftArray;
  QJsonArray rightArray;
  QJsonArray laneMarkArray;
  QJsonArray emptyArray;
  auto& left = lane.getLeft();
  auto& right = lane.getRight();
  auto& laneMark = lane.getLaneMarkVect();
  leftArray.push_back(lane.is_left_reality_line);
  rightArray.push_back(lane.is_right_reality_line);

  QPointF last1;
  QPointF last2;
  for (int i = 0; i < (int)left.size(); ++i) {
    QPointF&& noScaleContextPoint =
        realMapPointToNoScaleContext(QPointF(left[i].getX(), left[i].getY()), xmapmin_, ymapmin_);

    QJsonArray point;
    point.push_back(noScaleContextPoint.x());
    point.push_back(noScaleContextPoint.y());
    point.push_back(left[i].getType());
    subArray.push_back(point);
    leftArray.push_back(point);
  }

  // 处理每一个LaneMark
  if(laneMark.size() > 0) {
    QJsonArray polygon_for_lane;
    for(int i = 0; i < (int)laneMark.size(); ++i) {
      auto& polygon = laneMark[i].getPolygon();
      QJsonArray single_polygon;
      for (int j = 0; j < (int) polygon.size(); j++)
      {
        // convert polygon of each LaneMark
        QPointF&& noScaleContextPoint =
          realMapPointToNoScaleContext(QPointF(polygon[j].getX(), polygon[j].getY()), xmapmin_, ymapmin_);
        QJsonArray point;
        point.push_back(noScaleContextPoint.x());
        point.push_back(noScaleContextPoint.y());
        single_polygon.push_back(point);
      }
      polygon_for_lane.push_back(single_polygon);
    }
    lane_mark_polygon_.push_back(polygon_for_lane);
  } else {
    lane_mark_polygon_.push_back(emptyArray);
  }

  if (sameDirection(left.front(), left.back(), right.front(), right.back())) {
    for (int i = right.size() - 1; i >= 0; --i) {
      QPointF&& noScaleContextPoint =
          realMapPointToNoScaleContext(QPointF(right[i].getX(), right[i].getY()), xmapmin_, ymapmin_);

      QJsonArray point;
      point.push_back(noScaleContextPoint.x());
      point.push_back(noScaleContextPoint.y());
      point.push_back(right[i].getType());
      subArray.push_back(point);
      rightArray.push_back(point);
    }
  }
  else {
    for (int i = 0; i < (int)right.size(); ++i) {
      QPointF&& noScaleContextPoint =
          realMapPointToNoScaleContext(QPointF(right[i].getX(), right[i].getY()), xmapmin_, ymapmin_);

      QJsonArray point;
      point.push_back(noScaleContextPoint.x());
      point.push_back(noScaleContextPoint.y());
      point.push_back(right[i].getType());
      subArray.push_back(point);
      rightArray.push_back(point);
    }
  }

  if (subArray.size() >= 2) {
    lane_id_.push_back(QJsonValue(lane.getId().c_str()));
    lane_polygon_.push_back(std::move(subArray));
    lane_left_.push_back(std::move(leftArray));
    lane_right_.push_back(std::move(rightArray));
    // lane_mark_polygon_.push_back(std::move(laneMarkArray));
    switch (lane.getLaneType()) {
    case COWA::MapData::Lane::NONE: lane_type_.push_back(1); break;
    case COWA::MapData::Lane::CITY_DRIVING: lane_type_.push_back(2); break;
    case COWA::MapData::Lane::BIKING: lane_type_.push_back(3); break;
    case COWA::MapData::Lane::SIDEWALK: lane_type_.push_back(4); break;
    case COWA::MapData::Lane::WAITINGAREA: lane_type_.push_back(5); break;
    case COWA::MapData::Lane::HYBRID: lane_type_.push_back(6); break;
    case COWA::MapData::Lane::PARKING: lane_type_.push_back(7); break;
    case COWA::MapData::Lane::EMERGENCY_LINE: lane_type_.push_back(8); break;
    case COWA::MapData::Lane::BUS: lane_type_.push_back(9); break;
    default: {
      qDebug() << "lane.getLaneType() unknown************* " << Qt::endl;
      return false;}
    }
    return true;
  }
  /*
    Lane_LaneType_NONE = 1,
  Lane_LaneType_CITY_DRIVING = 2,
  Lane_LaneType_BIKING = 3,
  Lane_LaneType_PARKING = 7,
  Lane_LaneType_EMERGENCY_LINE = 8,
  Lane_LaneType_SIDEWALK = 4,
  Lane_LaneType_WAITINGAREA = 5,
  Lane_LaneType_HYBRID = 6
  */
  return false;
}

void SimulatorControl::dumpsys()
{
  if (ENABLE_DUMP_FILE) {
    dump_file_stream_ << "******frame id: " << frame_id_ << "*****" << std::endl;
    std::stringstream ss;

    dump_file_stream_ << ss.str();
    dump_file_stream_ << std::endl << std::endl;
  }
}
