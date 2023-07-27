import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2
import QtQuick.Layouts 1.15

// our c++ class
import COWA.Simulator 1.0

Item
{
    id: home_page_id

    // 左侧的2个创建工程的选项
	Rectangle
    {
        id: left_tab_id
        x: 0
        width: 102 * config_id.screenScale
        height: parent.height
        color: "#FFFFFF"

        property int project_spacing: 36 * config_id.screenScale
        property int currentIndex: 0

        Image
        {
            id: simulate_project_id
            x: 11 * config_id.screenScale
            y: 44 * config_id.screenScale
            width: 80 * config_id.screenScale
            height: 80 * config_id.screenScale
            fillMode: Image.PreserveAspectFit

            Image
            {
                id: simulate_project_image_id
                x: 22 * config_id.screenScale
                y: 10 * config_id.screenScale
                width: 36 * config_id.screenScale
                height: 36 * config_id.screenScale
                source: "qrc:///resource/image/home_page/new_project.png"
                fillMode: Image.PreserveAspectFit
            }

            Text
            {
                id: simulate_project_text_id
                x: 16 * config_id.screenScale
                y: 53 * config_id.screenScale
                width: 48 * config_id.screenScale
                height: 19 * config_id.screenScale
                text: qsTr("仿真")
                font.styleName: "Regular"
                font.pixelSize: 12 * config_id.screenScale
                color: "#505559"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onEntered:
                {
                    simulate_project_id.source = "qrc:///resource/image/home_page/select_background.png"
                }
                onExited:
                {
                    if (left_tab_id.currentIndex != 0)
                    {
                        simulate_project_id.source = ""
                    }
                }
                onClicked:
                {
                    home_page_id.setCurrentIndex(0)
                }
            }
        }

        Image
        {
            id: record_play_project_id
            x: simulate_project_id.x
            y: simulate_project_id.y + simulate_project_id.height  + left_tab_id.project_spacing * 2
            width: 80 * config_id.screenScale
            height: 80 * config_id.screenScale
            fillMode: Image.PreserveAspectFit

            Image
            {
                id: record_play_project_image_id
                x: 22 * config_id.screenScale
                y: 10 * config_id.screenScale
                width: 36 * config_id.screenScale
                height: 36 * config_id.screenScale
                source: "qrc:///resource/image/home_page/record_play.png"
                fillMode: Image.PreserveAspectFit
            }

            Text
            {
                id: record_play_project_text_id
                x: 16 * config_id.screenScale
                y: 53 * config_id.screenScale
                width: 48 * config_id.screenScale 
                height: 19 * config_id.screenScale
                text: qsTr("回放")
                font.styleName: "Regular"
                font.pixelSize: 12 * config_id.screenScale
                color: "#505559"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onEntered:
                {
                    record_play_project_id.source = "qrc:///resource/image/home_page/select_background.png"
                }
                onExited:
                {
                    if (left_tab_id.currentIndex != 1)
                    {
                        record_play_project_id.source = ""
                    }
                }
                onClicked:
                {
                    home_page_id.setCurrentIndex(1)
                }
            }
        }
    }

    // 右侧的地图模板
    Rectangle {
        x: left_tab_id.width
        y: 0
        width: parent.width - left_tab_id.width
        height: parent.height
        StackLayout {
            id: stacklayout_id
            anchors.fill: parent
            currentIndex: 0

            Rectangle
            {
                id: new_project_page_id
                x: left_tab_id.width
                y: 0
                width: parent.width - left_tab_id.width
                height: parent.height
                color: "#EDF1F2"

                Loader
                {
                    id: new_project_page_loader_id
                    width: parent.width
                    height: parent.height
                    source: "qrc:///resource/qml/home_page/simulate_project_page.qml"
                }
            }
            
            Rectangle
            {
                id: record_play_project_page_id
                x: left_tab_id.width
                y: 0
                width: parent.width - left_tab_id.width
                height: parent.height
                color: "#EDF1F2"
                Loader
                {
                    id: record_play_project_page_loader_id
                    width: parent.width
                    height: parent.height
                    source: "qrc:///resource/qml/home_page/record_project_page.qml"
                }
            }
        }
    }

    function setCurrentIndex(index)
    {
        left_tab_id.currentIndex = index
        stacklayout_id.currentIndex = index

        simulate_project_id.source = ""
        simulate_project_image_id.source = "qrc:///resource/image/home_page/new_project.png"
        simulate_project_text_id.color = "#505559"

    
        record_play_project_id.source = ""
        record_play_project_image_id.source = "qrc:///resource/image/home_page/record_play.png"
        record_play_project_text_id.color = "#505559"

        if (index == 0)
        {
            simulate_project_id.source = "qrc:///resource/image/home_page/select_background.png"
            simulate_project_image_id.source = "qrc:///resource/image/home_page/new_project_select.png"
            simulate_project_text_id.color = "#3291F8"
        }
        else if (index == 1) {
            record_play_project_id.source = "qrc:///resource/image/home_page/select_background.png"
            record_play_project_image_id.source = "qrc:///resource/image/home_page/record_play_select.png"
            record_play_project_text_id.color = "#3291F8"
        }
    }

    Component.onCompleted:
    {
        home_page_id.setCurrentIndex(0)
    }
}