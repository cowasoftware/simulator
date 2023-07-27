import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1

import COWA.Simulator 1.0

import "qrc:/resource/qml/config"

Item
{
	id: simulation_edit_control_item_id

    property var left_tab_name:config_id.propertyConfig[config_id.edit_obstacle].name //默认是"动态物体"

    /*
    *	接受增加车辆等物体的信息
    *	//function addModelData(){}
    
    *	输入要增加的物体隶属于哪个list
    *	找到该物体父节点所在的层——index
    * 	再将要增加的那个物体，放在index的子节点中
    *
    *	findIndex()：输入物体名字，存在则返回所在层；不存在则返回-1.
    *	addModelData():用于增加物体
    *	调用格式为：addModelData("主车","list的图标","物体类型")
    *   注意：物体类型是主车的孩子节点
    */

    function findIndex(fatherName){
        for(var i = 0 ; i < myModel.count ; ++i){
            if(myModel.get(i).name == fatherName){
                return i
            }
            //console.log("myModel.get(i).name:...",myModel.get(i).name)
        }
        //console.log("myModel.count:...",myModel.count)
        return -1
    }

    function isHeroCar(type) {
        return type >= config_id.hero_car_type_start && type <= config_id.hero_car_type_end
    }
    function addModelData(fatherName, picture_source,type){
        var index = findIndex(fatherName)
        if(index == -1)
        {
            //如果不存在，则创建新的父节点
            // console.log("fatherName:...",index)
            myModel.append({
                "name":fatherName,
                "picture_source":picture_source,
                "level":0,"subNode":[]
            })

            // 创建完父节点，再递归创建子节点
            if(type!=-1)
            {
                addModelData( fatherName, picture_source,type ) 
            }
                                
        }
        else
        {
            myModel.get(index).subNode.append({
                "type": type, 
                "name":config_id.scenoriaConfig[type].name,
                "name_en":config_id.scenoriaConfig[type].name_en,
                "picture_source":config_id.scenoriaConfig[type].image_source, 
                "level":index + 1, "subNode":[]
            })
        }
    }

    function buildModel(tabName)
    {
        var father_icon = "qrc:///resource/image/simulation_page/edit_control_list_menu.png"

        if ( tabName == config_id.propertyConfig[config_id.edit_obstacle].name )
        {
            // 动态物体强制把主车放在第一个位置，设置type为-1，即不创建子节点
            addModelData(config_id.propertyConfig[ config_id.hero_car ].name,father_icon,-1) 
        }

        // 遍历map
        for(var key in config_id.scenoriaConfig)
        {
            // 左侧tab && 可见才加入model
            if ( tabName == config_id.propertyConfig[ config_id.scenoriaConfig[key].property1 ].name &&  
                    config_id.scenoriaConfig[key].is_show_in_edit_control )
            {                                         
                var father_name = config_id.propertyConfig[ config_id.scenoriaConfig[key].property2 ].name
                
                var role_type = key

                // console.log(" config_id.scenoriaConfig.key " , key,config_id.scenoriaConfig[role_type].name)
                
                addModelData(father_name,father_icon,role_type)
            }// end if               
        }// end for

        simulation_test_rect_id.visible = false;
        if (tabName == "仿真测试")
        {
            simulation_test_rect_id.visible = true;
        }
    }// end func

    Rectangle
    {
        id: simulation_test_rect_id
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        property var test_num: 1
        property var test_describe: ""

        TextInput
        {
            id: simulate_title_id
            x: 10
            y: 20
            width: parent.width - simulate_title_id.x * 2
            height: 30
            text: "仿真测试检测项"
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
        }

        TextEdit
        {
            id: simulation_label_id
            x: 20
            y: 50
            width: parent.width - simulation_label_id.x * 2
            height: parent.height - simulation_label_id.y
            wrapMode: Text.WordWrap
            text: simulation_test_rect_id.test_describe
            font.pixelSize: 16
        }
    }

	ListModel {
        id: myModel
        Component.onCompleted: { 
            buildModel( left_tab_name ) //函数调用以创建myModel
        }
    }
 
    Component //委托提供一个展示数据的示例（如何展示一个模型中的数据）
    {
        id:list_delegate

        Column
        {
            id:objColumn

            Component.onCompleted: 
            {
                //默认展开列表
                for(var i = 1; i < objColumn.children.length - 1; ++i) 
                {
                    objColumn.children[i].visible = true
                }
                iconAin.from = 0
                iconAin.to = 90
                iconAin.start()

                simulation_test_rect_id.visible = false
            }

            MouseArea
            {
                width:listView.width
                height: objItem.implicitHeight
                enabled: objColumn.children.length > 2

                onClicked:
                {
                    //console.log("list_delegate onClicked..")

                    //flag用于判断列表是否释放，后续用于播放动画
                    var flag = false;

                    for(var i = 1; i < parent.children.length - 1; ++i) 
                    {
                        //console.log("onClicked..i=",i)

                        flag = parent.children[i].visible 
                        //console.log("flag..",flag) 

                        //取反，原来设置的是false，现在点击就是true
                        parent.children[i].visible = !parent.children[i].visible   
                    }
                    //console.log("onClicked..flag = ",flag) 

                    //如果放下菜单，则播放icon放下动画;否则播放图片上扬动画
                    if(!flag)
                    {
                        iconAin.from = 0
                        iconAin.to = 90
                        iconAin.start()
                    }
                    else
                    {
                        iconAin.from = 90
                        iconAin.to = 0
                        iconAin.start()
                    }
                }
                
                //row用于展示灰色的列表标题、图标等信息
                Row{
                    id:objItem
                    spacing: 9 * config_id.screenScale
                    leftPadding: 10 * config_id.screenScale

					Rectangle
					{
						id:list_rect
						width:200 * config_id.screenScale
						height:30 * config_id.screenScale
						color:"#EDF1F2"

						Image 
						{							
							id: icon
							anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.topMargin:  6 * config_id.screenScale
                            anchors.leftMargin: 3 * config_id.screenScale
							width: 20 * config_id.screenScale
							height: 20 * config_id.screenScale
							source: picture_source  //来自myModel的一级列表图标路径属性

							//旋转动画- 控制旋转值的变化
							RotationAnimation{
								id:iconAin
								target: icon
								duration: 100   //动画时间
							}
						}

						Text
						{
							id: list_name
							x:icon.x + icon.width + 11 * config_id.screenScale
							y: icon.y
							width: 24 * config_id.screenScale
							height: 19 * config_id.screenScale
							text: name  //来自myModel的一级列表名字属性
							font.styleName: "Regular"
							font.pixelSize: 12 * config_id.screenScale
							color: "#505559"
							horizontalAlignment: Text.AlignLeft
							verticalAlignment: Text.AlignVCenter
						}
					}                   
                }
            }

            //重复排布myModel的子节点subNode
            Repeater 
            {
               model: subNode

               delegate: Rectangle
               {     //子物体展示，如车辆、行人的图片、文字信息。
                    id:role_rect_id
					x:0
					y:0
                    width: 210 * config_id.screenScale
                    height: 70 * config_id.screenScale
                    Image
                    {
                        id: role_icon
                        anchors.left: parent.left

                        
                        anchors.leftMargin: 28 * config_id.screenScale
                        width: isHeroCar(type) ? 55 * config_id.screenScale : 50 * config_id.screenScale
                        height: isHeroCar(type) ? 55 * config_id.screenScale: 50 * config_id.screenScale
                        y : (parent.height - height) / 2

                        source: picture_source
                        fillMode: Image.PreserveAspectFit
                    }					
					Text
					{
						id: list_name
                        x:role_icon.x + role_icon.width + 9 * config_id.screenScale
                        y : isHeroCar(type) ? 25 * config_id.screenScale : 15 * config_id.screenScale
						width: 65 * config_id.screenScale
						height: 20 * config_id.screenScale
						text: name
						font.styleName: "Regular"
						font.pixelSize: isHeroCar(type) ? 14 * config_id.screenScale : 12 * config_id.screenScale
						color: "#505559"
						horizontalAlignment: Text.AlignLeft
						verticalAlignment: Text.AlignVCenter
					}
                    Text
					{
                        visible : !isHeroCar(type)
						id: list_en_name
                        x:role_icon.x + role_icon.width + 9 * config_id.screenScale
                        y : 35 * config_id.screenScale
						width: 65 * config_id.screenScale
						height: 20 * config_id.screenScale
						text: name_en
						font.styleName: "Regular"
						font.pixelSize: 12 * config_id.screenScale
						color: "#505559"
						horizontalAlignment: Text.AlignLeft
						verticalAlignment: Text.AlignVCenter
					}

                    MouseArea
                    {
                        id:role_mouse_id
                        anchors.fill: parent                       
                        hoverEnabled:true
                        pressAndHoldInterval : 1

                        onPressAndHold:
                        {
                            // 发送信号，simulation_page接收
                            event_bus_id.getIconSourceToMoveCar(type)

                            //console.log("onPressAndHold image_source:",picture_source)
                        }       
                    }
               }
            }
        }
    }

    ListView
    {
        id:listView
        anchors.fill: parent
        anchors.top: parent.top
        anchors.topMargin:20 * config_id.screenScale
        spacing: 20 * config_id.screenScale

        orientation: ListView.Vertical  //垂直列表
        interactive: true;              //元素可用鼠标滚轮
        clip: true                      //限制顶部，使得不超出区域
        boundsBehavior:Flickable.StopAtBounds  //listview不跳动
     
        model:myModel
        delegate: list_delegate
    }

    Connections
    {
        target:event_bus_id

        function onSimulationLeftSideTabBarPressed(name)
        {
            myModel.clear()

            left_tab_name = name
            buildModel( left_tab_name )
        }
    }

    Connections
    {
        target: ScenarioControl

        function onNotifySetSimulationTestInfo(id, name, circleInfo)
        {
            if (id == "" && name == "")
            {
                return
            }
            if (name == "")
            {
                simulation_test_rect_id.test_describe = simulation_test_rect_id.test_describe +
                    simulation_test_rect_id.test_num + "." + id + "\n";
            }
            else
            {
                simulation_test_rect_id.test_describe = simulation_test_rect_id.test_describe +
                    simulation_test_rect_id.test_num + "." + name + "\n";
            }
            ++simulation_test_rect_id.test_num
        }

        function onNotifyClearSimulationTestInfo()
        {
            simulation_test_rect_id.test_num = 1
            simulation_test_rect_id.test_describe = ""
        }
    }
}