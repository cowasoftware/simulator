import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import COWA.Simulator 1.0
import COWA.Simulator.VModel 1.0
import "qrc:/resource/qml/config"
import "qrc:/resource/control"

Control {
    id: control
    implicitWidth: 300
    implicitHeight: 400
   

    Component {
        id: sublightColorCom
        ItemDelegate {
            width: 100 * config_id.screenScale
            contentItem: Text {
                text: model.text
                color: model.color
                //font: control.font
                font.pixelSize: 14 * config_id.screenScale
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            //highlighted: control.highlightedIndex === index
        }
    }
    Component {
        id: sublightFlowCom
        ItemDelegate {
            id: sublightFlowItem
            property var view: ListView.view
            implicitWidth: view.width
            implicitHeight: 35 * config_id.screenScale
            topPadding: 2 * config_id.screenScale
            bottomPadding: topPadding
            background: Rectangle {
                color: parent.hovered ? '#F5F5F5' : 'white'
                MouseArea {
                    id: mousearea
                    anchors.fill: parent
                    pressAndHoldInterval: 500 
                    onPressAndHold: view.interactive = false
                    onReleased: view.interactive = true
                    //onClicked: view.currentIndex = index
                    onMouseYChanged: {
                        var pore = view.indexAt(
                                    mousearea.mouseX + sublightFlowItem.x,
                                    mousearea.mouseY + sublightFlowItem.y)
                        if (index !== pore && pore >= 0 && !view.interactive) {
                            view.model.moveItem(index, pore)
                        }
                    }
                }

                Rectangle {
                    width: 10 * config_id.screenScale
                    height: 10 * config_id.screenScale
                    anchors.right: parent.right
                    anchors.rightMargin: 15 * config_id.screenScale
                    anchors.verticalCenter: parent.verticalCenter
                    color: 'red'
                    visible: parent.parent.hovered
                    Label{
                        text: "X"
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: view.model.removeItem(index)
                    }
                }
            }
            contentItem: RowLayout {
                Label {
                    text: index + 1
                    Layout.preferredWidth: 20 * config_id.screenScale
                    horizontalAlignment: Label.AlignHCenter
                }

                ComboBox {
                    id: sublightColorComb
                    Layout.preferredWidth: 64 * config_id.screenScale
                    font.pixelSize: 14 * config_id.screenScale
                
                    indicator: Item {}
                    background: Rectangle {
                        border.width: 1 * config_id.screenScale
                        border.color: "#BBBBBB"
                        radius: 4 * config_id.screenScale
                        //color: 'transparent'
                    }
                    contentItem: Text {
                        leftPadding: 10 * config_id.screenScale
                        rightPadding: parent.indicator.width + parent.spacing
                        text: parent.displayText
                        font: parent.font
                        //color: parent.pressed ? "#17a81a" : "#21be2b"
                        color: sublightColorModel.get(
                                   sublightColorComb.currentIndex).color
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    popup: Popup {
                        id: popup
                        y: (sublightColorComb.height - 1) *  config_id.screenScale
                        width: sublightColorComb.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1 * config_id.screenScale

                        contentItem: ListView {
                            clip: true
                            implicitHeight: (contentHeight + 5) * config_id.screenScale
                            model: sublightColorComb.popup.visible ? sublightColorComb.delegateModel : null
                            currentIndex: sublightColorComb.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator {}
                        }

                        background: Rectangle {
                            border.color: "#21be2b"
                            radius: 2 * config_id.screenScale
                        }
                    }
                    model: sublightColorModel
                    delegate: sublightColorCom
                    textRole: 'text'
                    valueRole: 'value'
                    Layout.preferredHeight: 30 * config_id.screenScale
                    currentIndex: color - 1
                    onActivated: color = currentValue
                }
                TextField {
                    id: signalTime
                    Layout.preferredWidth: 64 * config_id.screenScale
                    Layout.preferredHeight: 30 * config_id.screenScale
                    Layout.rightMargin: 10 * config_id.screenScale
                    rightPadding: 20 * config_id.screenScale
                    color: "#000000"
                    text: time
                    validator: IntValidator { bottom: 0; top: 10000 }
                    horizontalAlignment: TextField.AlignRight
                    verticalAlignment: TextField.AlignVCenter
                    selectByMouse: true
                    selectionColor: "#999999"
                    placeholderText: qsTr("主车坐标x,y")
                    font.pixelSize: 12 * config_id.screenScale
                    onAccepted: {
                        focus = false
                        time = text
                    }
                    background: Rectangle {
                        border.width: 1; //border.color: "#B2B2B2"
                        radius: 4; 
                        border.color: "#000000"
                        color: "#FFFFFF" //"transparent"
                        opacity: 0.1
                        implicitWidth: 100 * config_id.screenScale
                    }
                    Label {
                        text: '秒'
                        anchors.right: parent.right
                        anchors.rightMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
    ListModel {
        id: sublightColorModel
        ListElement {
            text: '绿色'
            value: 1
            color: 'green'
        }
        ListElement {
            text: '红色'
            value: 2
            color: 'red'
        }
        ListElement {
            text: '黄色'
            value: 3
            color: 'yellow'
        }
        ListElement {
            text: '未知'
            value: 4
            color: 'grey'
        }
        ListElement {
            text: '黑色'
            value: 5
            color: 'black'
        }
    }
    ListModel {
        id: triggleModel
        ListElement {
            text: '一直'
            value: 0
        }
        ListElement {
            text: '根据主车位置'
            value: 1
        }
    }
    ListModel {
        id: sublightTypeModel

        property bool isCrosswalk: TrafficLightEditPanelVM.isCrosswalk
        property bool completed: false

        Component.onCompleted: {
            sublightTypeModel.append({
                text: qsTr("left"),
                value: 2,
                visible: !isCrosswalk
            });
            sublightTypeModel.append({
                text: qsTr("forward"),
                value: 1,
                visible: true
            })
            sublightTypeModel.append({
                text: qsTr("right"),
                value: 3,
                visible: !isCrosswalk
            })
            sublightTypeModel.append({
                text: qsTr("uturn"),
                value: 4,
                visible: !isCrosswalk
            })
            completed = true;
        }

        onIsCrosswalkChanged: {
            if(completed) {
                setProperty(0, "visible", !TrafficLightEditPanelVM.isCrosswalk)
                setProperty(2, "visible", !TrafficLightEditPanelVM.isCrosswalk)
                setProperty(3, "visible", !TrafficLightEditPanelVM.isCrosswalk)
            }
        }

    }
    background: Rectangle {
        color: 'white'
    }
    contentItem: ColumnLayout {
        Layout.leftMargin: 12 * config_id.screenScale

        Label{
            Layout.leftMargin: 12 * config_id.screenScale
            Layout.fillWidth: true
            Layout.preferredHeight: 40 * config_id.screenScale
            text: TrafficLightEditPanelVM.title
            color: "#000000"
            font.pixelSize: 12 * config_id.screenScale
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1 * config_id.screenScale
            color: "#BBBBBB"
        }
        RowLayout {
            TabBar {
                    id: sublightTypeTabBar
                    Layout.fillWidth: true
                    Layout.leftMargin: 12 * config_id.screenScale
                    Layout.preferredHeight: 30 * config_id.screenScale
                    property bool isCrosswalk: TrafficLightEditPanelVM.isCrosswalk
                    onIsCrosswalkChanged: {
                        if (isCrosswalk) {
                            // 人行道默认选中forward
                            sublightTypeTabBar.currentIndex = 1
                        }
                    }

                    Repeater{
                        model:sublightTypeModel
                        delegate: TabButton{
                            visible: model.visible
                            background: Rectangle{
                                color: parent.checked ? '#DAEBFD' : 'white'
                            }
                            contentItem: Label{
                                text: model.text
                                font.family: "Regular"
                                horizontalAlignment: Label.AlignHCenter
                                verticalAlignment: Label.AlignVCenter
                            }
                        }
                    }
                }

            Rectangle {
                Layout.preferredWidth: 14 * config_id.screenScale
                Layout.preferredHeight: 14 * config_id.screenScale
                Layout.leftMargin: 7 * config_id.screenScale
                Layout.rightMargin: 7 * config_id.screenScale
                color: 'green'
                Label{
                    text: '+'
                    anchors.centerIn: parent
                    font.bold: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: listViews.itemAt(
                                   sublightTypeTabBar.currentIndex).model.addItem(
                                   1, 0)
                }
            }
        }

        StackLayout {
            id: stackLayout
            currentIndex: sublightTypeTabBar.currentIndex
            Layout.fillHeight: true
            Layout.fillWidth: true
            Repeater {
                id: listViews
                model: 4
                delegate: ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: {
                        switch (index) {
                        case 0:
                            return TrafficLightEditPanelVM.leftSignalFlowList
                        case 1:
                            return TrafficLightEditPanelVM.forwordSignalFlowList
                        case 2:
                            return TrafficLightEditPanelVM.rightSignalFlowList
                        case 3:
                            return TrafficLightEditPanelVM.uturnSignalFlowList
                        }
                    }
                    delegate: sublightFlowCom
                    spacing: 2 * config_id.screenScale
                    clip: true
                    boundsBehavior: ListView.StopAtBounds
                    ScrollIndicator.vertical: ScrollIndicator {}
                    move: Transition {
                        NumberAnimation {
                            property: "y"
                            duration: 200
                        }
                    }
                    //被交换的项
                    moveDisplaced: Transition {
                        NumberAnimation {
                            property: "y"
                            duration: 200
                        }
                    }
                    remove: Transition {
                        ParallelAnimation {
                            NumberAnimation {
                                property: "opacity"
                                to: 0
                                duration: 200
                            }
                            NumberAnimation {
                                properties: "x"
                                to: 100
                                duration: 200
                            }
                        }
                    }
                    removeDisplaced: Transition {
                        SequentialAnimation {
                            NumberAnimation {
                                duration: 200
                            }
                            NumberAnimation {
                                properties: "x,y"
                                duration: 100
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1 * config_id.screenScale
            color: "#BBBBBB"
        }
        RowLayout {
            Layout.leftMargin: 12 * config_id.screenScale
            Label {
                horizontalAlignment: Text.AlignLeft
                text: qsTr("触发方式")
                font.pixelSize: 12 * config_id.screenScale
                color: "#000000"
            }
            Item {
                Layout.fillWidth: true
            }
        }
        ColumnLayout {
            Layout.leftMargin: 24 * config_id.screenScale
            // Layout.preferredHeight: 200 * config_id.screenScale
            ButtonGroup {
                id: triggerBtnGroup
            }
            DriveCheckButton {
                id: trigger_always_check_id
                Layout.preferredWidth: 90 * config_id.screenScale
                Layout.preferredHeight: 20 * config_id.screenScale
                x : 10 * config_id.screenScale
                checked : TrafficLightEditPanelVM.trigger == 0
                ButtonGroup.group: triggerBtnGroup
                text: qsTr("一直运行")
                onClicked: {
                    TrafficLightEditPanelVM.trigger = 0
                }
            }
            DriveCheckButton {
                id: trigger_by_hero_car_check_id
                Layout.preferredWidth: 90 * config_id.screenScale
                Layout.preferredHeight: 20 * config_id.screenScale
                x : 10 * config_id.screenScale
                checked : TrafficLightEditPanelVM.trigger == 1
                ButtonGroup.group: triggerBtnGroup
                text: qsTr("主车到达指定位置")
                onClicked: {
                    TrafficLightEditPanelVM.trigger = 1
                }
            }
            TextField {
                visible : trigger_by_hero_car_check_id.checked
                id:trigger_param_str_id
                Layout.preferredWidth: 200 * config_id.screenScale
                horizontalAlignment: TextField.AlignRight
                verticalAlignment: TextField.AlignVCenter
                font.pixelSize: 12 * config_id.screenScale
                color: "#000000"
                selectByMouse: true
                selectionColor: "#999999"//选中背景颜色
                placeholderText: TrafficLightEditPanelVM.herocarPos == "" ? qsTr("主车坐标x,y") : TrafficLightEditPanelVM.herocarPos
                background: Rectangle {
                    border.width: 1; //border.color: "#B2B2B2"
                    radius: 4; 
                    border.color: "#000000"
                    color: "#FFFFFF" //"transparent"
                    opacity: 0.1
                    implicitWidth: 100 * config_id.screenScale
                }
                onAccepted: {
                    console.log("trigger_by_hero_car_check_id text ", text)

                    TrafficLightEditPanelVM.herocarPos = text
                    focus = false
                    
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0, TrafficLightEditPanelVM.herocarPos)
                    }
                }
            }

         
            Item{
                Layout.preferredHeight: 12 * config_id.screenScale
            }
        }
    }
}
