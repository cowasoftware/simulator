#include <QDebug>
#include <QGuiApplication>
#include <QMetaObject>
#include <QQmlApplicationEngine>
#include <QScreen>
#include <QWindow>
#include <QtQml>
#include <QtQuick/QQuickItem>
#include <iostream>

#include "common/cargs.h"
#include "control/ui_record_play_control.h"
#include "control/ui_simulator_control.h"
#include "herocar_model.h"
#include "obstacle_model.h"
#include "routing_model.h"
#include "parking_circle_model.h"
#include "vmodel/HeroCarEditPanelVM.h"
#include "vmodel/ObstacleEditPanelVM.h"
#include "vmodel/TrafficLightEditPanelVM.h"
#include "vmodel/VersionInfoVM.h"

static void registerQMLControl();
static void registerQMLModel();

#include <unistd.h>

#include <thread>

#include "control/simulation_page_mouse_cursor.h"

static struct cag_option options[] = {
    {.identifier = 'i',
     .access_letters = "i",
     .access_name = "ip",
     .value_name = "127.0.0.1",
     .description = "ip address"},

    {.identifier = 'p', .access_letters = "p", .access_name = "port", .value_name = "10000", .description = "ip port"},

    {.identifier = 'h',
     .access_letters = "h",
     .access_name = "help",
     .value_name = nullptr,
     .description = "Shows the command help"}};

static void handleArgs(int argc, char* argv[])
{
  cag_option_context context;
  char identifier;
  cag_option_prepare(&context, options, CAG_ARRAY_SIZE(options), argc, argv);
  while (cag_option_fetch(&context)) {
    identifier = cag_option_get(&context);
    switch (identifier) {
    case 'i': {
      std::string str_ip = cag_option_get_value(&context);
      Context::setIP(str_ip);
      break;
    }
    case 'p': {
      int port;
      sscanf(cag_option_get_value(&context), "%d", &port);
      Context::setPort(port);
      break;
    }
    case 'h': {
      printf("Usage: sim_client [OPTION]...\n\n");
      cag_option_print(options, CAG_ARRAY_SIZE(options), stdout);
      printf("\n");
      exit(0);
    }
    }
  }
}

void printVersionInfo() {
    std::cout << "/*********************Simulatore client version info*********************/" << std::endl;
    std::string version = Util::GetBuildVersion();
    std::string buildTime = Util::GetBuildTime();
    std::string versionInfo = "[SIM_CLIENT_MAIN] SIM_CLIENT main in, version: " + version + " , build time: " + buildTime;
    std::cout << versionInfo << std::endl;
    std::cout << "/************************************************************************/" << std::endl;
}

int main(int argc, char* argv[])
{
  std::setprecision(5);
  handleArgs(argc, argv);
  QCoreApplication::setOrganizationName("appName.org");
  QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
  QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine;

  // 向 QML 域注册  类
  registerQMLControl();
  registerQMLModel();
  printVersionInfo();

  engine.rootContext()->setContextProperty("simulation_page_mouse_cursor", new Simulation_page_mouse_cursor());
  engine.load(QUrl(QStringLiteral("qrc:resource/qml/main.qml")));
  if (engine.rootObjects().isEmpty()) { return -1; }

  SimulatorClient::GetInstance();
  app.exec();
  std::cout << "app exit..." << std::endl;
  return 0;
}

void registerQMLControl()
{
  qmlRegisterSingletonInstance("COWA.Simulator", 1, 0, "SimulatorControl", SingletonSimulatorControl::getInstance());
  qmlRegisterSingletonInstance("COWA.Simulator", 1, 0, "RecordPlayControl", SingletonRecordPlayControl::getInstance());
  qmlRegisterSingletonInstance("COWA.Simulator", 1, 0, "ScenarioControl", SingletonScenarioControl::getInstance());
}

void registerQMLModel()
{
  qRegisterMetaType<QVariantList*>("QVariantList*");
  qRegisterMetaType<std::shared_ptr<RPCReplyRecord>>("std::shared_ptr<RPCReplyRecord>)");
  
  qmlRegisterType<MapItem, 1>("COWA.Simulator", 1, 0, "MapItem");
  qmlRegisterType<MapListModel, 1>("COWA.Simulator", 1, 0, "MapListModel");
  qmlRegisterType<RecordListModel, 1>("COWA.Simulator", 1, 0, "RecordListModel");
  qmlRegisterType<RecordModel, 1>("COWA.Simulator", 1, 0, "RecordModel");

  qmlRegisterType<HeroCarModel, 1>("COWA.Simulator", 1, 0, "HeroCarModel");
  qmlRegisterType<ObstacleModel, 1>("COWA.Simulator", 1, 0, "ObstacleModel");
  qmlRegisterType<ObstacleCurveModel, 1>("COWA.Simulator", 1, 0, "ObstacleCurveModel");
  qmlRegisterType<RoutingModel, 1>("COWA.Simulator", 1, 0, "RoutingModel");
  qmlRegisterType<ParkingCircleModel, 1>("COWA.Simulator", 1, 0, "ParkingCircleModel");

  qmlRegisterType<SubLight, 1>("COWA.Simulator", 1, 0, "SubLight");
  qmlRegisterType<TrafficLightModel, 1>("COWA.Simulator", 1, 0, "TrafficLightModel");

  qmlRegisterSingletonInstance("COWA.Simulator.VModel", 1, 0, "ObstacleEditPanelVM", new ObstacleEditPanelVM());
  qmlRegisterSingletonInstance("COWA.Simulator.VModel", 1, 0, "HeroCarEditPanelVM", new HeroCarEditPanelVM());
  qmlRegisterSingletonInstance("COWA.Simulator.VModel", 1, 0, "TrafficLightEditPanelVM", new TrafficLightEditPanelVM());
  qmlRegisterSingletonInstance("COWA.Simulator.VModel", 1, 0, "VersionInfoVM", new VersionInfoVM());
}