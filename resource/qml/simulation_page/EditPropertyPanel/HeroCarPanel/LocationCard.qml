import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import COWA.Simulator.VModel 1.0
import "qrc:/resource/control"
import "../../../../control"
Control{
    id: location_card_control

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
                text: HeroCarEditPanelVM.x.toFixed(2)
                onAccepted:{
                    HeroCarEditPanelVM.x = value.toFixed(2)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.x.toFixed(2))
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
                text: HeroCarEditPanelVM.y.toFixed(2)
                onAccepted:{
                    HeroCarEditPanelVM.y = value.toFixed(2)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.y.toFixed(2))
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
                text: HeroCarEditPanelVM.z.toFixed(2)
                onAccepted:{
                    HeroCarEditPanelVM.z = value.toFixed(2)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.z.toFixed(2))
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
                text: HeroCarEditPanelVM.theta.toFixed(2)
                onAccepted:{
                    HeroCarEditPanelVM.theta = value.toFixed(2)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.theta.toFixed(2))
                    }
                }
            }

            EditField{
                id: vecEditField
                Layout.preferredWidth: 180 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("速度")
                unit.text: qsTr("m/s")
                text: HeroCarEditPanelVM.speed.toFixed(2)
                onAccepted:{
                    HeroCarEditPanelVM.speed = value.toFixed(2)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.speed.toFixed(2))
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#BBBBBB"
        }

        Label{
            id: throttle_label_id
            width: location_card_control.leftPadding
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 12 * config_id.screenScale
            color: "#8CA2AA"

            text: "throttle：" + HeroCarEditPanelVM.throttle.toFixed(2)
        }

        Label{
            id: steer_label_id
            width: location_card_control.leftPadding
            height: parent.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 12 * config_id.screenScale
            color: "#8CA2AA"

            text: "steer：" + HeroCarEditPanelVM.steer.toFixed(2)
        }

        // Label{
        //     id: vec_label_id
        //     width: location_card_control.leftPadding
        //     height: parent.height
        //     horizontalAlignment: Text.AlignLeft
        //     verticalAlignment: Text.AlignVCenter
        //     font.pixelSize: 12
        //     color: "#8CA2AA"

        //     text: "速度：" + HeroCarEditPanelVM.speed.toFixed(2) + " m/s"
        // }

    }

    Connections{
        target: HeroCarEditPanelVM
        function onFocusLosed(){
            xEditField.focus = false
            yEditField.focus = false
            zEditField.focus = false
            thetaEditField.focus = false
        }
    }
}
