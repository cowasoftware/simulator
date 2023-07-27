import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import COWA.Simulator.VModel 1.0
import "qrc:/resource/control"
import "../../../../control"

Control{
    property var model

    contentItem: ColumnLayout{
        Label{
            horizontalAlignment: Text.AlignLeft
            text: qsTr("尺寸")
            font.pixelSize: 12 * config_id.screenScale
            color: "#000000"
        }

        GridLayout{
            Layout.leftMargin: 24 * config_id.screenScale
            columns: 2
            columnSpacing: 24 * config_id.screenScale

            EditField{
                id:lengthEditField
                Layout.preferredWidth: 96 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("L")
                unit.text: qsTr("m")
                text: ObstacleEditPanelVM.length.toFixed(2)
                interval.bottom: 0.0
                onAccepted: {
                    ObstacleEditPanelVM.length = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.length.toFixed(2))
                    }
                }
            }

            EditField{
                id:widthEditField
                Layout.preferredWidth: 96 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("W")
                unit.text: qsTr("m")
                text: ObstacleEditPanelVM.width.toFixed(2)
                interval.bottom: 0.0
                onAccepted: {
                    ObstacleEditPanelVM.width = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.width.toFixed(2))
                    }
                }
            }

            EditField{
                id: heightEditField
                Layout.preferredWidth: 96 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("H")
                unit.text: qsTr("m")
                text: ObstacleEditPanelVM.height.toFixed(2)
                interval.bottom: 0.0
                onAccepted: {
                    ObstacleEditPanelVM.height = value.toFixed(2)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.height.toFixed(2))
                    }
                }
            }

            Button{
                id: btnLocker
                property bool unlocked: true
                Layout.preferredWidth: 18 * config_id.screenScale
                Layout.preferredHeight: 18 * config_id.screenScale
                background: Item{}
                contentItem: Image{
                    anchors.fill: parent
                    source: parent.unlocked ?  "qrc:/resource/image/simulation_page/icon_property_unlock.png" : "qrc:/resource/image/simulation_page/icon_property_lock.png"
                }
                onClicked: unlocked = !unlocked
            }
        }

        // 扰动控制
        Label{
            horizontalAlignment: Text.AlignLeft
            text: qsTr("扰动控制")
            font.pixelSize: 12 * config_id.screenScale
            color: "#000000"
        }

        GridLayout {
            Layout.leftMargin: 24 * config_id.screenScale
            columns: 2
            columnSpacing: 2 * config_id.screenScale

            ButtonGroup {
                id: btnGroup
            }
            // disturbance coefficient
            DriveCheckButton {
                id: undisturbed_id
                Layout.preferredWidth: 90 * config_id.screenScale
                Layout.preferredHeight: 20 * config_id.screenScale
                x : 10 * config_id.screenScale
                checked : ObstacleEditPanelVM.is_disturbable === false
                ButtonGroup.group: btnGroup
                text: qsTr("否")
                onClicked: {
                    ObstacleEditPanelVM.is_disturbable = false
                }
            }

            DriveCheckButton {
                id: disturbable_id
                Layout.preferredWidth: 90 * config_id.screenScale
                Layout.preferredHeight: 20 * config_id.screenScale
                x : 10 * config_id.screenScale
                checked : ObstacleEditPanelVM.is_disturbable === true
                ButtonGroup.group: btnGroup
                text: qsTr("是")
                onClicked: {
                    ObstacleEditPanelVM.is_disturbable = true
                    ObstacleEditPanelVM.edited()
                }
            }

            EditField{
                id: disturbableCoeffiEdit
                Layout.preferredWidth: 126 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                visible: ObstacleEditPanelVM.is_disturbable === true
                
                leftPadding: 80 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("扰动系数(0~1)")
                // unit.text: qsTr("%")
                text: ObstacleEditPanelVM.disturbance_coefficient.toFixed(1)
                interval.bottom: 0.0
                validator: RegExpValidator {regExp:  /^([0-1]{1}||[0].[1-9]{1})$/}
                onAccepted: {
                    ObstacleEditPanelVM.disturbance_coefficient = value.toFixed(1)
                    ObstacleEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,ObstacleEditPanelVM.disturbance_coefficient.toFixed(1))
                    }
                }
            }
        }
    }

    Connections{
        target: ObstacleEditPanelVM
        function onFocusLosed(){
            lengthEditField.focus = false
            widthEditField.focus = false
            heightEditField.focus = false
        }
    }
}
