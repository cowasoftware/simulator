import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2

import COWA.Simulator  1.0
import COWA.Simulator.VModel 1.0

import "./simulation_page"
import "./simulation_page/EditPropertyPanel"
import "qrc:/resource/qml/config"

Item
{
    id: simulation_page_item_id
    x: 0
    y: 0
    width: parent.width
    height: parent.height

    property var simulation_edit_display_rect_width: 267 * config_id.screenScale

    // 中间的仿真渲染界面
	Rectangle
    {
        id: simulation_window_rect_id
		x: simulation_edit_mask_rect_id.width
		y: simulation_shortcut_button_rect_id.height
        width: parent.width - simulation_edit_mask_rect_id.width - simulation_edit_display_rect_width
        height: parent.height - simulation_shortcut_button_rect_id.height - simulation_bottom_tip_rect_id.height
        color: "#C1CDD1"//"#8CA2AA"

        Loader
        {
            id: simulation_window_loader_id
            width: parent.width
            height:parent.height
            source: "qrc:///resource/qml/simulation_page/simulation_window.qml"
            onLoaded:
            {

            }
        }
	}

    // 左侧
    Rectangle
    {
        id: simulation_edit_mask_rect_id
		x: 0
		y: simulation_shortcut_button_rect_id.height
        width: 264 * config_id.screenScale
        height: parent.height - simulation_shortcut_button_rect_id.height - simulation_bottom_tip_rect_id.height
        color: "#E1E3E6"

        SimulationLeftSideTabBar{
            id:simulation_left_side_tab_bar_id
            x: 0
            y: 5 * config_id.screenScale
            width:30 * config_id.screenScale
            height:parent.height
        }

        Rectangle
        {
            id: simulation_edit_control_rect_id
            x: 35 * config_id.screenScale
	    	y: 5 * config_id.screenScale
            width: 220 * config_id.screenScale
            height: parent.height - 8 * config_id.screenScale
            color: "#FFFFFF"

            Loader
            {
                id: simulation_edit_control_loader_id
                width: parent.width
                height:parent.height
                source: "qrc:///resource/qml/simulation_page/edit_control.qml"
                onLoaded:
                {

                }
            }
	    }
	}

    //定义全局变量，用于接收来自信号的参数
    property var image_source : ""

    property var obs_type : config_id.unknown

    //表示控制窗口已经点击过物体了，用于逻辑控制，更好的发送信号到仿真窗口
    property var edit_control_clicked_obj:false

    Connections 
    {
        target: event_bus_id
        function onGetIconSourceToMoveCar(type)
        {
            //接到信号,第一时间设置mouseArea的大小为edit_control+仿真窗口大小
            simulation_page_mouse_id.x = simulation_left_side_tab_bar_id.width + 4
            simulation_page_mouse_id.y = simulation_edit_mask_rect_id.y 
            simulation_page_mouse_id.width = simulation_edit_control_rect_id.width + simulation_window_rect_id.width + 10   //间距
            simulation_page_mouse_id.height = simulation_window_rect_id.height

            obs_type = type
            image_source = config_id.scenoriaConfig[type].image_source
            edit_control_clicked_obj = true

            //修改鼠标形状,以及大小
            simulation_page_mouse_cursor.setMyCursor(simulation_page_mouse_id, image_source.slice(3),75,75) 

            //console.log("edit_control_clicked_obj:",edit_control_clicked_obj)

            //console.log("simulation_page image_source:",image_source)
        }
    }

    MouseArea
    {
        id:simulation_page_mouse_id

        //默认为edit_control窗口的大小
        x :simulation_left_side_tab_bar_id.width + 4 * config_id.screenScale
        y: simulation_shortcut_button_rect_id.height
        width:simulation_edit_control_rect_id.width
        height: simulation_edit_control_rect_id.height

        //需要某个鼠标响应事件穿透的话，配合添加mouse.accepted = false使用
        //当前的窗口相对edit_control是顶层，可以穿透到底层
        //只有clicked, doubleClicked and pressAndHold这三个函数才能穿透
        propagateComposedEvents: true
        
        //设置鼠标长按时间为1ms
        pressAndHoldInterval: 1

        onPressAndHold:
        {                   
            //console.log("simulation_page_mouse_id onPressAndHold")
            mouse.accepted = false
        }
        onClicked:
        {
            mouse.accepted = false         
        }

        // //用于调试，不要给我删了
        // hoverEnabled:true
        // onPositionChanged:
        // {
        //     console.log("发送信号  释放小车",mouseX - simulation_edit_control_rect_id.width -10,mouseY)
        // }

        onReleased:
        {
            //console.log("simulation_page_mouse_id onReleased")
            cursorShape = Qt.ArrowCursor

            /*  
                * 如果控制窗口点击了物体
                * 直接更改鼠标形状
                * 并且判断得到的鼠标位置是否在仿真窗口里
                * 发送信号到仿真窗口
                * 信号消息为：当前鼠标的位置（simulation_page的鼠标位置）   
            */
            if( edit_control_clicked_obj )
            {
                cursorShape = Qt.ArrowCursor

                //这里鼠标位置大于多少，取决与上面按下，收到信号时，设置的mouseArea的大小
                if(mouseX > (simulation_edit_control_rect_id.width + 10) && mouseY > 0) 
                {
                    event_bus_id.editControlSendMousePosAndImageSource(mouseX - simulation_edit_control_rect_id.width - 10,
                        mouseY, obs_type)

                    //console.log("发送信号  释放小车",mouseX - simulation_edit_control_rect_id.width -10,mouseY)
                }   
            }
            edit_control_clicked_obj = false

            //释放后，恢复为edit_control窗口的大小
            simulation_page_mouse_id.x = simulation_left_side_tab_bar_id.width + 4 * config_id.screenScale
            simulation_page_mouse_id.y = simulation_shortcut_button_rect_id.height
            simulation_page_mouse_id.width = simulation_edit_control_rect_id.width
            simulation_page_mouse_id.height = simulation_edit_control_rect_id.height
        }
    }

    Rectangle
    {
        id: simulation_shortcut_button_rect_id
		x: 0
		y: 0
        width: parent.width
        height: 50 * config_id.screenScale
        color: "#EDF1F2"

        Loader
        {
            id: simulation_shortcut_button_loader_id
            width: parent.width - simulator_quit_id.width
            height:parent.height
            source: "qrc:///resource/qml/simulation_page/ShortcutToolBar.qml"
            onLoaded:
            {

            }
        }

        Image {
            id: simulator_quit_id
            width: 50 * config_id.screenScale
            height: parent.height
            anchors.right : parent.right
            source: "qrc:/resource/image/simulation_page/quit.png"
            fillMode: Image.PreserveAspectFit
            MouseArea{
                property bool entered: false
                hoverEnabled: true
                anchors.fill: parent
                onEntered: {
                    entered = true
                }

                onExited: {
                    entered = false
                }
                onClicked: {
                    event_bus_id.backToHome()
                }
                ToolTip{
                    visible: parent.entered
                    text: "退出tab"
                    delay: 500
                }
            }
        }
	}

    // 右上角的 场景物体展示 
    Rectangle
    {
        id: simulation_edit_display_rect_id
        width: simulation_edit_display_rect_width
        height: 368 * config_id.screenScale
        x: parent.width - simulation_edit_display_rect_id.width
		y: simulation_shortcut_button_rect_id.height + 5 * config_id.screenScale
        color: "#FFFFFF"

        Loader
        {
            id: simulation_edit_display_loader_id
            width: parent.width
            height:parent.height
            source: "qrc:///resource/qml/simulation_page/edit_display.qml"
            onLoaded:
            {

            }
        }
	}

    // 右下角的 场景物体的属性展示和编辑
    Rectangle
    {
        id: simulation_edit_property_rect_id
        width: simulation_edit_display_rect_id.width
        height: parent.height -
            simulation_shortcut_button_rect_id.height - simulation_bottom_tip_rect_id.height -
            simulation_edit_display_rect_id.height - 11 * config_id.screenScale
        x: simulation_edit_display_rect_id.x
		y: simulation_edit_display_rect_id.y + simulation_edit_display_rect_id.height + 3 * config_id.screenScale
        color: "#FFFFFF"
        property var currentEditModel : undefined
        property var currentEditModelType: -1

        HeroCarPanel{
            anchors.fill: parent
            visible: HeroCarEditPanelVM.visible
        }

        ObstaclePanel{
            anchors.fill: parent
            visible: ObstacleEditPanelVM.visible
        }

        RoutePanel{
            id: routePanel
            anchors.fill: parent
            visible: false
        }

        TrafficLightPanel{
            id: trafficlightPanel
            anchors.fill: parent
            visible: TrafficLightEditPanelVM.visible
            //visible: false
        }

        CirclePanel {
            id: circlePanel
            anchors.fill: parent
            visible: false
        }

        Connections{
            target: event_bus_id
            function onSelectHeroCar(){
                simulation_edit_property_rect_id.currentEditModel = ScenarioControl.findHeroCarModel()
                simulation_edit_property_rect_id.currentEditModelType = 1
                HeroCarEditPanelVM.title = config_id.scenoriaConfig[simulation_edit_property_rect_id.currentEditModel.type].name
                HeroCarEditPanelVM.refreshed()
                HeroCarEditPanelVM.visible = true
                ObstacleEditPanelVM.cleared()
                ObstacleEditPanelVM.visible = false
                //TrafficLightEditPanelVM.cleared()
                TrafficLightEditPanelVM.visible = false
                routePanel.visible = false
                circlePanel.visible = false
                console.info('onSelectHeroCar',simulation_edit_property_rect_id.currentEditModel)
            }

            function onSelectObstacle(model_id){
                simulation_edit_property_rect_id.currentEditModel = ScenarioControl.findObstacleModel(model_id)
                if (simulation_edit_property_rect_id.currentEditModel == null) {
                    return
                }
                simulation_edit_property_rect_id.currentEditModelType = 2
                ObstacleEditPanelVM.title = config_id.scenoriaConfig[simulation_edit_property_rect_id.currentEditModel.type].name + "-" + model_id
                ObstacleEditPanelVM.refreshed(model_id);
                ObstacleEditPanelVM.visible = true

                HeroCarEditPanelVM.cleared()
                HeroCarEditPanelVM.visible = false
                //TrafficLightEditPanelVM.cleared()
                TrafficLightEditPanelVM.visible = false
                routePanel.visible = false
                circlePanel.visible = false
                console.info('onSelectObstacle',simulation_edit_property_rect_id.currentEditModel)
            }

            function onSelectLight(model_id){
                simulation_edit_property_rect_id.currentEditModel = SimulatorControl.acquireTrafficLight(model_id)
                if (simulation_edit_property_rect_id.currentEditModel == null) {
                    return
                }
                console.info("onSelectLight", model_id, simulation_edit_property_rect_id.currentEditModel)
                simulation_edit_property_rect_id.currentEditModelType = 3
                TrafficLightEditPanelVM.selectSignalObject(simulation_edit_property_rect_id.currentEditModel)
                SimulatorControl.markTrafficLightDirty(model_id)
                TrafficLightEditPanelVM.visible = true

                HeroCarEditPanelVM.cleared()
                HeroCarEditPanelVM.visible = false
                ObstacleEditPanelVM.cleared()
                ObstacleEditPanelVM.visible = false
                routePanel.visible = false
                circlePanel.visible = false
            }

            function onSelectGarbage(model_id) {
                simulation_edit_property_rect_id.currentEditModel = ScenarioControl.findGarbageModel(model_id)
                if (simulation_edit_property_rect_id.currentEditModel == null) {
                    return
                }
                console.info('onSelectGarbage', simulation_edit_property_rect_id.currentEditModel)
                simulation_edit_property_rect_id.currentEditModelType = 4
                HeroCarEditPanelVM.cleared()
                HeroCarEditPanelVM.visible = false
                ObstacleEditPanelVM.cleared()
                ObstacleEditPanelVM.visible = false
                TrafficLightEditPanelVM.visible = false
                routePanel.visible = false
                circlePanel.visible = false
            }

            function onSelectLineCurve(route_id){
                simulation_edit_property_rect_id.currentEditModel = ScenarioControl.findCurveModel(route_id)
                routePanel.currentObstacleCurveModel = simulation_edit_property_rect_id.currentEditModel
                routePanel.title = "轨迹线" + "-" + route_id
                routePanel.currentCurveId = route_id
                routePanel.visible = true
                HeroCarEditPanelVM.visible = false
                ObstacleEditPanelVM.visible = false
                circlePanel.visible = false
                TrafficLightEditPanelVM.visible = false
                HeroCarEditPanelVM.cleared()
                ObstacleEditPanelVM.cleared()
                console.info('onSelectLineCurve',simulation_edit_property_rect_id.currentEditModel)
            }

            function onSelectParkingArea()
            {
                simulation_edit_property_rect_id.currentEditModel = ScenarioControl.findParkingCircleModel()
                circlePanel.parkingCircleModel = simulation_edit_property_rect_id.currentEditModel
                circlePanel.title = "小巴停车区域"
                circlePanel.visible = true
                // circlePanel.setData(ids, points, radii)
                routePanel.visible = false
                HeroCarEditPanelVM.visible = false
                ObstacleEditPanelVM.visible = false
                TrafficLightEditPanelVM.visible = false
                HeroCarEditPanelVM.cleared()
                ObstacleEditPanelVM.cleared()
            }

            function onAddParkingArea(ids, points, radii)
            {
                circlePanel.title = "小巴停车区域"
                circlePanel.setData(ids, points, radii)
                circlePanel.visible = true
                routePanel.visible = false
                HeroCarEditPanelVM.visible = false
                ObstacleEditPanelVM.visible = false
                TrafficLightEditPanelVM.visible = false
                HeroCarEditPanelVM.cleared()
                ObstacleEditPanelVM.cleared()
            }

            function onNotifyUpdateHeroCar() {
                if (simulation_edit_property_rect_id.currentEditModelType == 1) {
                    HeroCarEditPanelVM.refreshed()
                }
            }
            function onNotifyUpdateObstacle(id) {
                if (simulation_edit_property_rect_id.currentEditModelType == 2) {
                    ObstacleEditPanelVM.refreshed(id)
                    //ObstacleEditPanelVM.dataUpdated(simulation_edit_property_rect_id.currentEditModel)
                }
            }

            function onEmptyEditDisplay(){
                HeroCarEditPanelVM.cleared();
                ObstacleEditPanelVM.cleared();
                HeroCarEditPanelVM.visible = false
                ObstacleEditPanelVM.visible = false
                routePanel.visible = false
                TrafficLightEditPanelVM.visible = false
                circlePanel.visible = false
            }
        }

        Connections{
            target: ScenarioControl
            function onNotifyUpdateAll(){
                switch(simulation_edit_property_rect_id.currentEditModelType){
                case 1:
                    HeroCarEditPanelVM.refreshed()
                    break
                case 2:
                    if (simulation_edit_property_rect_id.currentEditModel != null)
                        ObstacleEditPanelVM.refreshed(simulation_edit_property_rect_id.currentEditModel.id)
                    break
                default:
                    break;
                }
            }

            function onNotifyBackToHome() {
                console.log("back to home")
                event_bus_id.backToHome()
            }
        }
	}

    // 底部 状态栏 
    Rectangle
    {
        id: simulation_bottom_tip_rect_id
        width: parent.width
        height: 50 * config_id.screenScale
        x: 0
		y: parent.height - simulation_bottom_tip_rect_id.height
        color: "#EDF1F2"

        Loader
        {
            id: simulation_bottom_tip_loader_id
            width: parent.width
            height:parent.height
            source: "qrc:///resource/qml/simulation_page/bottom_tip.qml"
            onLoaded:
            {

            }
        }
	}

    Component.onCompleted : {
        if (config_id.simulatorType === "record") {
            ScenarioControl.setSimulateMode(false)
        } else if (config_id.simulatorType === "simulate") {
            ScenarioControl.setSimulateMode(true)
        }
    }
}
