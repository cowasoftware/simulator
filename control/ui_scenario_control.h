#pragma once

#include "common/Singleton.h"
#include "common_model.h"
#include "garbage_model.h"
#include "herocar_model.h"
#include "obstacle_curve_model.h"
#include "obstacle_model.h"
#include "routing_model.h"
#include "parking_circle_model.h"

#include <QJsonArray>
#include <QJsonValue>

using ObstaclesInfo = simulator::rpc::client::ObstaclesInfo;
using GarbageInfo = simulator::rpc::client::GarbageInfo;
using ScenarioSave = simulator::rpc::client::ScenarioSave;
using VehicleType = simulator::rpc::client::HeroCar_VehicleType;
using ParkingArea = simulator::rpc::client::ParkingArea;
using PoseStamped = COWA::NavMsg::PoseStamped;
using RoutingRequest = COWA::routing::RoutingRequest;

class ScenarioControl : public QObject {
  Q_OBJECT
 public:
  explicit ScenarioControl(QObject* parent = 0);
  virtual ~ScenarioControl() { clear(); }

  ScenarioControl(const ScenarioControl& other) = default;
  ScenarioControl& operator=(const ScenarioControl& other) = default;

 private:
  ObstacleModel* addObstacle(int type,
                             int id,
                             double x,
                             double y,
                             int mode = ObstacleControlMode::ControlMode_Mode_KEEP_LANE,
                             bool isstatic = false);
  int allocId() { return ++next_alloc_id_; }

 public:
 Q_SIGNALS:
  void notifyUpdateAll();
  void notifyUpdateObstacle(int id, ObstacleModel* model);
  // 更新障碍物的可见性
  void notifyUpdateObstacleVisible(int id, bool visible);
  void notifyUpdateHeroCar(HeroCarModel* model);
  void notifyUpdateHeroCarError(double old_x, double old_y, double x, double y, double distance);
  void notifyUpdateRecordHeroCar(double x, double y, long timestamp);
  void notifyUpdateGarbage(int id, GarbageModel* model);

  void notifyAddObstacle(int id, ObstacleModel* model);
  void notifyAddHeroCar(HeroCarModel* model);
  void notifyAddGarbage(int id, GarbageModel* model);
  void notifyDeleteHeroCar();
  void notifyDeleteObstacle(int id);
  void notifyDeleteGarbage(int id);
  void notifySetHeroRoutingPoints(QVariantList points);
  void notifyAddCurveModel(int id);
  void notifyDeleteCurveModel(int id);
  void notifySetParkingArea(QVariantList ids, QVariantList points, QVariantList raduii);
  void notifyDeleteCircleById(int id);
  void notifyDeleteParkingArea();
  void notifyClear();
  void notifyBackToHome();

  void notifySetSimulationTestInfo(QJsonValue id, QJsonValue name, QJsonArray circleInfo);
  void notifyClearSimulationTestInfo();

 public:
  /** 获取当前帧的障碍物 */
  ObstaclesInfo getCurrentObstaclesInfo();
  // 仿真启动时更新所有障碍物的可见性
  void updateObstacleVisible(); 
  void saveToHistory();
  void restoreToHistory();
  bool parseSimulationTestContext();
  std::string simulationTestToEvaluation();
  std::string getSimulationTestName();
  Q_INVOKABLE int addObstacle(int type, double x, double y, int mode = ObstacleControlMode::ControlMode_Mode_KEEP_LANE);
  Q_INVOKABLE int addObstacleStatic(int type, double x, double y);
  Q_INVOKABLE int copyObstacle(int obs_id);
  Q_INVOKABLE void addHeroCar(int type, double x, double y);
  Q_INVOKABLE void addGarbage(int type, double x, double y);
  // Q_INVOKABLE void addParkingCircle(double x, double y, double radius);
  Q_INVOKABLE void deleteHeroCar();
  Q_INVOKABLE void deleteObstacle(int id);
  Q_INVOKABLE void deleteGarbage(int id);
  Q_INVOKABLE void addParkingArea(const QVariantList& ids, const QVariantList& points, const QVariantList& radii);
  Q_INVOKABLE void deleteCircleById(int id);
  Q_INVOKABLE void deleteParkingArea();
  Q_INVOKABLE void clear();

