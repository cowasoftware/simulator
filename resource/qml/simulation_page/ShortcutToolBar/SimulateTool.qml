import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import COWA.Simulator 1.0

Control{
    property int currentSec: 0
    property bool animation
    property bool playing: false

    // 仿真加速的 倍数
    property var simulate_rates : [1, 2, 5, 10]
    property int current_rate_index : 0

    id: simulator_control_id

    Timer{
        id: simulator_timer_id
        interval: 1000//ms
        repeat: true
        onTriggered: simulator_control_id.currentSec++
    }

    function formatTime(val) {
        var hh = parseInt(val/3600);
        if(hh<10) hh = "0" + hh;
        var mm = parseInt((val-hh*3600)/60);
        if(mm<10) mm = "0" + mm;
        var ss = parseInt((val-hh*3600)%60);
        if(ss<10) ss = "0" + ss;
        var length = hh + ":" + mm + ":" + ss;
        if(val>=0){
            return length;
        }else{
            return "NaN";
        }
    }


    contentItem: RowLayout{
        spacing: 10 * config_id.screenScale

        Button{
            visible: true
            enabled: !simulator_control_id.playing
            Layout.preferredWidth: 25 * config_id.screenScale
            Layout.preferredHeight: 25 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            background: Rectangle{
                color: parent.hovered ? "#E1E3E6" : "transparent"
            }
            contentItem: Image{
                anchors.fill: parent
                source: simulator_control_id.playing ?  "qrc:///resource/image/simulation_page/icon_edit_property_kinetic_refresh.png" : "qrc:///resource/image/simulation_page/icon_tool_playback_sync.png"
            }
            NumberAnimation on rotation{
                loops: Animation.Infinite
                running: simulator_control_id.animation
                duration: 500
                from: 0
                to: 180
            }
            Timer{
                id: animation_timer_id
                interval: 500//ms
                repeat: false
                onTriggered: simulator_control_id.animation = false
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


                    console.log("playback pasuse")
                    animation = true
                    animation_timer_id.stop()
                    animation_timer_id.start()


                    simulator_timer_id.running = false
                    simulator_control_id.playing = false
                    event_bus_id.is_playing = false
                    event_bus_id.reset()
                    SimulatorControl.simulatorReset();
                }
                ToolTip{
                    visible: parent.entered
                    text: "后退"
                    delay: 500
                }
            }
        }

        Button{
            Layout.preferredWidth: 25 * config_id.screenScale
            Layout.preferredHeight: 25 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            background: Item{}
            contentItem: Image{
                anchors.fill: parent
                source: simulator_control_id.playing ? "qrc:///resource/image/simulation_page/icon_tool_playback_pause.png" : "qrc:///resource/image/simulation_page/icon_tool_playback_play.png"
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
                    if(simulator_control_id.playing){
                        console.log("simulator pasuse")
                        simulator_timer_id.running = false
                        event_bus_id.is_playing = false
                        SimulatorControl.simulatorPause();

                    }else{
                        console.log("simulator play")
                        simulator_timer_id.running = true
                        event_bus_id.is_playing = true
                        event_bus_id.notifyStartSimulator()
                        SimulatorControl.simulatorStart();
                    }
                    simulator_control_id.playing = !simulator_control_id.playing
                }
                ToolTip{
                    visible: parent.entered
                    text: "开始/暂停"
                    delay: 500
                }
            }

        }

        Label{
            Layout.preferredWidth: 42 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            text: formatTime(simulator_control_id.secs < 0 ? -1 : simulator_control_id.currentSec)
            color: "#505559"
            font.pixelSize: 10 * config_id.screenScale
            horizontalAlignment: Text.AlignRight
        }


        // ToolSeparator{
        //     Layout.rightMargin: 12 * config_id.screenScale
        //     Layout.leftMargin: 12 * config_id.screenScale
        // }


        // Button {
        //     id : dec_button_id
        //     Layout.preferredWidth: 20 * config_id.screenScale
        //     Layout.preferredHeight: 20 * config_id.screenScale
        //     Layout.alignment: Qt.AlignVCenter
        //     background: Item{}
        //     property bool userPressed: false
        //     contentItem: Image{
        //         anchors.fill: parent
        //         source: dec_button_id.userPressed == true ? "qrc:///resource/image/simulation_page/left_green.png" :
        //                                 "qrc:///resource/image/simulation_page/left_black.png" 
        //     }
        //     MouseArea {
        //         property bool entered: false
        //         hoverEnabled: true
        //         anchors.fill: parent
        //         onEntered: {
        //             entered = true
        //         }
        //         onExited: {
        //             entered = false
        //         }
        //         onClicked: {
        //             if (current_rate_index > 0) {
        //                 current_rate_index = current_rate_index - 1
        //                 SimulatorControl.setSimulateRate(simulate_rates[current_rate_index])
        //             }
        //         }
        //         onPressed: { dec_button_id.userPressed = true}
        //         onReleased: { dec_button_id.userPressed = false}
        //         ToolTip{
        //             visible: parent.entered
        //             text: "减慢仿真"
        //             delay: 500
        //         }
        //     }

        // }

        // Label{
        //     Layout.preferredWidth: 15 * config_id.screenScale
        //     Layout.alignment: Qt.AlignVCenter
        //     text: simulate_rates[current_rate_index] + "x"
        //     color: "#505559"
        //     font.pixelSize: 12 * config_id.screenScale
        //     horizontalAlignment: Text.AlignHCenter
        // }

        // Button{
        //     id : acc_button_id
        //     Layout.preferredWidth: 20 * config_id.screenScale
        //     Layout.preferredHeight: 20 * config_id.screenScale
        //     Layout.alignment: Qt.AlignVCenter
        //     background: Item{}

        //     property bool userPressed: false
        //     contentItem: Image{
        //         anchors.fill: parent
        //         source: acc_button_id.userPressed ==true ? "qrc:///resource/image/simulation_page/right_green.png" : 
        //                                 "qrc:///resource/image/simulation_page/right_black.png"
        //     }
        //     MouseArea{
        //         property bool entered: false
        //         hoverEnabled: true
        //         anchors.fill: parent
        //         onEntered: {
        //             entered = true
        //         }
        //         onExited: {
        //             entered = false
        //         }
        //         onClicked: {
        //             if (current_rate_index + 1 < simulate_rates.length) {
        //                 current_rate_index = current_rate_index + 1
        //                 SimulatorControl.setSimulateRate(simulate_rates[current_rate_index])
        //             }
        //         }
        //         onPressed: { acc_button_id.userPressed = true}
        //         onReleased: { acc_button_id.userPressed = false}
        //         ToolTip{
        //             visible: parent.entered
        //             text: "加速仿真"
        //             delay: 500
        //         }
        //     }

        // }
    }

    Component.onDestruction: {
        console.log("SimulatorTool qml Destruction")
        event_bus_id.is_playing = false
        // SimulatorControl.simulatorPause()
        SimulatorControl.simulatorClear()
    }
}
