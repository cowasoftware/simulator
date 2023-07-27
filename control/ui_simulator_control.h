#pragma once

#include <QJsonArray>
#include <QString>

#include "common/Singleton.h"
#include "map_list_model.h"
#include "map_model.h"
#include "obstacle_curve_model.h"
#include "trafficlight_model.h"
#include "ui_scenario_control.h"

class SimulatorControl final : public QObject {
  Q_OBJECT
 public:
  explicit SimulatorControl(QObject* parent = nullptr);
  virtual ~SimulatorControl();
  SimulatorControl(const SimulatorControl& other) = delete;
  const SimulatorControl& operator=(const SimulatorControl& other) = delete;

 private:
  bool serializeToJsonArray(const LaneLine& lane);
  void syncSignalConfig();

  void dumpsys();

 private Q_SLOTS:
  // reply from server
  void onRecvMapList(std::shared_ptr<QList<QString>> map_list);
  void onRecvMap(std::shared_ptr<HdMap> hdmap);
  void onRecvSignalConfig(std::shared_ptr<std::vector<SignalConfig>> signal_configs);
  void onSignalStateUpdate(std::vector<SignalState> signal_state);
  void onFrame(int frame_id);

 private:
  bool is_playing_ = false;
  bool is_map_loaded = false;
  bool is_scenario_loaded = false;

  int next_alloc_id_ = 0;
  int frame_id_;
  std::ofstream dump_file_stream_;

  // UI map
  MapListModel* ui_map_list_model_;
  MapModel* ui_map_model_;

  // scenario信息
  ScenarioControl* scenario_control_;

  double xmapmin_;
  double ymapmin_;
  double xmapmax_;
  double ymapmax_;

  QJsonArray lane_id_;
  QJsonArray lane_polygon_;
  QJsonArray lane_mark_polygon_;
  QJsonArray lane_type_;
  QJsonArray lane_left_;
  QJsonArray lane_right_;
  QJsonArray lane_strip_;
  QJsonArray signals_id_;
  QJsonArray signals_stop_line_;
  QJsonArray crosswalk_;
  QJsonArray crosswalkid_;
  QJsonArray crossroad_;
  QJsonArray crossroadid_;
  QJsonArray ramp_;
  QJsonArray rampid_;
  QJsonArray spObject_;
  QJsonArray coverage_paths;
  QJsonArray debug_points;

  std::map<std::string, int> id_Str_int;
  // 定义红绿灯的信息
  std::map<std::string, TrafficLightModel*> m_lightInfo;
  std::set<std::string> m_dirty_signal;

 public:
 Q_SIGNALS:
  // notify data to qml UI
  void notifyMapList(MapListModel* model);
  void notifyMap(QJsonArray lane_id,
                 QJsonArray lane_polygon,
                 QJsonArray lane_mark_polygon,
                 QJsonArray lane_strip,
                 QJsonArray laneType,
                 QJsonArray lane_left,
                 QJsonArray lane_right,
                 QJsonArray signals_id,
                 QJsonArray signals_stop_line,
                 QJsonArray crosswalkid,
                 QJsonArray crosswalk,
                 QJsonArray crossroadid,
                 QJsonArray crossroad,
                 QJsonArray rampsid,
                 QJsonArray ramps,
                 QJsonArray spObjects,
                 double xmapmin,
                 double ymapmin,
                 double xmapmax,
                 double ymapmax);
  // void addLightInfo(TrafficLightModel* model);
  void notifyTrafficLightModel(TrafficLightModel* model);
  void notifyConveragePaths(QJsonArray coverage_paths);
  void notifyDebugPoints(QJsonArray points);

 public:
  // send command to server
  Q_INVOKABLE void simulatorStart();
  Q_INVOKABLE void simulatorPause();
  Q_INVOKABLE void simulatorReset();
  Q_INVOKABLE void simulatorClear();

  // fetch map
  Q_INVOKABLE void acquireMapList();
  Q_INVOKABLE void acquireMap(const QString& mapname = "");
  Q_INVOKABLE QString acquireLaneInfo(const QString& laneid = "");
  Q_INVOKABLE TrafficLightModel* acquireTrafficLight(const QString& signal_id)
  {
    return m_lightInfo[signal_id.toStdString()];
  }
  TrafficLightModel* acquireTrafficLight(const std::string& signal_id) { return m_lightInfo[signal_id]; }
  Q_INVOKABLE void markTrafficLightDirty(const QString& signal_id) { m_dirty_signal.insert(signal_id.toStdString()); }
  std::set<std::string> getDirtySignal() { return m_dirty_signal; }

  // sync info to server
  Q_INVOKABLE void syncSceneToServer();
  Q_INVOKABLE void setSimulateRate(int rate);
  Q_INVOKABLE void setKeepTrafficLightGreen(int keep);

  // others
  Q_INVOKABLE bool loadCoveragePathFile(const QString& filename);
  Q_INVOKABLE bool loadDebugFile();
};

typedef Singleton<SimulatorControl> SingletonSimulatorControl;