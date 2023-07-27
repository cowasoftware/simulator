import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2
import QtQuick.Layouts 1.15

Control{
    id: control
    leftPadding: 32 * config_id.screenScale
    rightPadding: 32 * config_id.screenScale
    topPadding: 0
    bottomPadding: 0
    contentItem: RowLayout{
        spacing: 32 * config_id.screenScale

        RowLayout {
            spacing: 10 * config_id.screenScale
            Label{
                width: 20 * config_id.screenScale
                text: qsTr("X:")
                color: "#505559"
                font.pixelSize: 16 * config_id.screenScale
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
            }


            TextField {
                id : text_x_id
                x: 20 * config_id.screenScale
                Layout.preferredWidth: 150 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                selectByMouse: true
                selectionColor: "#999999"//选中背景颜色
                color: "#505559"
                font.pixelSize: 16 * config_id.screenScale
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignLeft

                background: Rectangle {
                    border.width: 1; //border.color: "#B2B2B2"
                    radius: 4; 
                    border.color: "#000000"
                    color: "#FFFFFF" //"transparent"
                    opacity: 0.1
                    implicitWidth: 100 * config_id.screenScale
                }

                onAccepted: {
                    console.log("text_x_id change")
                }
            }
        

            Label{
                width: 20 * config_id.screenScale
                text: qsTr("Y:")
                color: "#505559"
                font.pixelSize: 16 * config_id.screenScale
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignTop
            }
            
            TextField {
                id : text_y_id
                Layout.preferredWidth: 150 * config_id.screenScale
                selectByMouse: true
                selectionColor: "#999999"//选中背景颜色
                color: "#505559"
                font.pixelSize: 16 * config_id.screenScale
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                background: Rectangle {
                    border.width: 1; //border.color: "#B2B2B2"
                    radius: 4; 
                    border.color: "#000000"
                    color: "#FFFFFF" //"transparent"
                    opacity: 0.1
                    implicitWidth: 100 * config_id.screenScale
                }

                onAccepted: {
                    console.log("text_x_id change")
                }
            }
        }


        Rectangle {
            id: frame_rate_id
            Layout.preferredWidth: 150 * config_id.screenScale
            Layout.preferredHeight: 30 * config_id.screenScale
            property int frameCnt: 0
            property int sec: 0
            property int fps: 0
            property alias runing: numberAnimation.running
            radius: 4

            Rectangle{
                height: 2
                color: "red"
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                NumberAnimation on width{
                    id: numberAnimation
                    from: 0
                    to: frame_rate_id.width - frame_rate_id.radius
                    duration: 1000
                    loops: Animation.Infinite
                }
                onWidthChanged: {
                    frame_rate_id.frameCnt++;
                }
            }
            Text{
                anchors.centerIn: parent
                text: frame_rate_id.fps + " fps"
            }

            Timer{
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    frame_rate_id.fps = frame_rate_id.frameCnt
                    frame_rate_id.frameCnt = 0
                }
            }
        }

        Item{
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Connections {
        target: event_bus_id
        function onMouseMoveOnCanvas(x, y) {
            // console.log("onMouseMoveOnCanvas in canvas", x, y)
            // lable_x_id.text = x.toFixed(2)
            // lable_y_id.text = y.toFixed(2)

            text_x_id.text = x.toFixed(2)
            text_y_id.text = y.toFixed(2)
        }
    }

    function onSetXandY() {
        event_bus_id.locateAxies(text_x_id.text, text_y_id.text)
    }
}