  // return id of curve
  Q_INVOKABLE void setHeroRoutingPoints(QVariantList points);
  Q_INVOKABLE int addObstacleCurveModel(const QVariantList& points, const QVariantList& speeds);
  Q_INVOKABLE void deleteObstacleCurveModel(int curve_id);
  Q_INVOKABLE void bindCurvePoints(int curve_id, int obs_id);
  Q_INVOKABLE void unbindCurvePoints(int curve_id, int obs_id);

  Q_INVOKABLE HeroCarModel* findHeroCarModel() { return hero_car_model_; }
  Q_INVOKABLE RoutingModel* findRoutingModel() { return hero_car_model_->routing_model_; }
  Q_INVOKABLE ParkingCircleModel* findParkingCircleModel() { return parking_circle_model_; }

  Q_INVOKABLE ObstacleModel* findObstacleModel(int id)
  {
    auto it = obstacles_data_map_.find(id);
    if (it != obstacles_data_map_.end()) { return it->second; }
    return nullptr;
  }

  Q_INVOKABLE GarbageModel* findGarbageModel(int id)
  {
    auto it = garbages_data_map_.find(id);
    if (it != garbages_data_map_.end()) { return it->second; }
    return nullptr;
  }

  Q_INVOKABLE ObstacleCurveModel* findCurveModel(int line_id)
  {
    auto it = curves_model_.find(line_id);
    if (it != curves_model_.end()) { return it->second; }

    return nullptr;
  }

  // update obstacle speed
  Q_INVOKABLE void updateObstacleSpeedAtIndex(int line_id, int index, double speed);

  // 查询轨迹线所绑定的障碍物
  std::vector<int> findObstacleModelIdByCurveModel(int line_id)
  {
    auto iterator_obs = curves_to_obstacle.find(line_id);
    if (iterator_obs == curves_to_obstacle.end()) { return std::vector<int>(); }
    return iterator_obs->second;
  }

  Q_INVOKABLE QVariantList getAllCurveModelId()
  {
    QVariantList all_line_id;
    for (auto it : curves_model_) { all_line_id.push_back(it.first); }
    return all_line_id;
  }
  // load or saved  Scenario File
  Q_INVOKABLE bool openScenarioFile(const QString& filename);
  Q_INVOKABLE bool saveScenarioFile(const QString& filename, const QString& description, const QString& total_time);
  Q_INVOKABLE bool openRoutingFile(const QString& filename);
  Q_INVOKABLE bool openSimulationTestFile(const QString& filename);
  Q_INVOKABLE QString simulationTestBoardText();
  Q_INVOKABLE void copyToBoard(const QString& text);
  // 回放时 启用仿真
  Q_INVOKABLE void setSimulateMode(bool simulate_mode) { is_simulate_mode_ = simulate_mode; }
  // 回放时 启用仿真
  Q_INVOKABLE void enableSimulatorWhenReplay(bool enable) { enable_simulator_when_replay_ = enable; }

  // 解析routing
  QVariantList parseRoutingRequest(const RoutingRequest& routingRequest);
  /**解析parkingArea*/
  bool parseParkingArea(const ParkingArea& parkingArea);

 private Q_SLOTS:
  // publish data from server
  void onPoseUpdate(std::shared_ptr<ObstaclesInfo> obstacles_info);
  void onRecordPoseUpdate(std::shared_ptr<PoseStamped> record_hero_car_pose);
  void onNotifyDeleteCurveModel(int id);
  void onBackToHome();

 private:
  // all obstacles data for user edit
  long now_t = 0;
  std::map<int, ObstacleModel*> obstacles_data_map_;
  std::map<int, GarbageModel*> garbages_data_map_;
  std::vector<ObstaclesInfo> obstacles_info_history_;
  // std::map<int, CircleModel*> parking_area_;


  // obstacles id from replay
  std::set<int> replay_obstacle_id_set_;

  HeroCarModel* hero_car_model_ = nullptr;
  ParkingCircleModel* parking_circle_model_ = nullptr;
  int next_alloc_id_ = 0;

  // 轨迹线和速度线 绑定到 障碍物上
  // when a curves bind to obstacle,  register it
  std::map<int, std::vector<int>> curves_to_obstacle;
  std::map<int, ObstacleCurveModel*> curves_model_;

  bool is_simulate_mode_ = true;  // 仿真模式 还是回放模式
  bool enable_simulator_when_replay_ = false;  //回放模式时， 是否让主车被仿真接管
  std::string simulation_test_name_;
  std::string simulation_test_context_;
};

typedef Singleton<ScenarioControl> SingletonScenarioControl;