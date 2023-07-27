import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2
import COWA.Simulator 1.0

import COWA.Simulator 1.0

Rectangle
{
    id: light_board_id
    x: 0
    y: 0
    width: 50 * config_id.screenScale
    height: 50 * config_id.screenScale
	//"#00000000"
    color:  Qt.rgba(0,0,0,0)  //(1)
    border.color: "#00000000"

	property var signal_id: ""
	property var model: undefined

	property var uturn_signal_id: undefined
	property var show_uturn : false
	property var uturn_color: TrafficLightModel.GREEN
	property var uturn_remain_time: 0
	property var uturn_total_time: 50

	property var left_signal_id: undefined
	property var show_left : false
	property var left_color: TrafficLightModel.GREEN
	property var left_remain_time: 0
	property var left_total_time: 50

	property var forward_signal_id: undefined
	property var show_forward : false
	property var forward_color: TrafficLightModel.GREEN
	property var forward_remain_time: 0
	property var forward_total_time: 50

	property var right_signal_id: undefined
	property var show_right : false
	property var right_color: TrafficLightModel.GREEN
	property var right_remain_time: 0
	property var right_total_time: 50


    property var forward_id : 1
    property var left_id : 2
    property var right_id : 3
    property var utrun_id : 4


	Image
	{
		id: light_board_background_image_id
		x: 0
		y: 0
		width: parent.width
		height: parent.height
		source: "qrc:///resource/image/simulation_page/light/light_board_background.png"
		opacity: 0.9

		Row {
			x : 20 * config_id.screenScale
			y : 20 * config_id.screenScale
			spacing : 10 * config_id.screenScale

			Column {
				visible : light_board_id.show_left
				Image
				{
					width: 50 * config_id.screenScale
					height: 50 * config_id.screenScale
					source: left_color == TrafficLightModel.RED ? "qrc:///resource/image/simulation_page/light/left_red.png" :
						left_color == TrafficLightModel.GREEN ? "qrc:///resource/image/simulation_page/light/left_green.png" :
						left_color == TrafficLightModel.YELLOW ? "qrc:///resource/image/simulation_page/light/left_yellow.png" :
						left_color == TrafficLightModel.BLACK ? "qrc:///resource/image/simulation_page/light/left_black.png" :
						"qrc:///resource/image/simulation_page/light/left_unknown.png"

					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						onClicked: {
						}
					}
				}

				Text
				{
					id: light_image_left_remain_time_text_id
					width: light_image_uturn_remain_time_text_id.width
					height: light_image_uturn_remain_time_text_id.height
					text: qsTr(left_remain_time.toString())
					color: "#000000"
					font.pixelSize: 12 * config_id.screenScale
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}

			Column {
				visible : light_board_id.show_forward
				Image
				{
					width: 50 * config_id.screenScale
					height: 50 * config_id.screenScale
					source: forward_color == TrafficLightModel.RED ? "qrc:///resource/image/simulation_page/light/forward_red.png" :
						forward_color == TrafficLightModel.GREEN ? "qrc:///resource/image/simulation_page/light/forward_green.png" :
						forward_color == TrafficLightModel.YELLOW ? "qrc:///resource/image/simulation_page/light/forward_yellow.png" :
						forward_color == TrafficLightModel.BLACK ? "qrc:///resource/image/simulation_page/light/forward_black.png" :
						"qrc:///resource/image/simulation_page/light/forward_unknown.png"	
					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						onClicked: {
						}
					}
				}

				Text
				{
					id: light_image_forward_remain_time_text_id
					width: light_image_uturn_remain_time_text_id.width
					height: light_image_uturn_remain_time_text_id.height
					text: qsTr(forward_remain_time.toString())
					color: "#000000"
					font.pixelSize: 12 * config_id.screenScale
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}

			Column {
				visible : light_board_id.show_right
				Image
				{
					width: 50 * config_id.screenScale
					height: 50 * config_id.screenScale
					source: right_color == TrafficLightModel.RED ? "qrc:///resource/image/simulation_page/light/right_red.png" :
						right_color == TrafficLightModel.GREEN ? "qrc:///resource/image/simulation_page/light/right_green.png" :
						right_color == TrafficLightModel.YELLOW ? "qrc:///resource/image/simulation_page/light/right_yellow.png" :
						right_color == TrafficLightModel.BLACK ? "qrc:///resource/image/simulation_page/light/right_black.png" :
						"qrc:///resource/image/simulation_page/light/right_unknown.png"	
					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						onClicked: {
						}
					}
				}

				Text
				{
					id: light_image_right_remain_time_text_id
					width: light_image_uturn_remain_time_text_id.width
					height: light_image_uturn_remain_time_text_id.height
					text: qsTr(right_remain_time.toString())
					color: "#000000"
					font.pixelSize: 12 * config_id.screenScale
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}

			Column {
				visible : light_board_id.show_uturn
				Image
				{
					width: 50 * config_id.screenScale
					height: 50 * config_id.screenScale
					source: uturn_color == TrafficLightModel.RED ? "qrc:///resource/image/simulation_page/light/uturn_red.png" :
						uturn_color == TrafficLightModel.GREEN ? "qrc:///resource/image/simulation_page/light/uturn_green.png" :
						uturn_color == TrafficLightModel.YELLOW ? "qrc:///resource/image/simulation_page/light/uturn_yellow.png" :
						uturn_color == TrafficLightModel.BLACK ? "qrc:///resource/image/simulation_page/light/uturn_black.png" :
						"qrc:///resource/image/simulation_page/light/uturn_unknown.png"	
					MouseArea {
						anchors.fill: parent
						hoverEnabled: true
						onClicked: {

						}
					}
				}

				Text
				{
					id: light_image_uturn_remain_time_text_id
					width: 60 * config_id.screenScale
					height: 30 * config_id.screenScale
					text: qsTr(uturn_remain_time.toString())
					color: "#000000"
					font.pixelSize: 12 * config_id.screenScale
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}
		}
	}

	Component.onCompleted:
    {
		light_board_id.uturn_signal_id = undefined
		light_board_id.left_signal_id = undefined
		light_board_id.forward_signal_id = undefined
		light_board_id.right_signal_id = undefined
		console.log("signal_id Component.onCompleted: ")
    }

	onModelChanged : {
		light_board_id.uturn_signal_id = undefined
		light_board_id.show_uturn = false
		light_board_id.left_signal_id = undefined
		light_board_id.show_left = false
		light_board_id.forward_signal_id = undefined
		light_board_id.show_forward = false
		light_board_id.right_signal_id = undefined
		light_board_id.show_right = false

		if (model != undefined) {
			console.log("signal_id ", signal_id, "model.sublights length, " , model.sublights.length)
			for (var i = 0; i < model.sublights.length; ++i) {
				var sublight = model.sublights[i]
				console.log("sublight id ", sublight.id, " sublight.type ", sublight.type, " sublight.color ",sublight.color)
				if (sublight.id == forward_id) {
					light_board_id.forward_signal_id = sublight.id
					light_board_id.show_forward = true
					light_board_id.forward_color = sublight.color
				} else if (sublight.id == left_id) {
					light_board_id.left_signal_id = sublight.id
					light_board_id.show_left = true
					light_board_id.left_color = sublight.color
				} else if (sublight.id == right_id) {
					light_board_id.right_signal_id = sublight.id
					light_board_id.show_right = true
					light_board_id.right_color = sublight.color
				} else if (sublight.id == utrun_id) {
					light_board_id.uturn_signal_id = sublight.id
					light_board_id.show_uturn = true
					light_board_id.uturn_color = sublight.color
				}
			}
		}
	}
	
}