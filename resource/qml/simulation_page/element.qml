import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2
import COWA.Simulator 1.0

Rectangle
{
    id: car_image_rect_id
    x: 0
    y: 0
    width: 0
    height: 0

    color: "#00000000"
    border.color: "green"
	border.width: 2

	// property var element_type: ["obstacle", "garbage", "light"]

	property var map_x : 0
	property var map_y : 0

    property var car_image_source: qsTr("")
	property var car_image_rotate: 0
	property var element_id: 0
	property var type: element_type[0]  // or light
	property var is_hoverd: false
	property var obstacle_opacity: 0.8

	rotation: car_image_rotate

    Image
	{
		id: car_image_id
		x: 0
		y: 0
		width: parent.width
		height: parent.height
		source: car_image_rect_id.car_image_source
		opacity: car_image_rect_id.obstacle_opacity

		Text
		{
			id: car_image_text_id
			x: 0
			y: 0
			width: parent.width
			height: parent.height
			text:  element_id == -1 ? qsTr("☆") : (element_id == -2 ? qsTr("*") :
					qsTr(element_id.toString()))
			color: "#FF0000"

			property var hero_car_font_size: parent.parent.parent.canvas_scale > 18 ? parent.parent.parent.canvas_scale : 18
			property var obstacle_font_size: (car_image_rect_id.width < car_image_rect_id.height ? car_image_rect_id.width : car_image_rect_id.height) * 0.5

			font.pixelSize: ((element_id == -1 || element_id == -2) ? hero_car_font_size : Number(obstacle_font_size < 1 ? 1 : obstacle_font_size))

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
		}
	}

	MouseArea
	{
		id: car_image_mouse_id
		anchors.fill: parent
		propagateComposedEvents: true
		hoverEnabled: true
		property var needKeepVisible : false
		property var isVisible : false

		onEntered: { show() }

		onExited: { hide() }

		onClicked: {select()}

        onPressed:
        {
			// console.log("car_image_mouse_id", "onPressed")
            if (line_drawer.tool_type == 1 && (pressedButtons & Qt.LeftButton) && 
				(car_image_rect_id.type == config_id.element_type[1] || 
				car_image_rect_id.type == config_id.element_type[2])) {
				// obstacle, garbage
				event_bus_id.canvasElementPressed(car_image_rect_id.element_id,
					mouseX / car_image_rect_id.width, mouseY / car_image_rect_id.height)
				mouse.accepted = false
            }

			// light
			if (car_image_rect_id.type == config_id.element_type[4]) {
				car_image_mouse_id.needKeepVisible = !car_image_mouse_id.needKeepVisible
				if (car_image_mouse_id.needKeepVisible) {
					console.log("car_image_mouse_id.needKeepVisible", car_image_mouse_id.needKeepVisible)
					show()
				} else {
					console.log("car_image_mouse_id.needKeepVisible", car_image_mouse_id.needKeepVisible)
					hide()
				}
			}
        }

		function show() {
			is_hoverd = true
			// parent.border.color = "green"
			// console.log("show", car_image_rect_id.element_id)
			if (car_image_rect_id.type == config_id.element_type[4])
			{
				console.log("show", car_image_rect_id.type, car_image_rect_id.element_id)
				if (!car_image_mouse_id.isVisible) {
					event_bus_id.showLightInfo(car_image_rect_id.element_id)
					car_image_mouse_id.isVisible = true
				}
			}
		}

		function hide() {
			is_hoverd = false
			// console.log("hide", car_image_rect_id.element_id)
			if (car_image_rect_id.type == config_id.element_type[4])
			{
				if (car_image_mouse_id.isVisible && !car_image_mouse_id.needKeepVisible) {
					event_bus_id.hideLightInfo(car_image_rect_id.element_id)
					car_image_mouse_id.isVisible = false
				}
			}
		}

		function select() {
			if (car_image_rect_id.type == config_id.element_type[4])
			{
				event_bus_id.selectLight(car_image_rect_id.element_id)
			}
		}
	}

	Connections
    {
        target: event_bus_id

        function onKeyPressed(keyboardCode)
		{
			if (!car_image_rect_id.is_hoverd || line_drawer.tool_type != 1 || 
				car_image_rect_id.type == config_id.element_type[4]) {
				// light 不处理
				return
			}

			//逆时针
			if (keyboardCode == Qt.Key_Left || keyboardCode == Qt.Key_A )
			{
				car_image_rect_id.car_image_rotate -= 1
			}
			//顺时针
			else if (keyboardCode == Qt.Key_Right || keyboardCode == Qt.Key_D )
			{
				car_image_rect_id.car_image_rotate += 1
			}

			//逆时针 
			if (keyboardCode == Qt.Key_Up || keyboardCode == Qt.Key_W )
			{
				car_image_rect_id.car_image_rotate -= 10
			}
			//顺时针
			else if (keyboardCode == Qt.Key_Down || keyboardCode == Qt.Key_S )
			{
				car_image_rect_id.car_image_rotate += 10
			}

			if (car_image_rect_id.car_image_rotate < -180)
			{
				car_image_rect_id.car_image_rotate += 360
			}
			else if (car_image_rect_id.car_image_rotate > 180)
			{
				car_image_rect_id.car_image_rotate -= 360
			}

			if (car_image_rect_id.type == config_id.element_type[0])
			{
				var heroCarModel = ScenarioControl.findHeroCarModel()
				heroCarModel.theta = -car_image_rect_id.car_image_rotate / 360 * 2 * Math.PI
				event_bus_id.notifyUpdateHeroCar()
				SimulatorControl.syncSceneToServer();
			}
			else if(car_image_rect_id.type == config_id.element_type[1]) 
			{
				var obstacleModel = ScenarioControl.findObstacleModel(car_image_rect_id.element_id)
				if (obstacleModel != null)
				{
					obstacleModel.theta = -car_image_rect_id.car_image_rotate / 360 * 2 * Math.PI
					event_bus_id.notifyUpdateObstacle(car_image_rect_id.element_id)
				}
			} else if (car_image_rect_id.type == config_id.element_type[2]) {
				var garbageModel = ScenarioControl.findGarbageModel(car_image_rect_id.element_id)
				if (garbageModel != null)
				{
					garbageModel.theta = -car_image_rect_id.car_image_rotate / 360 * 2 * Math.PI
					event_bus_id.notifyUpdateGarbage(car_image_rect_id.element_id)
				}
			}
		}
	}
}