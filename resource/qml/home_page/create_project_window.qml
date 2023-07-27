import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2
import QtQuick 2.9
import QtQuick.Shapes 1.9

Item
{
    id: create_project_window_id

	Rectangle
    {
        id: create_project_window_layer_id
        x: create_project_window_title_id.x
		y: create_project_window_title_id.radius
        width: parent.width
		height: create_project_window_title_id.height - create_project_window_title_id.radius
        color: create_project_window_title_id.color
	}

	Rectangle
    {
        id: create_project_window_title_id
        x: 0
		y: 0
        width: parent.width
		height: 56 * config_id.screenScale
		radius: 12 * config_id.screenScale
        color: "#8CA2AA"

		Text
    	{
    	    id: create_project_window_title_text_id
    	    x: 33 * config_id.screenScale
    	    y: 0 * config_id.screenScale
    	    width: parent.width - create_project_window_title_text_id.x
    	    height: parent.height
    	    text: qsTr("仿真工程")
    	    font.styleName: "Regular"
    	    font.pixelSize: 12 * config_id.screenScale
    	    color: "#EDF1F2"
    	    horizontalAlignment: Text.AlignLeft
    	    verticalAlignment: Text.AlignVCenter
    	}
	}

	Rectangle
    {
        id: create_project_window_confirm_button_id
        x: 496 * config_id.screenScale
		y: 344 * config_id.screenScale
        width: 80 * config_id.screenScale
		height: 40 * config_id.screenScale
		radius: 6
		border.color: "#BBBBBB"
        color: "#3291F8"

		Text
    	{
    	    id: create_project_window_confirm_button_text_id
    	    x: 0
    	    y: 0
    	    width: parent.width
    	    height: parent.height
    	    text: qsTr("确认")
    	    font.styleName: "Regular"
    	    font.pixelSize: 14 * config_id.screenScale
    	    color: "#EDF1F2"
    	    horizontalAlignment: Text.AlignHCenter
    	    verticalAlignment: Text.AlignVCenter
    	}

		MouseArea
        {
            anchors.fill: parent
            onClicked:
            {
				UICreateProjectWindowHandle.qmlSignalCreateProject()
            }
        }
	}

	Rectangle
    {
        id: create_project_window_cancel_button_id
        x: 397 * config_id.screenScale
		y: create_project_window_confirm_button_id.y
        width: create_project_window_confirm_button_id.width
		height: create_project_window_confirm_button_id.height
		radius: 6
		border.color: "#BBBBBB"
        color: "#FFFFFF"

		Text
    	{
    	    id: create_project_window_cancel_button_text_id
    	    x: 0
    	    y: 0
    	    width: parent.width
    	    height: parent.height
    	    text: qsTr("取消")
    	    font.styleName: "Regular"
    	    font.pixelSize: 14
    	    color: "#101010"
    	    horizontalAlignment: Text.AlignHCenter
    	    verticalAlignment: Text.AlignVCenter
    	}

		MouseArea
        {
            anchors.fill: parent
            onClicked:
            {
				UICreateProjectWindowHandle.qmlSignalHideCreateProjectWindow()
            }
        }
	}

}