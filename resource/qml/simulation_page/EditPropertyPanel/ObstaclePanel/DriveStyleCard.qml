import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import COWA.Simulator  1.0
import COWA.Simulator.VModel 1.0

import "qrc:/resource/qml/event_bus"
import "qrc:/resource/control"
import "../../../../control"

Control{

    ListModel {
        id: lineModel
    }

    Component.onCompleted: {
        var line_ids = ScenarioControl.getAllCurveModelId()
        for (var i = 0; i < line_ids.length; ++i) {
            lineModel.append({"value": line_ids[i], "text": "路线-" + line_ids[i]})
        }
    }

    contentItem: ColumnLayout {
        spacing : 12 * config_id.screenScale
        RowLayout{
            Label{
                horizontalAlignment: Text.AlignLeft
                text: qsTr("控制方式")
                font.pixelSize: 12 * config_id.screenScale
                color: "#000000"
            }

            Item{
                Layout.fillWidth: true
            }

        }

        ColumnLayout {
            spacing : 5 * config_id.screenScale
            ButtonGroup{
                id: btnGroup
            }

            Layout.leftMargin: 12 * config_id.screenScale
            DriveCheckButton {
                id: algorithmBtn1
                Layout.preferredWidth: 72 * config_id.screenScale
                Layout.preferredHeight: 20 * config_id.screenScale
                ButtonGroup.group: btnGroup
                checked : ObstacleEditPanelVM.mode === obstacle_panel_control.driveModeByStraight
                text: qsTr("沿直线行驶")
                onClicked: {
                    ObstacleEditPanelVM.mode = obstacle_panel_control.driveModeByStraight;
                    ObstacleEditPanelVM.edited()
                }
            }


            DriveCheckButton {
                id: algorithmBtn2
                Layout.preferredWidth: 72 * config_id.screenScale
                Layout.preferredHeight: 20 * config_id.screenScale
                ButtonGroup.group: btnGroup
                checked : ObstacleEditPanelVM.mode === obstacle_panel_control.driveModeByLane
                text: qsTr("沿车道线行驶")
                onClicked: {
                    ObstacleEditPanelVM.mode = obstacle_panel_control.driveModeByLane;
                    ObstacleEditPanelVM.edited()
                }
            }
            DriveCheckButton {
                visible : config_id.isUsingAI
                id: algorithmBtn3
                Layout.preferredWidth: 72 * config_id.screenScale
                Layout.preferredHeight: 20 * config_id.screenScale
                ButtonGroup.group: btnGroup
                checked : ObstacleEditPanelVM.mode === obstacle_panel_control.driveModeByRL
                text: qsTr("强化学习控车")
                onClicked: {
                    ObstacleEditPanelVM.mode = driveModeByRL;
                    ObstacleEditPanelVM.edited()
                }
            }
            DriveCheckButton {
                id: algorithmBtn4
                Layout.preferredWidth: 72 * config_id.screenScale
                Layout.preferredHeight: 20 * config_id.screenScale
                ButtonGroup.group: btnGroup
                checked : ObstacleEditPanelVM.mode === obstacle_panel_control.driveModeByCurve
                text: qsTr("按轨迹线行驶")
                onClicked: {
                    ObstacleEditPanelVM.mode = obstacle_panel_control.driveModeByCurve;
                    ObstacleEditPanelVM.edited()
                }
            }
            DriveComboBox {
                id : line_select_id4
                visible: algorithmBtn4.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale

                textRole: "text"
                valueRole: "value"
                model : lineModel
                currentIndex: ObstacleEditPanelVM.route >= 0 ? indexOfValue(ObstacleEditPanelVM.route) : -1
                onActivated:{
                    if (lineModel.count == 0) return
                   ScenarioControl.unbindCurvePoints(ObstacleEditPanelVM.route, ObstacleEditPanelVM.id)
                   ScenarioControl.bindCurvePoints(currentValue, ObstacleEditPanelVM.id)
                   ObstacleEditPanelVM.route = currentValue
                   ObstacleEditPanelVM.edited()
                }
            }
            DriveCheckButton {
                visible : config_id.isUsingAI
                id: algorithmBtn5
                Layout.preferredWidth: 72 * config_id.screenScale
                Layout.preferredHeight: 20 * config_id.screenScale
                ButtonGroup.group: btnGroup
                checked : ObstacleEditPanelVM.mode === obstacle_panel_control.driveModeByDL
                text: qsTr("预测和规则控制")
                onClicked: {
                    ObstacleEditPanelVM.mode = obstacle_panel_control.driveModeByDL;
                    ObstacleEditPanelVM.speed = 2.0;
                    ObstacleEditPanelVM.edited()
                }
            }
            DriveCheckButton {
                visible : config_id.isUsingAI
                id: algorithmBtn6
                Layout.preferredWidth: 72 * config_id.screenScale
                Layout.preferredHeight: 20 * config_id.screenScale
                ButtonGroup.group: btnGroup
                checked : ObstacleEditPanelVM.mode === obstacle_panel_control.driveModeByRouting
                text: qsTr("指定导航路线行驶")
                onClicked: {
                    ObstacleEditPanelVM.mode = obstacle_panel_control.driveModeByRouting;
                    ObstacleEditPanelVM.edited()
                }
            }
            DriveComboBox{
                id : line_select_id6
                visible: algorithmBtn6.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale

                textRole: "text"
                valueRole: "value"
                model : lineModel
                currentIndex: indexOfValue(ObstacleEditPanelVM.route)
                onActivated:{
                   ScenarioControl.unbindCurvePoints(ObstacleEditPanelVM.route, ObstacleEditPanelVM.id)
                   ScenarioControl.bindCurvePoints(currentValue, ObstacleEditPanelVM.id)
                   ObstacleEditPanelVM.route = currentValue
                   ObstacleEditPanelVM.edited()
                }
            }
        }


        RowLayout{
            Label{
                horizontalAlignment: Text.AlignLeft
                text: qsTr("触发方式")
                font.pixelSize: 12 * config_id.screenScale
                color: "#000000"
            }

            Item{
                Layout.fillWidth: true
            }
        }
        ColumnLayout{
            ButtonGroup{
                id: triggerBtnGroup
            }

            spacing : 5 * config_id.screenScale
            Layout.leftMargin: 12 * config_id.screenScale

            ColumnLayout{
                DriveCheckButton {
                    id: trigger_by_time_check_id
                    Layout.preferredWidth: 90 * config_id.screenScale
                    Layout.preferredHeight: 20 * config_id.screenScale
                    x : 10 * config_id.screenScale
                    checked : ObstacleEditPanelVM.trigger_type === obstacle_panel_control.triggerByTime
                    ButtonGroup.group: triggerBtnGroup
                    text: qsTr("时间触发点")
                    onClicked: {
                        ObstacleEditPanelVM.trigger_type = obstacle_panel_control.triggerByTime
                        ObstacleEditPanelVM.trigger_parameter = 0
                        ObstacleEditPanelVM.trigger_parameter_str = ""
                        ObstacleEditPanelVM.edited()
                    }
                }

                DriveCheckButton {
                    id: trigger_by_distance_check_id
                    Layout.preferredWidth: 90 * config_id.screenScale
                    Layout.preferredHeight: 20 * config_id.screenScale
                    anchors.rightMargin: 20 * config_id.screenScale
                    x: parent.width / 2 + 10 * config_id.screenScale
                    checked : ObstacleEditPanelVM.trigger_type === obstacle_panel_control.triggerByDistance
                    ButtonGroup.group: triggerBtnGroup
                    text: qsTr("距离触发点")
                    onClicked: {
                        ObstacleEditPanelVM.trigger_type = obstacle_panel_control.triggerByDistance
                        ObstacleEditPanelVM.trigger_parameter = 10
                        ObstacleEditPanelVM.trigger_parameter_str = ""
                        ObstacleEditPanelVM.edited()
                    }
                }
                DriveCheckButton {
                    id: trigger_by_location_check_id
                    Layout.preferredWidth: 90 * config_id.screenScale
                    Layout.preferredHeight: 20 * config_id.screenScale
                    anchors.rightMargin: 20 * config_id.screenScale
                    x: parent.width / 2 + 10 * config_id.screenScale
                    checked : ObstacleEditPanelVM.trigger_type === obstacle_panel_control.triggerByLocation
                    ButtonGroup.group: triggerBtnGroup
                    text: qsTr("主车位置")
                    onClicked: {
                        ObstacleEditPanelVM.trigger_type = obstacle_panel_control.triggerByLocation
                        ObstacleEditPanelVM.trigger_parameter = 0
                        ObstacleEditPanelVM.trigger_parameter_str = ""
                        ObstacleEditPanelVM.edited()
                    }
                }
            }
            EditField{
                visible :  trigger_by_time_check_id.checked || trigger_by_distance_check_id.checked
                id:trigger_param_id
                Layout.preferredWidth: 150 * config_id.screenScale
                Layout.preferredHeight: 25 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: trigger_by_time_check_id.checked ? qsTr("时间点") : qsTr("主车距离")
                unit.text: trigger_by_time_check_id.checked ? qsTr("秒") : qsTr("米")
                text: ObstacleEditPanelVM.trigger_parameter
                interval.bottom: 0.0
                onAccepted: {
                    ObstacleEditPanelVM.trigger_parameter = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.trigger_parameter.toFixed(2))
                    }
                }
            }
            TextField {
                visible : trigger_by_location_check_id.checked
                id:trigger_param_str_id
                Layout.preferredWidth: 200 * config_id.screenScale
                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter
                font.pixelSize: 12 * config_id.screenScale
                text: ObstacleEditPanelVM.trigger_parameter_str
                color: "#000000"
                selectByMouse: true
                selectionColor: "#999999"//选中背景颜色
                placeholderText: ObstacleEditPanelVM.trigger_parameter_str == "" ? qsTr("主车坐标x,y") : ObstacleEditPanelVM.trigger_parameter_str
                background: Rectangle {
                    border.width: 1; //border.color: "#B2B2B2"
                    radius: 4; 
                    border.color: "#000000"
                    color: "#FFFFFF" //"transparent"
                    opacity: 0.1
                    implicitWidth: 100 * config_id.screenScale
                }
                onAccepted: {
                    console.log("trigger_by_location_check_id text ", text)
                    ObstacleEditPanelVM.trigger_parameter_str = text
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.trigger_parameter_str)
                    }
                }
            }
        }
    }


    Connections {
		target: ScenarioControl
        function onNotifyAddCurveModel(line_id) {
			var element = {}
            element.value = line_id
            element.text = qsTr("轨迹线") + "-" + line_id
			lineModel.append(element)
		}
		function onNotifyDeleteCurveModel(line_id) {
            var pos = -1;
            for (var i = 0; i < lineModel.count; i++) {
                if (lineModel.get(i).value == line_id) {
                    pos = i;
                    break;
                }
            }
            if (pos >= 0) {
                lineModel.remove(pos)
            }    
        }
    
    }
}
