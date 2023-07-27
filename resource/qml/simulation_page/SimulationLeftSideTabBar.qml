import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "qrc:/resource/control"
import "qrc:/resource/qml/config"

TabBar{
    id: control
    width: 30 * config_id.screenScale
    height: listView.contentHeight
    background: Item{}

    contentItem: ListView{
        id: listView
        spacing: 1
        model: control.contentModel
        boundsBehavior: Flickable.StopAtBounds
        interactive: false
    }

    ListModel
    {
        id: listModel
        ListElement{
            text: qsTr("背景")
        }
        ListElement{
            text: qsTr("仿真测试")
        }
        
        Component.onCompleted: 
        { 
            getTabFromConfig() // 调用函数创建tab

            function getTabFromConfig()
            {

                var tabSet=new Set();
                for(var key in config_id.scenoriaConfig)
                {
                    if(config_id.scenoriaConfig[key].is_show_in_edit_control)
                    {
                        var tab_name = config_id.propertyConfig[ config_id.scenoriaConfig[key].property1 ].name
                        tabSet.add(tab_name)
                    }
                    
                }
                // 遍历tabSet
                for(var item of tabSet)
                {
                    listModel.append( {"text":item} )

                }
            }
        }     
       
        // ListElement{
        //     text: qsTr("动态物体")
        // }
        // ListElement{
        //     text: qsTr("静态物体")
        // }
        // ListElement{
        //     text: qsTr("传感器")
        // }
    }

    Repeater{
        model: listModel
        delegate: TabButton{
            id: tabButton
            width: 30 * config_id.screenScale
            implicitHeight: 100 * config_id.screenScale
            checkable: true
            checked: index === 1
            text: model.text
            background: RadiusRectangle{
                color: tabButton.checked ? "#FFFFFF" : "#EDF1F2"
                        topRightRadius: 10
                        topLeftRadius: 0
                        bottomLeftRadius: 0
                        bottomRightRadius:  10
            }
            contentItem: Label{
                text: parent.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WrapAnywhere
                color: "#101010"
                font.pixelSize: 12 * config_id.screenScale
            }
            onClicked:
            {
                //console.log("tab button on clicked",model.text)
                event_bus_id.simulationLeftSideTabBarPressed(model.text)
            }
        }
    }
    
}
