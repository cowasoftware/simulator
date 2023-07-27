import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import COWA.Simulator.VModel 1.0
import "qrc:/resource/control"
import "../../../../control"
Control{
    contentItem: ColumnLayout{
        Label{
            horizontalAlignment: Text.AlignLeft
            text: qsTr("位置")
            font.pixelSize: 12 * config_id.screenScale
            color: "#000000"
        }

        GridLayout{
            Layout.leftMargin: 24 * config_id.screenScale
            columns: 1

            EditField{
                id: xEditField
                Layout.preferredWidth: 180 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("X")
                unit.text: qsTr("m")
                text: ObstacleEditPanelVM.x.toFixed(2)
                onAccepted:{
                    ObstacleEditPanelVM.x = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.x.toFixed(2))
                    }
                }
            }

            EditField{
                id: yEditField
                Layout.preferredWidth: 180 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("Y")
                unit.text: qsTr("m")
                text: ObstacleEditPanelVM.y.toFixed(2)
                onAccepted:{
                    ObstacleEditPanelVM.y = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.y.toFixed(2))
                    }
                }
            }

            EditField{
                id: zEditField
                Layout.preferredWidth: 180 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("Z")
                unit.text: qsTr("m")
                text: ObstacleEditPanelVM.z.toFixed(2)
                onAccepted:{
                    ObstacleEditPanelVM.z = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.z.toFixed(2))
                    }
                }
            }

            EditField{
                id: thetaEditField
                Layout.preferredWidth: 180 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                icon.width: 14 * config_id.screenScale
                icon.height: 14 * config_id.screenScale
                icon.source: "qrc:/resource/image/simulation_page/icon_property_rotate.png"
                text: ObstacleEditPanelVM.theta.toFixed(2)
                onAccepted:{
                    ObstacleEditPanelVM.theta = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.theta.toFixed(2))
                    }
                }
            }
        }
    }

    Connections{
        target: ObstacleEditPanelVM
        function onFocusLosed(){
            xEditField.focus = false
            yEditField.focus = false
            zEditField.focus = false
            thetaEditField.focus = false
        }
    }
}
