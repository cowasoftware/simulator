import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2

import COWA.Simulator 1.0

import "qrc:/resource/qml/event_bus"

Dialog
{
    id: dialog
    width: 750
    height: 920
    x: (1920 - dialog.width) / 2
    y: (1080 - dialog.height) / 2 - 50

    property color backgroundColor: "#404040"
    property color textColor: "white"

    modal: false /* 非模态对话框 */
    closePolicy: Popup.NoAutoClose   /* 不自动关闭 */

    /* 背景 */
    background: Rectangle
    {
        color: dialog.backgroundColor
        border.color: "#404040"
        border.width: 2
        radius: 8
    }

    /* 标题 */
    Rectangle
    {
        x: 0
        y: 0
        width: parent.width
        height: 15
        color: "#00000000"
        Text
        {
            id: titleLabel
            text: qsTr("仿真测试文件模板（已复制到剪贴板）")
            color: dialog.textColor
            font.pointSize: 9 * 1.2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
        }

        /* 水平分隔线 */
        Rectangle
        {
            id: horizontalLine
            y: 25
            width: parent.width
            height: 1
            color: "#606060"
        }
        Rectangle
        {
            id: simulation_test_close_id
            x: parent.width - 20
            y: 0
            width: 20
            height: 20
            Image
            {
                x: -5
                y: -5
                width: 30
                height: 30
                source: "qrc:///resource/image/simulation_page/quit.png"
            }
            color: "#EB6637"
            radius: 10
            MouseArea
            {
                x: 0
                y: 0
                width: parent.width
                height: parent.height
                anchors.fill: parent
                onClicked:
                {
                    dialog.close();
                }
            }
        }
    }
    Rectangle
    {
        id: simulation_test_edit_rect_id
        x: 10
        y: 46
        width: parent.width - simulation_test_edit_rect_id.x * 2
        height: parent.height - simulation_test_edit_rect_id.y - 10
        color: "grey"
        radius: 2
        //TextArea
        //{
        //    style:TextAreaStyle
        //    {
        //        textColor:"#333"
        //        selectionColor:"steelblue"
        //        selectedTextColor:"#eee"
        //        backgroundColor:"#eee"
        //    }
        //}
        Flickable
        {
            id: flick
            width: parent.width - 10
            height: parent.height
            anchors.fill: parent
            contentWidth: edit.contentWidth
            contentHeight: edit.contentHeight
            clip: true      
            function ensureVisible(r)
            {
                if (flick.contentX >= r.x)
                {
                    flick.contentX = r.x;
                }
                else if (flick.contentX + width <= r.x + r.width)
                {
                    flick.contentX = r.x + r.width - width;
                }
                if (flick.contentY >= r.y)
                {
                    flick.contentY = r.y;
                }
                else if (flick.contentY + height <= r.y + r.height)
                {
                    flick.contentY = r.y + r.height - height;
                }
            }       
            TextEdit
            {
                id: edit
                x: 5
                y: 5
                //width: flick.width
                //height: flick.height
                width: flick.width - 10
                height: flick.height
                font.pointSize: 15
                wrapMode: TextEdit.Wrap
                focus: true
                selectByMouse: false
                enabled: false
                text: ""
                onCursorRectangleChanged:
                {
                    flick.ensureVisible(cursorRectangle)
                }
            }
        }
        Rectangle
        {
            id: scrollbar
            anchors.right: flick.right
            y: flick.visibleArea.yPosition * flick.height
            width: 10
            height: flick.visibleArea.heightRatio * flick.height
            color: "lightgrey"
        }
    }
    
    //Rectangle
    //{
    //    id: simulation_test_copy_rect_id
    //    x: simulation_test_edit_rect_id.x + simulation_test_edit_rect_id.width + 10
    //    y: simulation_test_edit_rect_id.y
    //    width: parent.width - simulation_test_copy_rect_id.x - 10
    //    height: (parent.height - simulation_test_edit_rect_id.y) / 4 - 10
    //    color: "grey"
    //    radius: 2

    //    Text
    //    {
    //        text: "复制"
    //        horizontalAlignment: Text.AlignHCenter
    //        verticalAlignment: Text.AlignVCenter
    //        anchors.centerIn: parent
    //    }

    //    MouseArea
    //    {
    //        anchors.fill: parent
    //        hoverEnabled: true
    //        acceptedButtons: Qt.LeftButton
    //        onEntered:
    //        {
    //            parent.color = "#B0B0B0"
    //        }
    //        onExited:
    //        {
    //            parent.color = "grey"
    //        }
    //        onPressed:
    //        {
    //            parent.color = "#606060"
    //        }
    //        onReleased:
    //        {
    //            parent.color = containsMouse ? "#B0B0B0" : "grey"
    //        }
    //    }
    //}

    //Rectangle
    //{
    //    id: simulation_test_copy_rect_id2
    //    x: simulation_test_edit_rect_id.x + simulation_test_edit_rect_id.width + 10
    //    y: simulation_test_edit_rect_id.y + simulation_test_copy_rect_id.height + 10
    //    width: parent.width - simulation_test_copy_rect_id.x - 10
    //    height: (parent.height - simulation_test_edit_rect_id.y) / 4 - 10
    //    color: "grey"
    //    radius: 2

    //    Text
    //    {
    //        text: "粘贴"
    //        horizontalAlignment: Text.AlignHCenter
    //        verticalAlignment: Text.AlignVCenter
    //        anchors.centerIn: parent
    //    }

    //    MouseArea
    //    {
    //        anchors.fill: parent
    //        hoverEnabled: true
    //        acceptedButtons: Qt.LeftButton
    //        onEntered:
    //        {
    //            parent.color = "#B0B0B0"
    //        }
    //        onExited:
    //        {
    //            parent.color = "grey"
    //        }
    //        onPressed:
    //        {
    //            parent.color = "#606060"
    //        }
    //        onReleased:
    //        {
    //            parent.color = containsMouse ? "#B0B0B0" : "grey"
    //        }
    //    }
    //}

    //Rectangle
    //{
    //    id: simulation_test_copy_rect_id3
    //    x: simulation_test_edit_rect_id.x + simulation_test_edit_rect_id.width + 10
    //    y: simulation_test_edit_rect_id.y + (simulation_test_copy_rect_id.height + 10) * 2
    //    width: parent.width - simulation_test_copy_rect_id.x - 10
    //    height: (parent.height - simulation_test_edit_rect_id.y) / 4 - 10
    //    color: "grey"
    //    radius: 2

    //    Text
    //    {
    //        text: "确定"
    //        horizontalAlignment: Text.AlignHCenter
    //        verticalAlignment: Text.AlignVCenter
    //        anchors.centerIn: parent
    //    }

    //    MouseArea
    //    {
    //        anchors.fill: parent
    //        hoverEnabled: true
    //        acceptedButtons: Qt.LeftButton
    //        onEntered:
    //        {
    //            parent.color = "#B0B0B0"
    //        }
    //        onExited:
    //        {
    //            parent.color = "grey"
    //        }
    //        onPressed:
    //        {
    //            parent.color = "#606060"
    //        }
    //        onReleased:
    //        {
    //            parent.color = containsMouse ? "#B0B0B0" : "grey"
    //        }
    //    }
    //}
    //
    //Rectangle
    //{
    //    id: simulation_test_copy_rect_id4
    //    x: simulation_test_edit_rect_id.x + simulation_test_edit_rect_id.width + 10
    //    y: simulation_test_edit_rect_id.y + (simulation_test_copy_rect_id.height + 10) * 3
    //    width: parent.width - simulation_test_copy_rect_id.x - 10
    //    height: (parent.height - simulation_test_edit_rect_id.y) / 4 - 10
    //    color: "grey"
    //    radius: 2

    //    Text
    //    {
    //        text: "取消"
    //        horizontalAlignment: Text.AlignHCenter
    //        verticalAlignment: Text.AlignVCenter
    //        anchors.centerIn: parent
    //    }

    //    MouseArea
    //    {
    //        anchors.fill: parent
    //        hoverEnabled: true
    //        acceptedButtons: Qt.LeftButton
    //        onEntered:
    //        {
    //            parent.color = "#B0B0B0"
    //        }
    //        onExited:
    //        {
    //            parent.color = "grey"
    //        }
    //        onPressed:
    //        {
    //            parent.color = "#606060"
    //        }
    //        onReleased:
    //        {
    //            parent.color = containsMouse ? "#B0B0B0" : "grey"
    //        }
    //    }
    //}
    MouseArea
    {
        id: mouseRegion
        x: 0
        y: 0
        width: parent.width - 30
        height: 25
        property variant clickPos: "1,1"
        onPressed:
        {
            clickPos = Qt.point(mouse.x, mouse.y)
        }
        onPositionChanged:
        {
            dialog.x = dialog.x + mouse.x - clickPos.x
            dialog.y = dialog.y + mouse.y - clickPos.y
        }
    }

	Connections
    {
        target: event_bus_id

		function onShowSimulationTestBoard()
		{
            ScenarioControl.copyToBoard(edit.text)
			open()
		}
	}

    Component.onCompleted:
    {
        edit.text = ScenarioControl.simulationTestBoardText()
    }
}