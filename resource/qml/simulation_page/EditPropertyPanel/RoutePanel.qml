import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import COWA.Simulator 1.0
// 展示轨迹线 详细信息
Control{
    property string title
    property var currentObstacleCurveModel : undefined
    // 当前轨迹线
    property int currentCurveId: -1

    ListModel{
        id: routeModel
    }

    Component{
        id: routeDelegate
        Control{
            id: routeControl
            width: ListView.view.width
            height: 30 * config_id.screenScale
            // leftPadding: 24 * config_id.screenScale
            // ightPadding: 24 * config_id.screenScale
            leftPadding : 0
            rightPadding : 0

            contentItem: RowLayout{
                width: parent.availableWidth
                height: parent.availableHeight


                Label{
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32 * config_id.screenScale
                    Layout.preferredHeight: 18 * config_id.screenScale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: model.routeId
                    color: "#8CA2AA"
                    font.pixelSize: 12 * config_id.screenScale
                }

                Label{
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32 * config_id.screenScale
                    Layout.preferredHeight: 18 * config_id.screenScale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: model.x
                    color: "#000000"
                    font.pixelSize: 12 * config_id.screenScale
                }

                Label{
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32 * config_id.screenScale
                    Layout.preferredHeight: 18 * config_id.screenScale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: model.y
                    color: "#000000"
                    font.pixelSize: 12 * config_id.screenScale
                }

                TextField {
                    id: velocity_id
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32 * config_id.screenScale
                    Layout.preferredHeight: 32 * config_id.screenScale
                    horizontalAlignment: TextField.AlignHCenter
                    verticalAlignment: TextField.AlignVCenter
                    text: model.v
                    maximumLength : 5
                    color: "#000000"
                    selectByMouse: true
                    selectionColor: "#999999"//选中背景颜色
                    font.pixelSize: 12 * config_id.screenScale
              
                    onEditingFinished: {
                        if (index < 0) return
                        routeModel.setProperty(index, "v", text)
                        currentObstacleCurveModel.updateSpeed(index, text)
                        routeControl.updateObstacleSpeed(currentCurveId, index, text)
                        focus = false
                    }
                    onFocusChanged: {
                        if(!focus){
                            var t = text
                            clear()
                            insert(0, t)
                        }
                    }
                }
            }

            // 更新障碍物曲线所绑定的障碍物属性
            function updateObstacleSpeed(curve_id, index, speed)
            {
                console.log("updateObstacleSpeed, curve_id=" + curve_id + ",index=" + index + ", speed=" + speed)
                ScenarioControl.updateObstacleSpeedAtIndex(curve_id, index, speed);
            }
        }
    }

    id: control
    contentItem: ColumnLayout{
        spacing: 0
        Label{
            Layout.leftMargin: 12 * config_id.screenScale
            Layout.fillWidth: true
            Layout.preferredHeight: 40 * config_id.screenScale
            text: control.title
            color: "#000000"
            font.pixelSize: 12 * config_id.screenScale
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
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

            Repeater{
                model: ["INDEX","X","Y", "速度m/s"]
                delegate: Label{
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32 * config_id.screenScale
                    Layout.preferredHeight: 18 * config_id.screenScale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                    color: "#8CA2AA"
                    font.pixelSize: 12 * config_id.screenScale
                }
            }
        }

        ListView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6 * config_id.screenScale
            model: routeModel
            delegate: routeDelegate
            ScrollBar.vertical: ScrollBar{}
        }
    }


    onCurrentObstacleCurveModelChanged: {
        if (currentObstacleCurveModel != undefined) {
            routeModel.clear()

            var route_curves = currentObstacleCurveModel.getCurve();
            var speed_curves = currentObstacleCurveModel.getSpeeds();
            for (var i = 0; i < route_curves.length; ++i) {
                var x = route_curves[i].x.toFixed(2)
                var y = route_curves[i].y.toFixed(2)
                var v = speed_curves[i].toFixed(2)
                console.log("lineCurvesModel[i].x", x, y, v)
                routeModel.append({"routeId":i, "x": x ,"y": y, "v": v})
            }
        }
    }
    
}
