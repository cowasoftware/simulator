import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import COWA.Simulator  1.0
import COWA.Simulator.VModel 1.0

import "qrc:///resource/qml/simulation_page/EditPropertyPanel/HeroCarPanel"
import "qrc:/resource/qml/config"
import "./HeroCarPanel"
import "qrc:/resource/control"

Control{
    id: hero_car_panel_control
    visible: HeroCarEditPanelVM.visible
    contentItem: ColumnLayout{
        spacing: 0

        Label{
            text: "车型  :  " + HeroCarEditPanelVM.title
            Layout.leftMargin: 12 * config_id.screenScale
            Layout.fillWidth: true
            Layout.preferredHeight: 30 * config_id.screenScale
            color: "#000000"
            font.pixelSize: 12 * config_id.screenScale
            horizontalAlignment: Text.AlignVCenter
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
            Layout.preferredHeight: 40 * config_id.screenScale
            background: Item{
                Rectangle{
                    x: tabBar.currentItem.x
                    width: tabBar.currentItem.width
                    height: 2
                    color: "#505559"
                    anchors.bottom: parent.bottom
                    Behavior on x{
                        NumberAnimation{
                            duration: 150
                        }
                    }
                }
            }
            Repeater{
                model: ["基本属性", "routing设置", "控制设置"]
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
                        Layout.topMargin: 12 * config_id.screenScale
                        Layout.rightMargin: 12 * config_id.screenScale
                        Layout.bottomMargin: 12 * config_id.screenScale
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
                        Layout.topMargin: 12 * config_id.screenScale
                        Layout.rightMargin: 12 * config_id.screenScale
                        Layout.bottomMargin: 12 * config_id.screenScale
                    }

                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
            Control{
                contentItem: ColumnLayout{
                    RoutingCard {
                        id: routingCard
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: 12 * config_id.screenScale
                        Layout.topMargin: 12 * config_id.screenScale
                        Layout.rightMargin: 12 * config_id.screenScale
                        Layout.bottomMargin: 12 * config_id.screenScale
                    }
                    Item{
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }

            Control{
                contentItem: ColumnLayout{
                    KineticCard{
                        id: kineticCard
                    
                        Layout.fillWidth: true
                        Layout.leftMargin: 12 * config_id.screenScale
                        Layout.topMargin: 12 * config_id.screenScale
                        Layout.rightMargin: 12 * config_id.screenScale
                        Layout.bottomMargin: 12 * config_id.screenScale
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
