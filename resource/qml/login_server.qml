import QtQuick 2.12
import QtQuick.Controls 2.12
 import QtQuick.Layouts 1.15

// import "qrc:/resource/qml/config"
// import "qrc:/resource/qml/event_bus"
// import "qrc:/resource/qml/simulation_page"
// import "qrc:/resource/qml/home_page"

Rectangle
{
    id: login_server_id
    width: 1920
    height: 1080
    color:  Qt.rgba(255,255,255, 0.1)
    

    // 中间
    Rectangle
    {
        id: login_server_info_id
        anchors.centerIn : parent
        width: 500
        height: 400
        color: "#FFFFFF"
        border.width: 10
        border.color: login_server_info_id.color
        radius:  10

        Row {
            spacing : 20
            anchors.centerIn : parent
            Text {
                text:"服务器IP";
                x: 10
                anchors.verticalCenter: parent.verticalCenter
                font.bold: true; //字体加粗
                font.pixelSize:14; //像素
                font.family: "微软雅黑"
            }
            TextField {
                id: server_ip_id
                anchors.verticalCenter: parent.verticalCenter
                text: "127.0.0.1"
                font.pixelSize: 20
                wrapMode: TextField.Wrap
                leftPadding: 50
            }
        }

        Rectangle {
            anchors.right : parent.right
            anchors.bottom : parent.bottom
            width: 90
            height: 92
            Text {
                id: name
                anchors.fill: parent
                text: qsTr("确定")
            }
            MouseArea {
                anchors.fill: parent
                onPressed: {
                    console.log("123")
                    login_server_loader_id.source = ""
                }
            }
        }
    }
}
