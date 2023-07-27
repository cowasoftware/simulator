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
    //border.width: 2

	property var map_x : 0
	property var map_y : 0

    property var car_image_source: qsTr("")
	property var car_image_rotate: 0
	property var element_id: 0
    property var type
	property var vehicle_type
	property var is_hoverd: false
    property var car_length_b
    property var car_bridge_width1
    property var car_bridge_width2
	rotation: car_image_rotate

    Rectangle{
        width: parent.width
		height: parent.height
        x: width / 2 - car_image_rect_id.car_length_b
        y: 0
        //anchors.left: parent.left
        //anchors.leftMargin: Math.round(width / 2 - car_image_rect_id.car_length_b)
        color: "#00000000"
        border.color: "green"
        border.width: 2

        Image
        {
            id: car_image_id
            source: car_image_rect_id.car_image_source
            opacity: 0.8
            anchors.fill: parent

            Text
            {
                id: car_image_text_id
                x: 0
                y: 0
                width: parent.width
                height: parent.height
                color: "#FF0000"

                property var hero_car_font_size: parent.parent.parent.canvas_scale > 18 ? parent.parent.parent.canvas_scale : 18
                property var obstacle_font_size: (car_image_rect_id.width < car_image_rect_id.height ? car_image_rect_id.width : car_image_rect_id.height) * 0.5

                font.pixelSize: ((element_id == -1 || element_id == -2) ? hero_car_font_size : Number(obstacle_font_size < 1 ? 1 : obstacle_font_size))

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle{
                id: bridge2
                width: 2
                height: car_bridge_width2
                anchors.left: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: vehicle_type === 101
                color: 'yellow'
            }

            Rectangle{
                id: bridge1
                width: 2
                height: car_bridge_width1
                anchors.left: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: vehicle_type === 101
                color: 'black'
            }


            
        }
    }

    // Rectangle{
    //     width: parent.height / 10
    //     height: width
    //     radius: height
    //     color: 'red'
    //     anchors.centerIn: parent
        
    // }

    MouseArea
    {
        id: car_image_mouse_id
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true

        onEntered: is_hoverd = true

        onExited: is_hoverd = false

        onPressed:
        {
            // console.log("car_image_mouse_id", "onPressed")
            if (line_drawer.tool_type == 1 && (pressedButtons & Qt.LeftButton))
            {
                event_bus_id.canvasElementPressed(car_image_rect_id.element_id,
                    mouseX / car_image_rect_id.width, mouseY / car_image_rect_id.height)
                mouse.accepted = false
            }
        }
    }

	Connections
    {
        target: event_bus_id

        function onKeyPressed(keyboardCode)
		{
			if (!car_image_rect_id.is_hoverd || line_drawer.tool_type != 1)
			{
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

            var heroCarModel = ScenarioControl.findHeroCarModel()
            heroCarModel.theta = -car_image_rect_id.car_image_rotate / 360 * 2 * Math.PI
            event_bus_id.notifyUpdateHeroCar()
            SimulatorControl.syncSceneToServer();
		}
	}
}