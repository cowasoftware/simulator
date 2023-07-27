import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import "../../control"
import COWA.Simulator  1.0

Control{
    id: record_project_page_id

    property bool selected : false
    property var selected_map_name : undefined
    property var selected_record_name : undefined

    contentItem: Item{
        Button{
            anchors.right: parent.right
            anchors.rightMargin: 48 * config_id.screenScale
            anchors.top: parent.top
            anchors.topMargin: 48 * config_id.screenScale
            width: 120* config_id.screenScale
            height: 60 * config_id.screenScale
            text:"完成"   //按钮标题
            background: Rectangle {
                radius : 5
                color: record_project_page_id.selected === true ? "#5b89ff" : "#DCDCDC"
            }

            onClicked: {
                if (record_project_page_id.selected === true) {
                    event_bus_id.createProject("record", selected_record_name)
                }
            }
        }

        Label{
            id: map_title_id
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
            height: 200 * config_id.screenScale
            anchors.top: map_title_id.bottom
            anchors.topMargin: 66 * config_id.screenScale
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
                            console.log("record Project in record_project_page.qml", " selected map ", title)
                            record_project_page_id.selected_map_name = title
                            SimulatorControl.acquireMap(title)
                            if (record_project_page_id.selected_record_name != undefined) {
                                record_project_page_id.selected = true
                            }
                        }
                    }
                }
            }
        }

        Label{
            id: record_title_id
            width: 136 * config_id.screenScale
            height: 36 * config_id.screenScale
            text: qsTr("选择回放文件")
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
            y : 500 * config_id.screenScale
            anchors.leftMargin: 44 * config_id.screenScale
            anchors.topMargin: 48 * config_id.screenScale
        }

        Container{
            id: record_container_id
            width: parent.width
            anchors.top: record_title_id.bottom
            anchors.topMargin: 66 * config_id.screenScale
            anchors.bottom: parent.bottom
            leftPadding: 10 * config_id.screenScale
            rightPadding: 10 * config_id.screenScale
            contentItem: Flow{
                spacing: 0
            }

            Repeater{
                id : repeater_record_list_id
                //  model: 
                //  [
                //     {"title": qsTr("hehe"), "cover":"qrc:///resource/image/home_page/project_sample_image.png"},
                //     {"title": qsTr("hehe"), "cover":"qrc:///resource/image/home_page/project_sample_image.png"},
                //     {"title": qsTr("hehe"), "cover":"qrc:///resource/image/home_page/project_sample_image.png"},
                // ]
                delegate: Item{
                    width: 300 * config_id.screenScale
                    height: 160 * config_id.screenScale
                    MapTemplateItem{
                        anchors.centerIn: parent
                        title: model.modelData.title
                        cover:"qrc:///resource/image/home_page/project_sample_image.png"
                        onClicked: {
                            console.log("record Project in record_project_page.qml", " selected record ", title)
                            record_project_page_id.selected_record_name = title
                            RecordPlayControl.acquireRecord(title)
                            if (record_project_page_id.selected_map_name != undefined) {
                                record_project_page_id.selected = true
                            }
                        }
                    }
                }
            }
        }

    }
    Connections {
        target: SimulatorControl
        function onNotifyMapList(model) {
            console.log("onNotifyMapList in main.qml", model)
            repeater_map_list_id.model = model
        }
    }
    Connections {
        target: RecordPlayControl
        function onNotifyRecordList(recordListModel) {
            console.log("onNotifyRecordList in record_project_page.qml", recordListModel)
            if (recordListModel != null) {
                var list_model = []
                for (var i = 0; i < recordListModel.records.length; ++i) {
                    list_model.push(
                        {
                            "title": recordListModel.records[i].title, 
                            "cover":"qrc:///resource/image/home_page/project_sample_image.png"
                        }
                    )

                }
                repeater_record_list_id.model = list_model
            }
        }
    }

    Component.onCompleted: {
        var recordListModel = RecordPlayControl.acquireRecordList()
        if (recordListModel != null) {
            var list_model = []
            for (var i = 0; i < recordListModel.records.length; ++i) {
                console.log("recordListModel.records[i].title ", recordListModel.records[i].title)
                list_model.push(
                    {
                        "title": recordListModel.records[i].title, 
                        "cover":"qrc:///resource/image/home_page/project_sample_image.png"
                    }
                )

            }
            repeater_record_list_id.model = list_model
        }
    }

}
