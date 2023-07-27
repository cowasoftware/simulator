import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import COWA.Simulator  1.0
import COWA.Simulator.VModel 1.0

import "qrc:///resource/qml/simulation_page/EditPropertyPanel/ObstaclePanel"
import "qrc:/resource/qml/config"
import "qrc:/resource/control"
import "./ObstaclePanel"

Control{
    id: obstacle_panel_control
    visible: ObstacleEditPanelVM.visible

    property int driveModeByStraight : 1
    property int driveModeByLane : 2
    property int driveModeByRL : 3
    property int driveModeByCurve : 4
    property int driveModeByDL : 5
    property int driveModeByRouting : 6


    property int triggerByTime : 0
    property int triggerByDistance : 1
    property int triggerByLocation : 2

    property var  tab_model : ObstacleEditPanelVM.is_static ? ["静态属性"] : ["静态属性", "动态属性"]

    contentItem: ColumnLayout{
        spacing: 0
        Label{
            Layout.leftMargin: 12 * config_id.screenScale
            Layout.fillWidth: true
            Layout.preferredHeight: 40 * config_id.screenScale
            text: ObstacleEditPanelVM.title
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


        TabBar{
            id: tabBar
            spacing: 20 * config_id.screenScale
            Layout.leftMargin: 12 * config_id.screenScale
            Layout.preferredHeight: 45 * config_id.screenScale
            background: Item{
                Rectangle{
                    x: tabBar.currentItem != null ? tabBar.currentItem.x : 0
                    width: tabBar.currentItem != null ? tabBar.currentItem.width : 0
                    height: 2
                    color: "#505559"
                    anchors.bottom: parent.bottom
                    Behavior on x {
                        NumberAnimation{
                            duration: 150
                        }
                    }
                }
            }
            Repeater {
                model: obstacle_panel_control.tab_model
                delegate: TabButton{
                    width: tabItem.contentWidth
                    anchors.verticalCenter: parent.verticalCenter
                    focusPolicy: Qt.NoFocus
                    background: Item{}
                    contentItem: Label{
                        id: tabItem
                        text: modelData
                        color: "#000000"
                        font.pixelSize: 12 * config_id.screenScale
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#BBBBBB"
        }
        SwipeView{
            Layout.fillWidth: true
            Layout.fillHeight: true
            interactive: false
            currentIndex: tabBar.currentIndex
            clip: true
            Control{
                contentItem: ColumnLayout{
                    SizeCard{
                        id: sizeCard
                        Layout.fillWidth: true
                        Layout.leftMargin: 12 * config_id.screenScale
                        Layout.topMargin: 16 * config_id.screenScale
                        Layout.rightMargin: 12 * config_id.screenScale
                        Layout.bottomMargin: 16 * config_id.screenScale
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#BBBBBB"
                    }

                    LocationCard{
                        id: locationCard
                        Layout.fillWidth: true
                        Layout.leftMargin: 12 * config_id.screenScale
                        Layout.topMargin: 16 * config_id.screenScale
                        Layout.rightMargin: 12 * config_id.screenScale
                        Layout.bottomMargin: 16 * config_id.screenScale
                    }

                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
            Control{
                visible : ObstacleEditPanelVM.is_static == false
                contentItem: ColumnLayout{
                    KineticCard{
                        id: kineticCard
                        Layout.fillWidth: true
                        Layout.leftMargin: 12 * config_id.screenScale
                        Layout.topMargin: 16 * config_id.screenScale
                        Layout.rightMargin: 12 * config_id.screenScale
                        Layout.bottomMargin: 16 * config_id.screenScale
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#BBBBBB"
                    }

                    DriveStyleCard{
                        Layout.fillWidth: true
                        Layout.leftMargin: 12 * config_id.screenScale
                        Layout.topMargin: 16 * config_id.screenScale
                        Layout.rightMargin: 12 * config_id.screenScale
                        Layout.bottomMargin: 16 * config_id.screenScale
                    }

                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
