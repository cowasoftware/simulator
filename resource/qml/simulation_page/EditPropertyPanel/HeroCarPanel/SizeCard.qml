import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import COWA.Simulator.VModel 1.0
import "qrc:/resource/control"
import "../../../../control"

Control{
    contentItem: ColumnLayout{
        Label{
            horizontalAlignment: Text.AlignLeft
            text: qsTr("尺寸")
            font.pixelSize: 12 * config_id.screenScale
            color: "#000000"
        }

        GridLayout{
            Layout.leftMargin: 24 * config_id.screenScale
            columns: 2
            columnSpacing: 24 * config_id.screenScale

            EditField{
                id:lengthEditField
                Layout.preferredWidth: 96 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("L")
                unit.text: qsTr("m")
                text: HeroCarEditPanelVM.length
                interval.bottom: 0.0
                onAccepted: {
                    HeroCarEditPanelVM.length = value
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.length)
                    }
                }
            }

            EditField{
                id:widthEditField
                Layout.preferredWidth: 96 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("W")
                unit.text: qsTr("m")
                text: HeroCarEditPanelVM.width
                interval.bottom: 0.0
                onAccepted: {
                    HeroCarEditPanelVM.width = value
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.width)
                    }
                }
            }

            EditField{
                id: heightEditField
                Layout.preferredWidth: 96 * config_id.screenScale
                Layout.preferredHeight: 30 * config_id.screenScale
                leftPadding: 48 * config_id.screenScale
                rightPadding: 8 * config_id.screenScale
                title.text: qsTr("H")
                unit.text: qsTr("m")
                text: HeroCarEditPanelVM.height
                interval.bottom: 0.0
                onAccepted: {
                    HeroCarEditPanelVM.height = value
                    HeroCarEditPanelVM.edited()
                    focus = false
                }
                onFocusChanged: {
                    if(!focus){
                        clear()
                        insert(0,HeroCarEditPanelVM.height)
                    }
                }
            }

            Button{
                id: btnLocker
                property bool unlocked: true
                Layout.preferredWidth: 18 * config_id.screenScale
                Layout.preferredHeight: 18 * config_id.screenScale
                background: Item{}
                contentItem: Image{
                    anchors.fill: parent
                    source: parent.unlocked ?  "qrc:/resource/image/simulation_page/icon_property_unlock.png" : "qrc:/resource/image/simulation_page/icon_property_lock.png"
                }
                onClicked: unlocked = !unlocked
            }
        }
    }

    Connections{
        target: HeroCarEditPanelVM
        function onFocusLosed(){
            lengthEditField.focus = false
            widthEditField.focus = false
            heightEditField.focus = false
        }
    }
}
