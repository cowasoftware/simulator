import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import COWA.Simulator.VModel 1.0
import "qrc:/resource/control"
import "../../../../control"
Control{
    property var model

    contentItem: ColumnLayout{
        GridLayout{
            Layout.leftMargin: 0

            columnSpacing: 24 * config_id.screenScale
            columns: 1

            Rectangle {
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                ButtonGroup{
                    id: btnGroup
                }

                RowLayout{
                    spacing: 10 * config_id.screenScale
                    DriveCheckButton {
                        id: kineticSelect1
                        visible: false
                        Layout.preferredWidth: 60 * config_id.screenScale
                        Layout.preferredHeight: 20 * config_id.screenScale
                        x : 10 * config_id.screenScale
                        checked : HeroCarEditPanelVM.dynamic_model === 0
                        checkable: false
                        ButtonGroup.group: btnGroup
                        text: qsTr("动力学")
                        onClicked: {
                            HeroCarEditPanelVM.dynamic_model = 0
                            HeroCarEditPanelVM.edited()
                        }
                    }
                    DriveCheckButton {
                        id: kineticSelect2
                        Layout.preferredWidth: 60 * config_id.screenScale
                        Layout.preferredHeight: 20 * config_id.screenScale
                        anchors.rightMargin: 20 * config_id.screenScale
                        x: parent.width / 2 + 10 * config_id.screenScale
                        checked : HeroCarEditPanelVM.dynamic_model === 1
                        ButtonGroup.group: btnGroup
                        text: qsTr("运动学")
                        onClicked: {
                            HeroCarEditPanelVM.dynamic_model = 1
                            HeroCarEditPanelVM.edited()
                        }
                    }
                    DriveCheckButton {
                        id: kineticSelect3
                        Layout.preferredWidth: 60 * config_id.screenScale
                        Layout.preferredHeight: 20 * config_id.screenScale
                        x : 10 * config_id.screenScale
                        checked : HeroCarEditPanelVM.dynamic_model === 2
                        ButtonGroup.group: btnGroup
                        text: qsTr("跟随规划")
                        onClicked: {
                            HeroCarEditPanelVM.dynamic_model = 2
                            HeroCarEditPanelVM.edited()
                        }
                    }
                    DriveCheckButton {
                        id: kineticSelect4
                        Layout.leftMargin: 20 * config_id.screenScale
                        Layout.preferredWidth: 60 * config_id.screenScale
                        Layout.preferredHeight: 20 * config_id.screenScale
                        x : 10 * config_id.screenScale
                        checked : HeroCarEditPanelVM.dynamic_model === 3
                        ButtonGroup.group: btnGroup
                        text: qsTr("模型")
                        onClicked: {
                            HeroCarEditPanelVM.dynamic_model = 3
                            HeroCarEditPanelVM.edited()
                        }
                    }
                }
            }
   
            Rectangle {
                visible : !kineticSelect3.checked &&  !kineticSelect4.checked
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#BBBBBB"
            }

            Label{
                visible : !kineticSelect3.checked &&  !kineticSelect4.checked
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Vehicle参数")
                font.pixelSize: 12 * config_id.screenScale
                color: "#000000"
            }
            
            EditField{
                visible : !kineticSelect3.checked &&  !kineticSelect4.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("wheel_base")
                tips.text: qsTr("前后轴之间的距离m")
                unit.text: qsTr("m")
                text: HeroCarEditPanelVM.wheelbase.toFixed(2)
                onAccepted:{
                    HeroCarEditPanelVM.wheelbase = value.toFixed(2)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.wheelbase.toFixed(2))
                    }
                }
            }
            EditField{
                visible : kineticSelect1.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("mass_f")
                tips.text: qsTr("前轮所承受质量kg")
                unit.text: qsTr("kg")
                text: HeroCarEditPanelVM.massf.toFixed(2)
                onAccepted:{
                    HeroCarEditPanelVM.massf = value.toFixed(2)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.massf.toFixed(2))
                    }
                }
            }
            EditField{
                visible : kineticSelect1.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("mass_r")
                tips.text: qsTr("后轮所承受质量 kg")
                unit.text: qsTr("kg")
                text: HeroCarEditPanelVM.massr.toFixed(2)
                onAccepted:{
                    HeroCarEditPanelVM.massr = value.toFixed(2)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.massr.toFixed(2))
                    }
                }
            }
            EditField{
                visible : kineticSelect1.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("c_f")
                tips.text: qsTr("前轮单位侧偏角能形成的侧偏力 N/rad")
                unit.text: qsTr("N/rad")
                text: HeroCarEditPanelVM.cf.toFixed(2)
                onAccepted:{
                    HeroCarEditPanelVM.cf = value.toFixed(2)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.cf.toFixed(2))
                    }
                }
            }
            EditField{
                visible : kineticSelect1.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("c_r")
                tips.text: qsTr("后轮单位侧偏角能形成的侧偏力 N/rad")
                unit.text: qsTr("N/rad")
                text: HeroCarEditPanelVM.cr.toFixed(2)
                onAccepted:{
                    HeroCarEditPanelVM.cr = value.toFixed(2)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.cr.toFixed(2))
                    }
                }
            }
            EditField{
                visible : kineticSelect2.checked &&  !kineticSelect4.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("compensator_slope")
                tips.text: qsTr("线性补偿系数")
                unit.text: qsTr("")
                text: HeroCarEditPanelVM.ackermann_compensator_slope.toFixed(5)
                onAccepted:{
                    HeroCarEditPanelVM.ackermann_compensator_slope = value.toFixed(5)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.ackermann_compensator_slope.toFixed(5))
                    }
                }
            }
            EditField{
                visible : kineticSelect2.checked &&  !kineticSelect4.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("compensator_offset")
                tips.text: qsTr("线性补偿偏移量")
                unit.text: qsTr("")
                text: HeroCarEditPanelVM.ackermann_compensator_offset.toFixed(5)
                onAccepted:{
                    HeroCarEditPanelVM.ackermann_compensator_offset = value.toFixed(5)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.ackermann_compensator_offset.toFixed(5))
                    }
                }
            }

            Rectangle {
                visible : !kineticSelect3.checked &&  !kineticSelect4.checked
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#BBBBBB"
            }
            Label{
                visible : !kineticSelect3.checked &&  !kineticSelect4.checked
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Chassis参数")
                font.pixelSize: 12 * config_id.screenScale
                color: "#000000"
            }

            EditField{
                visible : !kineticSelect3.checked &&  !kineticSelect4.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("time_constant")
                tips.text: qsTr("一阶系统时间常数")
                unit.text: qsTr("")
                text: HeroCarEditPanelVM.omega1st.toFixed(1)
                onAccepted:{
                    HeroCarEditPanelVM.omega1st = value.toFixed(1)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.omega1st.toFixed(1))
                    }
                }
            }
            EditField{
                visible : !kineticSelect3.checked &&  !kineticSelect4.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("omega")
                tips.text: qsTr("二阶系统自然振荡频率")
                unit.text: qsTr("")
                text: HeroCarEditPanelVM.omega2ed.toFixed(1)
                onAccepted:{
                    HeroCarEditPanelVM.omega2ed = value.toFixed(1)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.omega2ed.toFixed(1))
                    }
                }
            }
            EditField{
                visible : !kineticSelect3.checked &&  !kineticSelect4.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("zeta")
                tips.text: qsTr("二阶系统阻尼比")
                unit.text: qsTr("")
                text: HeroCarEditPanelVM.zeta.toFixed(1)
                onAccepted:{
                    HeroCarEditPanelVM.zeta = value.toFixed(1)
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.zeta.toFixed(1))
                    }
                }
            }
            EditField{
                visible : !kineticSelect3.checked &&  !kineticSelect4.checked
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 100 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("delay")
                tips.text: qsTr("底盘对控制指令的响应滞后周期")
                unit.text: qsTr("")
                text: HeroCarEditPanelVM.delay
                onAccepted:{
                    HeroCarEditPanelVM.delay = value
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.delay)
                    }
                }
                
            }
        }
    }
}
