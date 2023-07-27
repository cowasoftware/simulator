import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "qrc:/resource/control"

import COWA.Simulator 1.0

Control{
    property int currentSec: 0
    property int totalSec: 0
    property bool syncing
    property bool playing: false
    property bool enable_simulator_when_replay : false

    id: control
    
    Timer{
        id: timer
        interval: 1000//ms
        repeat: true
        onTriggered: control.currentSec++
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

        PlaybackComboBox{
            Layout.preferredWidth: 160 * config_id.screenScale
            Layout.preferredHeight: 24 * config_id.screenScale
        }

        Button{
            Layout.preferredWidth: 25 * config_id.screenScale
            Layout.preferredHeight: 25 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            // ButtonGroup.group: btnGroup
            background: Item{}
            contentItem: Image{
                anchors.fill: parent
                source: control.playing ? "qrc:///resource/image/simulation_page/icon_tool_playback_pause.png" : "qrc:///resource/image/simulation_page/icon_tool_playback_play.png"
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
                    if(control.playing){
                        console.log("playback pasuse")
                        RecordPlayControl.recordPlayerPause();
                        timer.stop()
                        event_bus_id.is_playing = false
                    }else{
                        console.log("playback play")
                        RecordPlayControl.recordPlayerSeekTo(control.currentSec)
                        RecordPlayControl.recordPlayerStart();
                        timer.start()
                        event_bus_id.is_playing = true
                    }
                    control.playing = !control.playing
                }
                ToolTip{
                    visible: parent.entered
                    text: "播放回放"
                    delay: 500
                }
            }
        }
        Button{
            Layout.preferredWidth: 150 * config_id.screenScale
            Layout.preferredHeight: 25 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            text : control.enable_simulator_when_replay === true ? "仿真控制主车" : "回放数据控制主车"
            onClicked: {
                if(control.playing) {
                    console.log("必须先暂停")
                    return
                }
                if(control.enable_simulator_when_replay){
                    control.enable_simulator_when_replay = false
                    console.log("回放控制主车")
                    ScenarioControl.enableSimulatorWhenReplay(false)
                }else{
                    control.enable_simulator_when_replay = true
                    console.log("仿真控制主车")
                    ScenarioControl.enableSimulatorWhenReplay(true)
                }
            }
        }


        Label{
            Layout.preferredWidth: 60 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            text: formatTime(control.secs < 0 ? -1 : slider.value)
            color: "#505559"
            font.pixelSize: 16 * config_id.screenScale
            horizontalAlignment: Text.AlignRight
        }

        Slider{
            id: slider
            Layout.preferredWidth: 600 * config_id.screenScale
            Layout.preferredHeight: 12 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            topPadding: 5 * config_id.screenScale
            bottomPadding:5 * config_id.screenScale
            background: Item{}
            from: 0
            to: control.totalSec
            value: control.currentSec
            contentItem: Rectangle {
                color: Qt.rgba(0, 0, 0, 0.4)
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    color: "#0078D7"
                }
            }

            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 12 * config_id.screenScale
                implicitHeight: 12 * config_id.screenScale
                radius: 6
                border.width: 2
                border.color: "#0078D7"
            }

            onMoved: {
                control.currentSec = value
                console.log("playback seekto", value)
                RecordPlayControl.recordPlayerSeekTo(value);
            }
        }
        Label{
            Layout.preferredWidth: 60 * config_id.screenScale
            text: formatTime(control.totalSec)
            color: "#505559"
            font.pixelSize: 16 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }

        TextField {
            id : time_ns_in_record_id
            Layout.preferredWidth: 250 * config_id.screenScale
            selectByMouse: true
            selectionColor: "#999999"//选中背景颜色
            color: "#505559"
            font.pixelSize: 12 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            background: Rectangle {
                border.width: 0; //border.color: "#B2B2B2"
                radius: 4; color: "#FFFFFF" //"transparent"
                opacity: 0.05
                implicitHeight: 40 * config_id.screenScale; implicitWidth: 250 * config_id.screenScale
            }
        }

    }

    Component.onCompleted: {
        var recordModel = RecordPlayControl.acquireRecord()
        if (recordModel != null) {
            var totalNanoSec = recordModel.end - recordModel.begin
            totalSec  = totalNanoSec / 1000 / 1000 / 1000
            console.log("onCompleted Record file length ", totalSec, "second")
        }
    }
    Component.onDestruction: {
        console.log("PlaybackTool qml Destruction")
        event_bus_id.is_playing = false
        RecordPlayControl.recordPlayerPause()
    }

    Connections {
        target : RecordPlayControl
        function onNotifyRecord(recordModel) {
            if (recordModel != null) {
                var totalNanoSec = recordModel.end - recordModel.begin
                totalSec  = totalNanoSec / 1000 / 1000 / 1000
                console.log("onNotifyRecord Record file length ", totalSec, "second")
            }
        }
    }

    Connections
    {
        target: ScenarioControl
        function onNotifyUpdateRecordHeroCar(x, y, timestamp_ns) {
            time_ns_in_record_id.text =  "纳秒时间戳：" + timestamp_ns
        }
    }
}
