import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
// import Qt.labs.platform 1.1 as QtLab

import COWA.Simulator  1.0

import QtQuick.Dialogs 1.3

Control {
    id: root_id
    property var description: ""
    property var running_time: "10"
    property var file_abs_path: ""

    contentItem: RowLayout{ 
        spacing: 20 * config_id.screenScale
        FileDialog {
            id: file_open_dialog
            title: "Please choose a file"
            selectExisting: true
            selectFolder : false
            selectMultiple : false

            onAccepted: {
                var all = Qt.resolvedUrl(fileUrl).toString()
                var file_abs_path = all.substring(7, all.length)
                console.log("You chose file: ", all, file_abs_path);

                if(ScenarioControl.openScenarioFile(file_abs_path)) {
                    console.log("文件打开成功");
                    SimulatorControl.syncSceneToServer()
                }
                main_page_rect_id.forceActiveFocus()
            }
            onRejected: {
                console.log("Canceled")
                main_page_rect_id.forceActiveFocus()
            }
        }

        FileDialog {
            id: file_open_simulation_test_dialog
            title: "Please choose a file"
            selectExisting: true
            selectFolder : false
            selectMultiple : false

            onAccepted: {
                var all = Qt.resolvedUrl(fileUrl).toString()
                var file_abs_path = all.substring(7, all.length)
                console.log("You chose file: ", all, file_abs_path);

                if(ScenarioControl.openSimulationTestFile(file_abs_path)) {
                    console.log("仿真测试文件打开成功");
                    //SimulatorControl.syncSceneToServer()
                }
                main_page_rect_id.forceActiveFocus()
            }
            onRejected: {
                console.log("Canceled")
                main_page_rect_id.forceActiveFocus()
            }
        }

        Dialog {
            id: file_config_dialog
            title: "仿真文件"
            width: 800 * config_id.screenScale
            height: 600 * config_id.screenScale
            standardButtons: StandardButton.Cancel | StandardButton.Ok

            ColumnLayout {
                spacing: 40 * config_id.screenScale
                Layout.topMargin: 20 * config_id.screenScale
                Layout.preferredWidth: 700 * config_id.screenScale
                Layout.preferredHeight: 600 * config_id.screenScale
                
                RowLayout {
                    id: detail_layout
                    Label {
                        text: "场景描述: "
                        color: "navy"
                        font.pixelSize: 22 * config_id.screenScale
                        font.styleName: "Regular"
                        leftPadding: 20 * config_id.screenScale
                    }
                    TextField {
                        id: detail_editor
                        Layout.preferredWidth: 500 * config_id.screenScale
                        Layout.alignment: Qt.AlignVCenter
                        font.pixelSize: 22 * config_id.screenScale
                        font.styleName: "Regular"
                        placeholderText: qsTr("描述")
                        wrapMode: TextInput.WrapAnywhere
                        echoMode: TextInput.Normal
                        
                    }
                    Text {
                        id: detail_empty_tips
                        text: qsTr("场景描述不能为空！！")
                        color: "#F01313"
                        font.pixelSize: 18 * config_id.screenScale
                        font.styleName: "Regular"
                        visible: false
                    }
                }

                RowLayout {
                    id: running_time_layout
                    Label {
                        text: "仿真时长: "
                        color: "navy"
                        font.pixelSize: 22 * config_id.screenScale
                        font.styleName: "Regular"
                        leftPadding: 20 * config_id.screenScale
                    }
                    TextField {
                        id: running_time_editor
                        Layout.preferredWidth: 500 * config_id.screenScale
                        Layout.alignment: Qt.AlignVCenter
                        font.pixelSize: 22 * config_id.screenScale
                        font.styleName: "Regular"
                        inputMethodHints : Qt.ImhFormattedNumbersOnly
                        placeholderText: qsTr("输入时间长度，单位s")
                        wrapMode: TextInput.WrapAnywhere
                        validator: IntValidator{bottom: 10; top: 10*60*60;}
                    }
                    Text {
                        id: running_time_empty_tips
                        text: qsTr("仿真时长不能为空！！")
                        color: "#F01313"
                        font.pixelSize: 18 * config_id.screenScale
                        font.styleName: "Regular"
                        visible: false
                    }
                }

                RowLayout {
                    id: file_selector_layout
                    Label {
                        text: "选择文件: "
                        color: "navy"
                        font.pixelSize: 22 * config_id.screenScale
                        font.styleName: "Regular"
                        leftPadding: 20 * config_id.screenScale
                    }
                    Button {
                        id: open_file_btn
                        width: 250 * config_id.screenScale
                        height: 250 * config_id.screenScale
                        Layout.alignment: Qt.AlignVCenter
                        text: qsTr("请选择文件")
                        background: Rectangle{
                            id: open_button_rect
                            width: parent.width
                            height: parent.height
                            color: "#E1E3E6"
                            radius: 4
                        }
                        onClicked: {
                            file_save_dialog.open();
                        }
                    }
                    Text {
                        id: file_empty_tips
                        text: qsTr("保存文件不能为空！！")
                        color: "#F01313"
                        font.pixelSize: 18 * config_id.screenScale
                        font.styleName: "Regular"
                        visible: false
                    }
                }
            }

            onAccepted: {
                description = detail_editor.text
                running_time = running_time_editor.text
                // console.log("description", description, "running_time", running_time )
                if(description != "" && file_abs_path != "") {
                    if( ScenarioControl.saveScenarioFile(file_abs_path, description, running_time)) {
                        console.log("文件保存成功")
                    }
                }
                
                main_page_rect_id.forceActiveFocus()
            }
            onRejected: {
                console.log("Dialog Canceled")
                // main_page_rect_id.forceActiveFocus()
            }
        }

        FileDialog {
            id: file_save_dialog
            title: "Please choose a file"
            selectExisting: false
            selectFolder : false
            selectMultiple : false
            sidebarVisible:true
            onAccepted: {
                var all = Qt.resolvedUrl(fileUrl).toString()
                file_abs_path = all.substring(7, all.length)
                console.log("You chose file: ", all, file_abs_path);
                open_file_btn.text = file_abs_path
                
            }
            onRejected: {
                console.log("Canceled")
                main_page_rect_id.forceActiveFocus()
            }
        }

        FileDialog {
            id: file_open_coverage_path__dialog
            title: "Please choose a file"
            selectExisting: true
            selectFolder : false
            selectMultiple : false

            onAccepted: {
                var all = Qt.resolvedUrl(fileUrl).toString()
                var file_abs_path = all.substring(7, all.length)
                console.log("You chose file: ", all, file_abs_path);

                if(SimulatorControl.loadCoveragePathFile(file_abs_path)) {
                    console.log("coverage_path_config.pb.txt文件打开成功");
                }
                main_page_rect_id.forceActiveFocus()
            }
            onRejected: {
                console.log("Canceled")
                main_page_rect_id.forceActiveFocus()
            }
        }

        Button{
            id: open_button_id
            Layout.preferredWidth: 25 * config_id.screenScale
            Layout.preferredHeight: 25 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            background: Rectangle{
                color: parent.hovered ? "#E1E3E6" : "transparent"
            }
            contentItem: Image{
                anchors.fill: parent
                source: "qrc:///resource/image/simulation_page/icon_menu_file_open.png"
            }
            MouseArea{
                property bool entered: false
                hoverEnabled: true
                anchors.fill: parent
                onEntered: entered = true
                onExited: entered = false
                onClicked: {
                    if(event_bus_id.is_playing)
                    {
                        console.log("当前正处于仿真状态，请在暂停或结束后进行保存\n");
                        return
                    }
                    console.log("open dialog")
                    file_open_dialog.open();
                }
                ToolTip{
                    visible: parent.entered
                    text: "打开本地仿真场景"
                    delay: 500
                }
            }
        }

        Button{
            id: save_button_id
            Layout.preferredWidth: 25 * config_id.screenScale
            Layout.preferredHeight: 25 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            background: Rectangle{
                color: parent.hovered ? "#E1E3E6" : "transparent"
            }
            contentItem: Image{
                anchors.fill: parent
                source: "qrc:///resource/image/simulation_page/icon_menu_file_save.png"
            }
            MouseArea{
                property bool entered: false
                hoverEnabled: true
                anchors.fill: parent
                onEntered: entered = true
                onExited: entered = false
                onClicked: {
                    if(event_bus_id.is_playing)
                    {
                        console.log("当前正处于仿真状态，请在暂停或结束后进行保存\n");
                        return
                    }
                    console.log("save dialog")
                    file_config_dialog.open();
                }
                ToolTip{
                    visible: parent.entered
                    text: "保存仿真场景"
                    delay: 500
                }
            }
        }

        Button{
            id: open_simulation_test_board_button_id
            Layout.preferredWidth: 25 * config_id.screenScale
            Layout.preferredHeight: 25 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            background: Rectangle{
                color: parent.hovered ? "#E1E3E6" : "transparent"
            }
            contentItem: Image{
                anchors.fill: parent
                source: "qrc:///resource/image/simulation_page/icon_menu_test_template.png"
            }
            MouseArea{
                property bool entered: false
                hoverEnabled: true
                anchors.fill: parent
                onEntered: entered = true
                onExited: entered = false
                onClicked: {
                    if(event_bus_id.is_playing)
                    {
                        console.log("当前正处于仿真状态，请在暂停或结束后进行保存\n");
                        return
                    }
                    console.log("open simulation test board")
                    event_bus_id.showSimulationTestBoard();
                }
                ToolTip{
                    visible: parent.entered
                    text: "打开仿真测试文件模板"
                    delay: 500
                }
            }
        }

        Button{
            id: open_simulation_test_button_id
            Layout.preferredWidth: 25 * config_id.screenScale
            Layout.preferredHeight: 25 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            background: Rectangle{
                color: parent.hovered ? "#E1E3E6" : "transparent"
            }
            contentItem: Image{
                anchors.fill: parent
                source: "qrc:///resource/image/simulation_page/icon_menu_file_test.png"
            }
            MouseArea{
                property bool entered: false
                hoverEnabled: true
                anchors.fill: parent
                onEntered: entered = true
                onExited: entered = false
                onClicked: {
                    if(event_bus_id.is_playing)
                    {
                        console.log("当前正处于仿真状态，请在暂停或结束后进行保存\n");
                        return
                    }
                    console.log("open dialog")
                    file_open_simulation_test_dialog.open();
                }
                ToolTip{
                    visible: parent.entered
                    text: "打开仿真测试文件"
                    delay: 500
                }
            }
        }

        Button{
            id: open_coverage_path_config_button_id
            Layout.preferredWidth: 25 * config_id.screenScale
            Layout.preferredHeight: 25 * config_id.screenScale
            Layout.alignment: Qt.AlignVCenter
            background: Rectangle{
                color: parent.hovered ? "#E1E3E6" : "transparent"
            }
            contentItem: Image{
                anchors.fill: parent
                source: "qrc:///resource/image/simulation_page/icon_menu_file_test.png"
            }
            MouseArea{
                property bool entered: false
                hoverEnabled: true
                anchors.fill: parent
                onEntered: entered = true
                onExited: entered = false
                onClicked: {
                    if(event_bus_id.is_playing)
                    {
                        console.log("当前正处于仿真状态，请在暂停或结束后进行保存\n");
                        return
                    }
                    console.log("open dialog")
                    file_open_coverage_path__dialog.open();
                }
                ToolTip{
                    visible: parent.entered
                    text: "打开coverage_path文件"
                    delay: 500
                }
            }
        }
    }
}
