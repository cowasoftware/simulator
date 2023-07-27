import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3

import COWA.Simulator.VModel 1.0
import COWA.Simulator 1.0

import "qrc:/resource/control"
import "../../../../control"

Control {
    id: routing_card
    contentItem: ColumnLayout {
        RowLayout {
            spacing: 10 * config_id.screenScale

            ButtonGroup {
                id: btnGroup
            }
            Rectangle {
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                // 启用routing按钮
                DriveCheckButton {
                    id: routingEnableId
                    Layout.preferredWidth: 60 * config_id.screenScale
                    Layout.preferredHeight: 20 * config_id.screenScale
                    x : 10 * config_id.screenScale
                    checked : HeroCarEditPanelVM.enable_routing === true
                    ButtonGroup.group: btnGroup
                    text: qsTr("是否启用仿真下发的Routing")
                    onClicked: {
                        HeroCarEditPanelVM.enable_routing = !HeroCarEditPanelVM.enable_routing
                        HeroCarEditPanelVM.edited()
                    }
                }
            }
        }
        RowLayout {
            spacing: 10 * config_id.screenScale
            Rectangle {
                Layout.preferredWidth: 200 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                FileDialog {
                    id: file_open_routing_dialog
                    title: "Please choose a file"
                    selectExisting: true
                    selectFolder : false
                    selectMultiple : false

                    onAccepted: {
                        var all = Qt.resolvedUrl(fileUrl).toString()
                        var file_abs_path = all.substring(7, all.length)
                        console.log("You chose file: ", all, file_abs_path);

                        if (ScenarioControl.openRoutingFile(file_abs_path))
                        {
                            console.log("routing文件打开成功");
                            SimulatorControl.syncSceneToServer()
                        }
                        main_page_rect_id.forceActiveFocus()
                    }
                    onRejected: {
                        console.log("Canceled")
                        main_page_rect_id.forceActiveFocus()
                    }
                }
                Button {
                    id: open_routing_button_id
                    Layout.preferredWidth: 25 * config_id.screenScale
                    Layout.preferredHeight: 25 * config_id.screenScale
                    x : 10 * config_id.screenScale
                    Layout.alignment: Qt.AlignVCenter
                    background: Rectangle {
                        color: parent.hovered ? "#E1E3E6" : "transparent"
                    }
                    contentItem: Image {
                        anchors.fill: parent
                        source: "qrc:///resource/image/simulation_page/icon_menu_file_target.png"
                    }
                    MouseArea {
                        property bool entered: false
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: entered = true
                        onExited: entered = false
                        onClicked: {
                            if (event_bus_id.is_playing)
                            {
                                console.log("当前正处于仿真状态，请在暂停或结束后进行保存\n");
                                return
                            }
                            console.log("open dialog")
                            file_open_routing_dialog.open();
                        }
                        // ToolTip {
                        //     visible: parent.entered
                        //     text: "打开routing文件"
                        //     delay: 500
                        // }
                    }
                }
                Label{
                    visible : true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: open_routing_button_id.right
                    anchors.leftMargin: 10
                    text: qsTr("打开routing文件")
                    font.pixelSize: 12 * config_id.screenScale
                    color: "#000000"
                }
            }
            
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#BBBBBB"
        }

        RowLayout{
            Layout.fillWidth: true
            Layout.bottomMargin: 18 * config_id.screenScale
            Layout.topMargin: 18 * config_id.screenScale
            // Layout.leftMargin: 24 * config_id.screenScale
            Layout.leftMargin: 0
            // Layout.rightMargin: 24 * config_id.screenScale
            Layout.rightMargin: 0

            Label{
                Layout.fillWidth: true
                Layout.preferredWidth: 18 * config_id.screenScale
                Layout.preferredHeight: 18 * config_id.screenScale
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "X"
                color: "#8CA2AA"
                font.pixelSize: 12 * config_id.screenScale
            }
            Label{
                Layout.fillWidth: true
                Layout.preferredWidth: 18 * config_id.screenScale
                Layout.preferredHeight: 18 * config_id.screenScale
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "Y"
                color: "#8CA2AA"
                font.pixelSize: 12 * config_id.screenScale
            }
            Label{
                Layout.fillWidth: true
                Layout.preferredWidth: 24 * config_id.screenScale
                Layout.preferredHeight: 18 * config_id.screenScale
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "mode"
                color: "#8CA2AA"
                font.pixelSize: 12 * config_id.screenScale
            }
            Label{
                Layout.fillWidth: true
                Layout.preferredWidth: 24 * config_id.screenScale
                Layout.preferredHeight: 18 * config_id.screenScale
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "side"
                color: "#8CA2AA"
                font.pixelSize: 12 * config_id.screenScale
            }
        }

        ListView {
            Layout.fillWidth: true
            // Layout.fillHeight: true
            Layout.fillHeight: true
            // height:  500* config_id.screenScale
            // implicitHeight: parent.height
            spacing: 6 * config_id.screenScale
            model: routeModel
            delegate: routeDelegate
            // ScrollBar.vertical: ScrollBar{}
            orientation: ListView.Vertical
            // boundsBehavior:Flickable.StopAtBounds
            ScrollIndicator.vertical: ScrollIndicator { }


            Connections
            {
                target: ScenarioControl
                function onNotifySetHeroRoutingPoints(points) {
                    console.log("onRoutingModelChanged1")
                    var routing_model = ScenarioControl.findRoutingModel()
                    // console.log("onRoutingModelChanged", routing_model)
                    if (routing_model != null) {
                        // console.log("onRoutingModelChanged3")
                        routeModel.clear()
                        for (var i = 0; i < points.length; ++i) {
                            var x = points[i].x.toFixed(2)
                            var y = points[i].y.toFixed(2)
                            console.log("onRoutingModelChanged")
                            var mode = routing_model.getWorkMode(i)
                            var side = routing_model.getWorkSide(i)
                            console.log("onRoutingModelChanged RoutingModel[i].x", x, y, mode, side)
                            routeModel.append({"x": x ,"y": y, "mode": mode, "side":side})
                        }
                    }
                }
            }
        }
    }

    ListModel{
        id: routeModel
    
    }

    Component{
        id: routeDelegate
        Control{
            id: routeControl
            width: ListView.view.width
            height: 60 * config_id.screenScale
            leftPadding : 0
            rightPadding : 0
            
            property var current_point_index : index
            property var item_data : model

            contentItem: RowLayout{
                width: parent.availableWidth
                height: parent.availableHeight

                ColumnLayout {
                    Layout.preferredHeight: 72 * config_id.screenScale
                    RowLayout {
                        Label{
                            Layout.fillWidth: true
                            Layout.preferredWidth: 32 * config_id.screenScale
                            Layout.preferredHeight: 18 * config_id.screenScale
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: item_data.x
                            color: "#000000"
                            font.pixelSize: 12 * config_id.screenScale
                        }
                        Label{
                            Layout.fillWidth: true
                            Layout.preferredWidth: 32 * config_id.screenScale
                            Layout.preferredHeight: 18 * config_id.screenScale
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: item_data.y
                            color: "#000000"
                            font.pixelSize: 12 * config_id.screenScale
                        }
                    }

                    RowLayout {
                        spacing: 9 * config_id.screenScale
                        DriveComboBox {
                            id : mode_id
                            Layout.preferredWidth: 120 * config_id.screenScale
                            Layout.preferredHeight: 30 * config_id.screenScale
                            Layout.leftMargin: 5 * config_id.screenScale

                            textRole: "text"
                            valueRole: "value"
                            model : workModeModel
                            currentIndex: item_data.mode
                            onActivated:{
                                console.log("mode_id onActivated ", index, current_point_index)
                                var routing_model = ScenarioControl.findRoutingModel()
                                if (routing_model != undefined) {
                                    routing_model.setWorkMode(current_point_index, index)
                                    item_data.mode = index
                                }
                            }

                            onCurrentIndexChanged: {
                                console.log("currentIndex", currentIndex, "item_data.mode", item_data.mode)

                            }
                            Component.onCompleted: {
                                console.log("onCompleted currentIndex", currentIndex, "item_data.mode", item_data.mode)
                            }
                        }


                        DriveComboBox {
                            id : side_id
                            Layout.preferredWidth: 120 * config_id.screenScale
                            Layout.preferredHeight: 30 * config_id.screenScale
                            Layout.rightMargin: 5 * config_id.screenScale

                            textRole: "text"
                            valueRole: "value"
                            model : workSideModel
                            currentIndex: item_data.side
                            onActivated:{
                                console.log("side_id onActivated ", index, current_point_index)
                                var routing_model = ScenarioControl.findRoutingModel()
                                if (routing_model != undefined) {
                                    routing_model.setWorkSide(current_point_index, index)
                                    item_data.side = index 
                                }
                            }

                            onCurrentIndexChanged: {
                                console.log("currentIndex", currentIndex, "item_data.side", item_data.side)

                            }
                            Component.onCompleted: {
                                console.log("onCompleted currentIndex", currentIndex, "item_data.side", item_data.side)
                            }
                        }
                    }
                }
            }
        }
    }


    ListModel {
        id: workModeModel
    }
    ListModel {
        id: workSideModel
    }
    Component.onCompleted: {
        workModeModel.append({"value" : 0, "text": "Unknown"})
        workModeModel.append({"value" : 1, "text": "Unwork"})
        workModeModel.append({"value" : 2, "text": "WorkOn"})
        workModeModel.append({"value" : 3, "text": "Trans"})
        workModeModel.append({"value" : 4, "text": "Pullover"})
        workModeModel.append({"value" : 5, "text": "Parking"})
        workModeModel.append({"value" : 6, "text": "Startgo"})

        workSideModel.append({"value" : 0, "text": "Unknown"})
        workSideModel.append({"value" : 1, "text": "Left"})
        workSideModel.append({"value" : 2, "text": "Right"})
        workSideModel.append({"value" : 3, "text": "Middle"})

    }
}

