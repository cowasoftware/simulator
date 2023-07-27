import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import COWA.Simulator 1.0

// 展示停车区域 详细信息
Control {
    id: control
    property string title
     property var parkingCircleModel : undefined

    ListModel{
        id: circleModel
    }

    Component {
        id: circleDelegate

        Control {
            id: circleControl
            width: ListView.view.width
            height: 30 * config_id.screenScale
            leftPadding : 0
            rightPadding : 0

            contentItem: RowLayout {
                width: parent.availableWidth
                height: parent.availableHeight

                Text{
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32 * config_id.screenScale
                    Layout.preferredHeight: 18 * config_id.screenScale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: model.id
                    color: "#8CA2AA"
                    font.pixelSize: 10 * config_id.screenScale
                }
                Text{
                    // elide: Text.ElideRight   // ...
                    wrapMode: Text.WordWrap //换行
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32 * config_id.screenScale
                    Layout.preferredHeight: 18 * config_id.screenScale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: qsTr(model.x + "," + model.y)
                    color: "#666666"
                    font.pixelSize: 10 * config_id.screenScale
                }
                Text{
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32 * config_id.screenScale
                    Layout.preferredHeight: 18 * config_id.screenScale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: model.radius
                    color: "#000000"
                    font.pixelSize: 10 * config_id.screenScale
                }
                Button {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32 * config_id.screenScale
                    Layout.preferredHeight: 18 * config_id.screenScale
                    text: "Delete" 
                    font.pixelSize : 10 * config_id.screenScale
                    background: Rectangle {
                        radius : 5
                    }
                    onClicked: {
                        console.log("onClicked, delete circle: ", model.id)
                        ScenarioControl.deleteCircleById(model.id)
                        circle_list_view.model.remove(index)                    
                    }
                }
            }
        }
    }

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
                model: ["ID", "圆心坐标", "半径", "操作"]
                delegate: Label{
                    Layout.fillWidth: true
                    Layout.preferredWidth: 32 * config_id.screenScale
                    Layout.preferredHeight: 18 * config_id.screenScale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                    color: "#8CA2AA"
                    font.pixelSize: 10 * config_id.screenScale
                }
            }
        }

        ListView{
            id: circle_list_view
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6 * config_id.screenScale
            model: circleModel
            delegate: circleDelegate
            ScrollBar.vertical: ScrollBar{}
        }
    }

    function setData(ids, points, radii)
    {
        console.log("ids: ", ids)
        console.log("points: ", points)
        console.log("radii: ", radii)
        circleModel.clear()
        if (points.length < 1 || points.length != radii.length) { return; }
        for (var i = 0; i < ids.length; ++i)
        {
            circleModel.append({
                "id": ids[i],
                "x": points[i].x.toFixed(2),
                "y": points[i].y.toFixed(2),
                "center": points[i],
                "radius": radii[i].toFixed(2)
            })
        }
    }

    onParkingCircleModelChanged: {
        if (parkingCircleModel != undefined)
        {
            circleModel.clear()
            var ids = parkingCircleModel.getIds()
            var points = parkingCircleModel.getPoints()
            var radii = parkingCircleModel.getRaduii()
            console.log("ids: ", ids)
            console.log("points: ", points)
            console.log("radii: ", radii)
            if (points.length < 1 || points.length != radii.length) { return; }
            for (var i = 0; i < ids.length; ++i)
            {
                circleModel.append({
                    "id": ids[i],
                    "x": points[i].x.toFixed(2),
                    "y": points[i].y.toFixed(2),
                    "center": points[i],
                    "radius": radii[i].toFixed(2)
                })
            }
        }
    }
}