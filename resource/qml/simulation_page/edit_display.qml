import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2

import COWA.Simulator 1.0
import "qrc:/resource/qml/config"

Rectangle
{
    id: simulation_edit_display_item_id
    width: 267 * config_id.screenScale
    height: 368 * config_id.screenScale

    Rectangle {
        id: simulation_edit_display_rect_id
        width: parent.width
        height: 53 * config_id.screenScale
        // color: "#FF0000"
        Text {
            id: simulation_edit_display_text_id
            x: 13 * config_id.screenScale
            y: 0
            width: parent.width
            height: parent.height
            text: qsTr("元素列表")
            font.styleName: "Regular"
            font.pixelSize: 18 * config_id.screenScale
            color: "#505559"
            // horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        // 搜索框 暂时去掉,后续实现功能了再加
        // Image {
        //     id: sourch_image_id
        //     x: 220
        //     source: "qrc:///resource/image/simulation_page/search.png"
        //     fillMode: Image.PreserveAspectFit
        //     scale: 0.8
        //     anchors.verticalCenter: parent.verticalCenter
        //     MouseArea {
        //         anchors.fill: parent
        //         onClicked: {
        //             onSearchClicked("搜索框被点击")
        //         }
        //     }
        // }

    }

    //View
    ListView {
        id: listView
        width: parent.width
        height: parent.height - simulation_edit_display_rect_id.height - 1
        y: simulation_edit_display_rect_id.height
        z : 0
        orientation: ListView.Vertical
        boundsBehavior:Flickable.StopAtBounds
        spacing: 10
        model: objModel
        delegate: objDelegate
        onCountChanged: {
            if(count === 0){
                event_bus_id.emptyEditDisplay()
            }
        }
    }

    property int herocar_size : 0
    property int obstacles_size : 0
    property int garbages_size : 0
    property int linecurves_size : 0
    property int circle_size : 0
    property int lastSelectedIndex : -1

    // 支持ctrl-c ctrl-v快速复制粘贴一个新的障碍物
    property int lastCopyItemIndex : -1

    //Model
    ListModel {
        id: objModel
        Component.onCompleted: {
        }
    }

	//Delegate
	Component {
		id: objDelegate
		Rectangle {
			id: item_rect_id
			width: 250 * config_id.screenScale
			
			height: 40 * config_id.screenScale
            color: lastSelectedIndex === index ? "#DAEBFD" : "#FFFFFF"
			Image {
				id: item_image_id
				width: model.type === 2 ? 25 * config_id.screenScale : 36 * config_id.screenScale
				height: model.type === 2 ? 25 * config_id.screenScale : 36 * config_id.screenScale
				x : 20
				source: qsTr(model.image)
				fillMode: Image.PreserveAspectFit
				anchors.verticalCenter: parent.verticalCenter
			}
			Text {
				id: item_image_text_id
				width: 36 * config_id.screenScale
				height: 36 * config_id.screenScale
				anchors.left: item_image_id.right
				anchors.leftMargin: model.type === 2 ? 28 * config_id.screenScale : 18 * config_id.screenScale
				text: qsTr(model.name)
				font.styleName: "Regular"
				font.pixelSize: 15 * config_id.screenScale
				// color: "#FF0000"
				color: "#505559"
				verticalAlignment: Text.AlignVCenter 	
				anchors.verticalCenter: parent.verticalCenter
			}
			MouseArea {
				anchors.fill: parent
                onClicked: selectItem(index, model.id)
				onDoubleClicked: {
					console.log("onDoubleClicked", "")
				}
			}
		}
	}


    Connections {
        target: ScenarioControl
        function onNotifyAddObstacle(model_id, model) {
            var template = config_id.scenoriaConfig[model.type]
            var element = {}
            element.type = config_id.element_type[1] // for obs
            element.id = model_id
            element.name = template.name + "-" + model_id
            element.image = template.image_source

            var index = herocar_size + obstacles_size
            obstacles_size = obstacles_size + 1
            objModel.insert(index, element)
            //console.log("onNotifyAddObstacle id:", model_id,  herocar_size, obstacles_size )
            if (config_id.simulatorType !== "record" ) { 
                selectItem(index, model_id)
            }
        }

        function onNotifyAddHeroCar(model) {
            //console.log("onNotifyAddHeroCar", model)
            var template = config_id.scenoriaConfig[model.type]
            var element = {};
            element.type = config_id.element_type[0] // for hero
            element.id = -1
            element.name = template.name
            element.image = template.image_source
            if (herocar_size > 0) {
                herocar_size = 0
                objModel.remove(0);
            }
            herocar_size = 1
            objModel.insert(0, element)
            if (config_id.simulatorType !== "record" ) { 
                selectItem(0, -1)
            }
        }

        function onNotifyAddGarbage(model_id, model) {
            var template = config_id.scenoriaConfig[model.type]
            var element = {}
            element.type = config_id.element_type[2] // for garbage
            element.id = model_id
            element.name = template.name + "-" + model_id
            element.image = template.image_source

            var index = herocar_size + obstacles_size
            obstacles_size = obstacles_size + 1
            objModel.insert(index, element)
            //console.log("onNotifyAddObstacle id:", model_id,  herocar_size, obstacles_size )
            if (config_id.simulatorType !== "record" ) { 
                selectItem(index, model_id)
            }
        }

        function onNotifyUpdateGarbage(model_id, model) {
            var template = config_id.scenoriaConfig[model.type]
            var element = {}
            element.type = config_id.element_type[2] // for garbage
            element.id = model_id
            element.name = template.name + "-" + model_id
            element.image = template.image_source
            var index = herocar_size + obstacles_size
            obstacles_size = obstacles_size + 1
            objModel.insert(index, element)
            if (config_id.simulatorType !== "record" ) { 
                selectItem(0, -1)
            }
        }

        function onNotifyDeleteHeroCar() {
            herocar_size = 0
            objModel.remove(0)
            if (objModel.count > 0) {
                if (config_id.simulatorType !== "record" ) { 
                    selectItem(0, objModel.get(0).id)
                }
            } else { // empty
                lastSelectedIndex = -1
            }
            //console.log("onNotifyDeleteHeroCar")
        }
        function onNotifyDeleteObstacle(id) {
            var pos = -1
            for (var i = herocar_size; i < herocar_size + obstacles_size; ++i) {
                if (id === objModel.get(i).id) {
					pos = i
					break;
				}
			}
			//console.log(id, " xxx ", obstacles_size , pos)
			if (pos >= 0) {
				var index = pos
				obstacles_size = obstacles_size - 1
				objModel.remove(pos)
				if (objModel.count > 0) {
					if (index  > 0) { 
						index = index - 1
					}
                    if (config_id.simulatorType !== "record" ) { 
                        selectItem(index, objModel.get(index).id)
                    }
				} else { // empty
					lastSelectedIndex = -1
				}
				//console.log("onNotifyDeleteObstacle")
			}
		}

        function onNotifyDeleteGarbage(id) {
            var pos = -1
            for (var i = herocar_size; i < herocar_size + obstacles_size; ++i) {
                if (id === objModel.get(i).id) {
					pos = i
					break;
				}
			}
			if (pos >= 0) {
				var index = pos
				obstacles_size = obstacles_size - 1
				objModel.remove(pos)
				if (objModel.count > 0) {
					if (index  > 0) { 
						index = index - 1
					}
                    if (config_id.simulatorType !== "record" ) { 
                        selectItem(0, objModel.get(0).id)
                    }
				} else { // empty
					lastSelectedIndex = -1
				}
			}
        }

		function onNotifyAddCurveModel(line_id) {
			// var line_id = ScenarioControl.addCurvePoints(line_array)
			var element = {}
			element.type = config_id.element_type[3] // for line curves
			element.id = line_id
            element.name = qsTr("轨迹线") + "-" + line_id
            element.image = "qrc:///resource/image/simulation_page/icon_tool_canvas_timeline.png"
			objModel.append(element)
			linecurves_size = linecurves_size  + 1
            if (config_id.simulatorType !== "record" ) { 
			    selectItem(objModel.count - 1, line_id)
            }
		}
        // function onNotifyAddRoutingPoints(points) {
        //     var element = {}
		// 	element.type = 2 // for line curves
		// 	element.id = -1
        //     element.name = qsTr("主车目的点")
        //     element.image = "qrc:///resource/image/simulation_page/icon_tool_herocar_dest.png"
        //     objModel.append(element)
		// 	linecurves_size = linecurves_size  + 1
        //     if (config_id.simulatorType !== "record" ) { 
		// 	    selectItem(objModel.count - 1, -1)
        //     }
        // }

		function onNotifyDeleteCurveModel(line_id) {
			// ScenarioControl.deleteCurvePoints(line_id);
			var pos = -1
			for (var i = herocar_size + obstacles_size; i < objModel.count; ++i) {
                if (line_id === objModel.get(i).id) {
					pos = i
					break;
				}
			}
			if (pos >= 0) {
				var index =  pos
				linecurves_size = linecurves_size - 1
				objModel.remove(index)
				if (objModel.count > 0) {
					if (index  > 0) {index = index - 1}
                    if (config_id.simulatorType !== "record" ) { 
                        selectItem(index, objModel.get(index).line_id)
                    }
				} else { // empty
					lastSelectedIndex = -1
				}
				console.log("onNotifyDeleteCurveModel")
			} 

        }

         /** 通过场景文件添加circle **/
        function onNotifySetParkingArea(ids, points, raduii)
        {
            if (circle_size == 0)
            {
                console.log("onNotifySetParkingArea: ", ids)
                var element = {}
                element.type = config_id.element_type[5] // for circle
                element.name = qsTr("小巴停车区域")
                element.image = "qrc:///resource/image/simulation_page/icon_tool_circle.png"
                var index = herocar_size + obstacles_size
                objModel.insert(index, element)
                circle_size = 1
            }
            if (config_id.simulatorType !== "record" ) { 
			    event_bus_id.selectParkingArea()
            }
        }

        function onNotifyDeleteParkingArea()
        {
            var index = herocar_size + obstacles_size
            console.log("onNotifyDeleteParkingArea, index = ", index)
            objModel.remove(index, 1)
            circle_size = 0
            if (objModel.count > 0) {
                if (index  > 0) { 
                    index = index - 1
                }
                if (config_id.simulatorType !== "record" ) { 
                    selectItem(index, objModel.get(index).id)
                }
            } else { // empty
                lastSelectedIndex = -1
            }
        }

        function onNotifyClear() {
            herocar_size = 0
            obstacles_size = 0
            linecurves_size = 0
            circle_size = 0
            objModel.clear()
            lastSelectedIndex = -1
        }

    }

    Connections {
        target : event_bus_id
        function onKeyPressed(key) {
            if (key  === Qt.Key_Delete) {
                if(lastSelectedIndex >= 0) {
                    deleteItem(lastSelectedIndex)
                }
            }

            if (key === Qt.Key_V) {
                if (lastSelectedIndex >= 0) {
                    var old_id = objModel.get(lastSelectedIndex).id
                    console.log("copyObstacle " , old_id)
                    ScenarioControl.copyObstacle(old_id)
                }
            }
        }

        function onSelectHeroCar() {
            var index = 0
            lastSelectedIndex = index
            console.log("onSelectHeroCar" , index)
            listView.positionViewAtIndex(index, ListView.Visible)
        }

        function onSelectObstacle(id) {
            var index = -1
			for (var i = herocar_size; i < herocar_size + obstacles_size; ++i) {
                if (id === objModel.get(i).id) {
					index = i
					break;
				}
			}
			if (index >= 0) {
                lastSelectedIndex = index
                console.log("onSelectObstacle id", id, " index ", index)
                listView.positionViewAtIndex(index, ListView.Visible)
            }
        }

        function onSelectGarbage(id) {
            var index = -1
            for (var i = herocar_size; i < herocar_size + obstacles_size; ++i) {
                if (id === objModel.get(i).id) {
					index = i
					break;
				}
			}
            if (index >= 0) {
                lastSelectedIndex = index
                console.log("onSelectGarbage id", id, " index ", index)
                listView.positionViewAtIndex(index, ListView.Visible)
            }
        }

        /** 通过编辑i添加 **/
        function onAddParkingArea(ids, points, radii)
        {
            if (circle_size == 0)
            {
                console.log("onAddParkingArea")
                var element = {}
                element.type = config_id.element_type[5] // for parking area
                element.name = qsTr("小巴停车区域") 
                element.image = "qrc:///resource/image/simulation_page/icon_tool_circle.png"
                var index = herocar_size + obstacles_size
                objModel.insert(index, element)
                circle_size = 1
                lastSelectedIndex = index
                listView.positionViewAtIndex(index, ListView.Visible)
            }
        }

        function onSelectParkingArea()
        {
            console.log("onSelectParkingArea")
            var index = herocar_size + obstacles_size
            lastSelectedIndex = index
            listView.positionViewAtIndex(index, ListView.Visible)
        }
    }

    function onSearchClicked(args) {
        // TODO 响应搜索事件
        console.log(args)
    }

    function selectItem(index, model_id) {
        lastSelectedIndex = index
        listView.positionViewAtIndex(index, ListView.Visible)
        var element = objModel.get(index)
        console.log("selectItem, index: " , index, "type: ", element.type, "model_id: ", model_id)

        if (element.type === config_id.element_type[0]) {
            event_bus_id.selectHeroCar()
        } else if (element.type === config_id.element_type[1]) {
            event_bus_id.selectObstacle(model_id)
        } else if (element.type === config_id.element_type[2]) {
            event_bus_id.selectGarbage(model_id)
        } else if (element.type === config_id.element_type[3]) {
            event_bus_id.selectLineCurve(model_id)
        } else if (element.type === config_id.element_type[5]) {
            event_bus_id.selectParkingArea()
        }
    }


    // call c++ ScenarioControl delete data
    function deleteItem(index) {
        if (index < objModel.count) {
            var element = objModel.get(index)
            console.log("deleteItem, index: " , index, "objModel.count: ", objModel.count, "element type: ", element.type)
            if (element.type == config_id.element_type[0]) {
                ScenarioControl.deleteHeroCar()
            } else if (element.type == config_id.element_type[1]) {
                ScenarioControl.deleteObstacle(element.id)
            } else if(element.type == config_id.element_type[2]) {
                ScenarioControl.deleteGarbage(element.id)
            } else if(element.type == config_id.element_type[3]) {
                ScenarioControl.deleteObstacleCurveModel(element.id)
            } else if(element.type == config_id.element_type[5]) {
                console.log("delete area")
                ScenarioControl.deleteParkingArea()
            }
        }
    }
}
