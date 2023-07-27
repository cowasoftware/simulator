import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


Container{
    id: control
    contentItem: RowLayout{
        spacing: 18 * config_id.screenScale
    }

    ButtonGroup{
        buttons: control.contentChildren
    }

    ListModel{
        id: toolModel
        ListElement{
            normal:"qrc:/resource/image/simulation_page/icon_tool_canvas_mouse.png"
            checked:"qrc:/resource/image/simulation_page/icon_tool_canvas_mouse_checked.png"
        }
        ListElement{
            normal:"qrc:/resource/image/simulation_page/icon_tool_canvas_timeline.png"
            checked:"qrc:/resource/image/simulation_page/icon_tool_canvas_timeline_checked.png"
        }
        ListElement{
            normal:"qrc:///resource/image/simulation_page//icon_tool_canvas_pos.png"
            checked:"qrc:///resource/image/simulation_page//icon_tool_canvas_pos_checked.png"
        }
        ListElement{
            normal:"qrc:///resource/image/simulation_page//icon_tool_canvas_brush.png"
            checked:"qrc:///resource/image/simulation_page//icon_tool_canvas_brush_checked.png"
        }
    }
    property var tips : [ "恢复鼠标", "他车轨迹线" , "自车目的", "小巴停车区域"]
    Component{
        id: toolDelegate
        Button{
            checked: index === currentIndex
            checkable: true
            Layout.preferredWidth: 27 * config_id.screenScale
            Layout.preferredHeight: 27 * config_id.screenScale
            background: Rectangle{
                color: parent.hovered || parent.checked ? "#E1E3E6" : "transparent"
            }
            contentItem: Image{
                width: 18 * config_id.screenScale
                height: 18 * config_id.screenScale
                source: parent.checked ? model.checked : model.normal
            }
            MouseArea{
                property bool entered: false
                hoverEnabled: true
                anchors.fill: parent
                onEntered: {
                    entered = true
                }
                onExited: {
                    entered = false
                }
                onClicked: {
                    control.currentIndex = index
                }
                ToolTip{
                    visible: parent.entered
                    text: tips[index]
                    delay: 500
                }
            }
        }

    }

    Repeater{
        model: toolModel
        delegate: toolDelegate
    }

    onCurrentIndexChanged: event_bus_id.selectTool(control.currentIndex + 1)

    Connections
    {
        target: event_bus_id
        function onSelectTool(tool_type) {
            if (control.currentIndex + 1 != tool_type) {
                control.currentIndex = tool_type - 1
            }
        }
    }
}
