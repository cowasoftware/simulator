import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import "../../control"
import COWA.Simulator  1.0

Control{
    id: new_project_page_id
    property bool selected : false
    property var selected_map_name : ""
    contentItem: Item{
        // Button{
        //     anchors.right: parent.right
        //     anchors.rightMargin: 48 * config_id.screenScale
        //     anchors.top: parent.top
        //     anchors.topMargin: 48 * config_id.screenScale
        //     width: 120 * config_id.screenScale
        //     height: 60 * config_id.screenScale
        //     text:"完成"   //按钮标题
        //     background: Rectangle {
        //         radius : 5
        //         color: new_project_page_id.selected === true ? "#5b89ff" : "#DCDCDC"
        //     }

        //     onClicked: {
        //         if (new_project_page_id.selected === true) {
        //             event_bus_id.createProject("simulate", new_project_page_id.selected_map_name)
        //         }
        //     }
        // }

        Label{
            id: title_id
            width: 100 * config_id.screenScale
            height: 36 * config_id.screenScale
            text: qsTr("选择地图")
            font.styleName: "Regular"
            font.pixelSize: 18 * config_id.screenScale
            color: "#000000"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            background: Item{
                Rectangle{
                    width: parent.width
                    height: 1
                    color: "#101010"
                    anchors.bottom: parent.bottom
                }
            }
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 44 * config_id.screenScale
            anchors.topMargin: 48 * config_id.screenScale
        }

        Container{
            id: map_container_id
            width: parent.width
            anchors.top: title_id.bottom
            anchors.topMargin: 66 * config_id.screenScale
            anchors.bottom: parent.bottom
            leftPadding: 10 * config_id.screenScale
            rightPadding: 10 * config_id.screenScale
            contentItem: Flow{
                spacing: 0
            }

            Repeater{
                id : repeater_map_list_id
                delegate: Item{
                    width: 300 * config_id.screenScale
                    height: 160 * config_id.screenScale
                    MapTemplateItem{
                        anchors.centerIn: parent
                        title: model.modelData.title
                        cover:"qrc:///resource/image/home_page/project_sample_image.png"
                        onClicked: {
                            new_project_page_id.selected = true
                            new_project_page_id.selected_map_name = title
                            SimulatorControl.acquireMap(selected_map_name)
                            event_bus_id.createProject("simulate", new_project_page_id.selected_map_name)
                        }
                    }
                }
            }
        }
    }
    Component.onCompleted: {
        SimulatorControl.acquireMapList()
        console.log("Component.onCompleted in new_project_page.qml")
    }
    
    Connections {
        target: SimulatorControl
        function onNotifyMapList(model) {
            console.log("onNotifyMapList in new_project_page.qml", model)
            repeater_map_list_id.model = model
        }
    }
}
