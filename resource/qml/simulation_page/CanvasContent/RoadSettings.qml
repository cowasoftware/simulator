import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

import COWA.Simulator  1.0
import "qrc:/resource/control"

Item // tips
{
    x: 10 * config_id.screenScale
    y: 10 * config_id.screenScale
    z: 1000
    width: parent.width
    height: 300 * config_id.screenScale
    Row {
        spacing : 5 * config_id.screenScale
        Column {
            Rectangle {
                width: 140 * config_id.screenScale
                height: show_label1_id.height
                color: Qt.rgba(0,0,0,0.0)
                border.width: 1
                border.color: "white"
                Label {
                    id: show_label1_id
                    text: qsTr("Object物体类型")
                    font.pixelSize: 14 * config_id.screenScale
                    font.bold: true
                }
                MouseArea {
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: {
                        crossroad_id.visible = !crossroad_id.visible
                        crosswalk_id.visible = !crosswalk_id.visible
                        ramp_id.visible = !ramp_id.visible
                        object_id.visible = !object_id.visible
                        curb_id.visible = !curb_id.visible
                        strip_id.visible = !strip_id.visible
                    }
                }
            }
            Rectangle // 十字路口
            {
                id: crossroad_id
                width: 140 * config_id.screenScale
                height: show_cross_1_id.height
                color: "#186FF0"
                border.width: 1
                border.color: "white"
                visible: true
                CustomCheckBox {
                    id : show_cross_1_id
                    text: qsTr("CROSSROAD")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : false
                    onClicked: {
                        // console.log("show_cross_1_id.checked ", show_cross_1_id.checked);
                        simulation_window_id.show_CROSSROAD = show_cross_1_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            Rectangle // 人行横道
            {
                id: crosswalk_id
                width: 140 * config_id.screenScale
                height: show_cross_2_id.height
                color: "#DEF4FF"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_cross_2_id
                    text: qsTr("CROSSWALK")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : false
                    onClicked: {
                        // console.log("show_cross_2_id.checked ", show_cross_2_id.checked);
                        simulation_window_id.show_CROSSWALK = show_cross_2_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            Rectangle // 斜坡
            {
                id: ramp_id
                width: 140 * config_id.screenScale
                height: show_ramp_id.height
                color: "#660033"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_ramp_id
                    text: qsTr("RAMP")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : false
                    onClicked: {
                        // console.log("show_ramp_id.checked ", show_ramp_id.checked);
                        simulation_window_id.show_RAMP = show_ramp_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            Rectangle // 特殊物体
            {
                id: object_id
                width: 140 * config_id.screenScale
                height: show_object_id.height
                color: "#9400D3"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_object_id
                    text: qsTr("OBJECT")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : true
                    onClicked: {
                        // console.log("show_object_id.checked ", show_object_id.checked);
                        simulation_window_id.show_OBJECT = show_object_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            Rectangle // 马路牙
            {
                id: curb_id
                width: 140 * config_id.screenScale
                height: show_curb_id.height
                color: "#FFA07A"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_curb_id
                    text: qsTr("CURB")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : false
                    onClicked: {
                        // console.log("show_object_id.checked ", show_object_id.checked);
                        simulation_window_id.show_CURB = show_curb_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            Rectangle // strip
            {
                id: strip_id
                width: 140 * config_id.screenScale
                height: show_strip_id.height
                color: "#0066cc"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_strip_id
                    text: qsTr("STRIP")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : false
                    onClicked: {
                        // console.log("show_object_id.checked ", show_object_id.checked);
                        simulation_window_id.show_STRIP = show_strip_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            
        }
        Column {
            Rectangle {
                width: 140 * config_id.screenScale
                height: show_label2_id.height
                color: Qt.rgba(0,0,0,0.0)
                border.width: 1
                border.color: "white"
                Label {
                    id: show_label2_id
                    text: qsTr("道路类型")
                    font.pixelSize: 14 * config_id.screenScale
                    font.bold: true
                }
                MouseArea {
                    hoverEnabled: true
                    anchors.fill: parent
                    onClicked: {
                        driving_id.visible = !driving_id.visible
                        biking_id.visible = !biking_id.visible
                        sidewalk_id.visible = !sidewalk_id.visible
                        waiting_id.visible = !waiting_id.visible
                        hybrid_id.visible = !hybrid_id.visible
                        bus_id.visible = !bus_id.visible
                        emergency_id.visible = !emergency_id.visible
                    }
                }
            }
            Rectangle //机动车道
            {
                id: driving_id
                width: 140 * config_id.screenScale
                height: show_road_1_id.height
                color: "#505559"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_road_1_id
                    text: qsTr("CITY_DRIVING")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : true
                    onClicked: {
                        console.log("show_road_1_id.checked ", show_road_1_id.checked);
                        simulation_window_id.show_CITY_DRIVING = show_road_1_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            Rectangle //非机动车道
            {
                id: biking_id
                width: 140 * config_id.screenScale
                height: show_road_2_id.height
                color: "#8ca2aa"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_road_2_id
                    text: qsTr("BIKING")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : true
                    onClicked: {
                        console.log("show_road_2_id.checked ", show_road_2_id.checked);
                        simulation_window_id.show_BIKING = show_road_2_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            Rectangle // 人行道
            {
                id: sidewalk_id
                width: 140 * config_id.screenScale
                height: show_road_3_id.height
                color: "#bdbdbd"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_road_3_id
                    text: qsTr("SIDEWALK")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : true
                    onClicked: {
                        console.log("show_road_3_id.checked ", show_road_3_id.checked);
                        simulation_window_id.show_SIDEWALK = show_road_3_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            } 
            Rectangle  // 待转区
            {
                id:  waiting_id
                width: 140 * config_id.screenScale
                height: show_road_4_id.height
                color: "#FFFFF0"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_road_4_id
                    text: qsTr("WAITINGAREA")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : true
                    onClicked: {
                        console.log("show_road_4_id.checked ", show_road_4_id.checked);
                        simulation_window_id.show_WAITINGAREA = show_road_4_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            Rectangle  // 机非混合道路
            {
                id: hybrid_id
                width: 140 * config_id.screenScale
                height: show_road_5_id.height
                color: "#7FFFD4"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_road_5_id
                    text: qsTr("HYBRID")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : true
                    onClicked: {
                        // console.log("show_road_5_id.checked ", show_road_5_id.checked);
                        simulation_window_id.show_HYBRID = show_road_5_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            Rectangle  // 普通公路路边停车车道
            {
                id: bus_id
                width: 140 * config_id.screenScale
                height: show_road_6_id.height
                color: "#2F4F4F"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_road_6_id
                    text: qsTr("BUS")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : true
                    onClicked: {
                        console.log("show_road_6_id.checked ", show_road_6_id.checked);
                        simulation_window_id.show_BUS = show_road_6_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
            Rectangle  // 应急车道
            {
                id: emergency_id
                width: 140 * config_id.screenScale
                height: show_road_7_id.height
                color: "#FFDEAD"
                border.width: 1
                border.color: "white"
                CustomCheckBox {
                    id : show_road_7_id
                    text: qsTr("EMERGENCY_LINE")
                    font.pixelSize : 12 * config_id.screenScale
                    checked : true
                    onClicked: {
                        console.log("show_road_7_id.checked ", show_road_7_id.checked);
                        simulation_window_id.show_EMERGENCY_LINE = show_road_7_id.checked
                        simulation_window_id.requestPaint()
                    }
                }
            }
        }
        Button {
            y : 3 * config_id.screenScale
            width: 80* config_id.screenScale
            height: 25 * config_id.screenScale
            text:"地图复原"   //按钮标题
            font.pixelSize : 12 * config_id.screenScale
            background: Rectangle {
                radius : 5
            }

            onClicked: {
                console.log("canvas.resetCanvas()")
                simulation_window_id.resetCanvas()
            }
        }
        CustomCheckBox {
            text: qsTr("保持绿灯")
            checked : false
            id : keep_trafficlight_green_id
            font.pixelSize : 12 * config_id.screenScale
            onCheckedChanged: {
                console.log("keep_trafficlight_green_id.checked ", keep_trafficlight_green_id.checked);
                simulation_window_id.keep_trafficlight_green = keep_trafficlight_green_id.checked
                SimulatorControl.setKeepTrafficLightGreen(keep_trafficlight_green_id.checked)
                simulation_window_id.requestPaint()
            }
        }
        Column {
            width: 100 * config_id.screenScale
            CustomCheckBox {
                id : show_traffic_id
                text: qsTr("搜索红绿灯")
                font.pixelSize : 12 * config_id.screenScale
                checked : false
                onCheckedChanged: {
                    show_traffic_text_id.jumpToLocation()
                }
            }

            TextField {
                id : show_traffic_text_id
                visible : show_traffic_id.checked
                width: 100 * config_id.screenScale
                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter
                font.pixelSize: 12 * config_id.screenScale
                color: "#000000"
                selectByMouse: true
                selectionColor: "#999999"//选中背景颜色
                placeholderText: qsTr("红绿灯id")
                background: Rectangle {
                    border.width: 1; //border.color: "#B2B2B2"
                    radius: 4; 
                    border.color: "#000000"
                    color: "#FFFFFF" //"transparent"
                    opacity: 0.1
                    implicitWidth: 100 * config_id.screenScale
                }

                onAccepted: {
                    jumpToLocation()
                    focus = false
                }

                function jumpToLocation() {
                    var traffic_id = show_traffic_text_id.text
                    console.log("id: ", traffic_id)
                    event_bus_id.locateTrafficLight(traffic_id)
                }
            }
        }

        CustomCheckBox {
            text: qsTr("显示所有道路ID")
            checked : false
            id : show_all_road_check_box_id
            font.pixelSize : 12 * config_id.screenScale
            onCheckedChanged: {
                console.log("show_all_road_check_box_id.checked ", show_all_road_check_box_id.checked);
                simulation_window_id.show_all_lane_id = show_all_road_check_box_id.checked
                simulation_window_id.requestPaint()
            }
        }

        Column {
            width: 100 * config_id.screenScale
            CustomCheckBox {
                id : show_one_road_check_box_id
                text: qsTr("高亮指定道路")
                font.pixelSize : 12 * config_id.screenScale
                checked : false
                onCheckedChanged: {
                    console.log("show_one_road_check_box_id.checked ", show_one_road_check_box_id.checked);
                    simulation_window_id.hightlight_one_road = show_one_road_check_box_id.checked
                    simulation_window_id.requestPaint()
                }
            }

            TextField {
                visible : show_one_road_check_box_id.checked
                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter
                font.pixelSize: 12 * config_id.screenScale
                color: "#000000"
                selectByMouse: true
                selectionColor: "#999999"//选中背景颜色
                placeholderText: qsTr("输入道路id")
                background: Rectangle {
                    border.width: 1; //border.color: "#B2B2B2"
                    radius: 4; 
                    border.color: "#000000"
                    color: "#FFFFFF" //"transparent"
                    opacity: 0.1
                    implicitWidth: 100 * config_id.screenScale
                }

                onAccepted: {
                    simulation_window_id.highlight_road = text
                    simulation_window_id.requestPaint()
                    show_one_road_detail_id.text = SimulatorControl.acquireLaneInfo(text)
                }
            }

            Text{
                id: show_one_road_detail_id
                visible : show_one_road_check_box_id.checked
                height: 400
                font.pixelSize: 12 * config_id.screenScale
                text: "";
                width: 300 * config_id.screenScale
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideNone
                maximumLineCount:100
            }
        }

        Column {
            width: 150 * config_id.screenScale
            CustomCheckBox {
                id : show_map_points_id
                text: qsTr("标记坐标点")
                font.pixelSize : 12 * config_id.screenScale
                checked : false
                onCheckedChanged: {
                    console.log("show_map_points_id.checked ", show_map_points_id.checked);
                    simulation_window_id.hightlight_point = show_map_points_id.checked
                    show_map_points_text_id.jumpToLocation()
                }
            }

            TextField {
                id : show_map_points_text_id
                visible : show_map_points_id.checked
                width: 150 * config_id.screenScale
                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter
                font.pixelSize: 12 * config_id.screenScale
                color: "#000000"
                selectByMouse: true
                selectionColor: "#999999"//选中背景颜色
                placeholderText: qsTr("点的坐标x,y")
                background: Rectangle {
                    border.width: 1; //border.color: "#B2B2B2"
                    radius: 4; 
                    border.color: "#000000"
                    color: "#FFFFFF" //"transparent"
                    opacity: 0.1
                    implicitWidth: 100 * config_id.screenScale
                }

                onAccepted: {
                    jumpToLocation()
                    focus = false
                }

                function jumpToLocation() {
                    var temp = show_map_points_text_id.text.split(",")
                    if (temp.length > 1) {
                        var x = parseFloat(temp[0]).toFixed(2)
                        var y = parseFloat(temp[1]).toFixed(2)
                        show_map_points_text_id.text = x + "," + y
                        event_bus_id.locateAxies(x, y)
                        

                        simulation_window_id.highlight_points = []
                        var p = simulation_window_id.realMapPointToNoScaleContext(Qt.point(x,y))
                        simulation_window_id.highlight_points.push(p.x)
                        simulation_window_id.highlight_points.push(p.y)
                        simulation_window_id.requestPaint()

                        console.log("jumpToLocation", show_map_points_text_id.text, x, y, "....", p.x, p.y)
                    } else {

                    }
                }
            }
        }

        
    }

    Component.onCompleted: {
        SimulatorControl.setKeepTrafficLightGreen(false)
    }
}
