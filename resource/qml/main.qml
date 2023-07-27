import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.VirtualKeyboard 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls 2.3
import COWA.Simulator.VModel 1.0

import "qrc:/resource/qml/config"
import "qrc:/resource/qml/event_bus"
import "qrc:/resource/qml/simulation_page"
import "qrc:/resource/qml/home_page"

Window
{
    id: window_id
    width: Screen.width
    height: Screen.height
    title : qsTr(VersionInfoVM.buildTime)
    visible: true
    color: "#1d1d1d"

    // 全局变量
    Config {
        id: config_id
    }
    // 全局事件通信
    EventBus {
        id: event_bus_id
    }
    
    // 中间内容 可以切换 创建工程页面 或者 仿真页面
    Rectangle
    {
        id: main_page_rect_id
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        color: "#EDF1F2"
        Loader
        {
            id: main_page_loader_id
            width: parent.width
            height: parent.height
            source: "qrc:///resource/qml/home_page.qml"
        }

        focus:true; //一定要获取焦点，才可以铺货键盘按键
        Keys.enabled: true;
        Keys.onPressed: {
            console.log("main_page_rect_id keyPressed ", event.key)
            event_bus_id.keyPressed(event.key)
        }
    }

    // FOR DEBUG 
    Loader
    {
        id: login_server_loader_id
        z : 1
        width: parent.width
        height: parent.height
        source: config_id.isLocalHost ? "" : "qrc:///resource/qml/login_server.qml"
    }

    SimulationTestBoard
    {
        id: dialog
    }

    Connections {
        target: event_bus_id
        function onCreateProject(type, name) {
            console.log("onCreateProject in main.qml, config_id.screenScale", type, name,  config_id.screenScale)
            config_id.simulatorType = type
            main_page_loader_id.source = "qrc:///resource/qml/simulation_page.qml"
        }

        function onBackToHome() {
            console.log("onBackToHome in main.qml")
            config_id.simulatorType = ""
            main_page_loader_id.source = "qrc:///resource/qml/home_page.qml"
        }
    }
}