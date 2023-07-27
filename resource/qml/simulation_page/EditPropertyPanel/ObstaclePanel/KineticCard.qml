import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import COWA.Simulator.VModel 1.0

import "qrc:/resource/qml/event_bus"
import "qrc:/resource/control"
import "../../../../control"

Control{
    property var model

    contentItem: ColumnLayout{
        RowLayout{
            Label{
                horizontalAlignment: Text.AlignLeft
                text: qsTr("速度模型")
                font.pixelSize: 12 * config_id.screenScale
                color: "#000000"
            }

            Item{
                Layout.fillWidth: true
            }

            Button{
                Layout.preferredWidth: 12 * config_id.screenScale
                Layout.preferredHeight: 12 * config_id.screenScale
                background: Item{}
                contentItem: Image{
                    anchors.fill: parent
                    source: "qrc:/resource/image/simulation_page/icon_edit_property_kinetic_refresh.png"
                }
            }
        }

        GridLayout{
            Layout.leftMargin: 24 * config_id.screenScale
            columns:  1

            EditField{
                id: speedEditField
                Layout.preferredWidth: 150 * config_id.screenScale
                Layout.preferredHeight: 25 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("当前速度")
                unit.text: qsTr("m/s")
                text: ObstacleEditPanelVM.speed.toFixed(2)
                interval.bottom: 0.0
                onAccepted:{
                    ObstacleEditPanelVM.speed = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.speed.toFixed(2))
                    }
                }
            }

            EditField{
                id:targetSpeedEditField
                visible : ObstacleEditPanelVM.mode !== obstacle_panel_control.driveModeByDL && ObstacleEditPanelVM.mode !== obstacle_panel_control.driveModeByRL && ObstacleEditPanelVM.mode !== obstacle_panel_control.driveModeByRouting
                Layout.preferredWidth: 150 * config_id.screenScale
                Layout.preferredHeight: 25 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("目标速度")
                unit.text: qsTr("m/s")
                text: ObstacleEditPanelVM.targetSpeed.toFixed(2)
                interval.bottom: 0.0
                onAccepted: {
                    ObstacleEditPanelVM.targetSpeed = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.targetSpeed.toFixed(2))
                    }
                }
            }


            EditField{
                id: accEditField
                visible : ObstacleEditPanelVM.mode !== obstacle_panel_control.driveModeByDL && ObstacleEditPanelVM.mode !== obstacle_panel_control.driveModeByRL
                Layout.preferredWidth: 150 * config_id.screenScale
                Layout.preferredHeight: 25 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("加速度")
                unit.text: qsTr("m/s2")
                text: ObstacleEditPanelVM.acc.toFixed(2)
                interval.bottom: 0.0
                onAccepted: {
                    ObstacleEditPanelVM.acc = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.acc.toFixed(2))
                    }
                }
            }
        }
    }

    Connections{
        target: ObstacleEditPanelVM
        function onFocusLosed(){
            speedEditField.focus = false
            targetSpeedEditField.focus = false
            accEditField.focus = false
        }
    }
}
