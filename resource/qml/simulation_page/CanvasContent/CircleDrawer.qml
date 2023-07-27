import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2

import COWA.Simulator 1.0

Item
{
	id : circle_drawer_id
	property var circle_id: 0
    property var circle_collect: []
	property var circle_file: []
    property int tool_type: 1
	property bool left_down: false
	property bool add_finished: false
	property var circle_ids: []
	property var circle_points: []
	property var circle_radius: []

	function onPaint(ctx)
	{
        for (var i = 0; i < circle_collect.length; ++i)
        {
			// 画内圆
			ctx.beginPath()
        	ctx.fillStyle = circle_collect[i].circlePointColor
            ctx.moveTo(circle_collect[i].position.x, circle_collect[i].position.y)
            ctx.arc(circle_collect[i].position.x, circle_collect[i].position.y,
				(5 / simulation_window_id.canvas_scale > circle_collect[i].circleRadius / 10 ?
					circle_collect[i].circleRadius / 10 : 5 / simulation_window_id.canvas_scale), 0, 2 * Math.PI, false)
			ctx.fill()
        	ctx.closePath()

			// 画外圆
			ctx.beginPath()
        	ctx.fillStyle = circle_collect[i].circleColor
            ctx.moveTo(circle_collect[i].position.x, circle_collect[i].position.y)
            ctx.arc(circle_collect[i].position.x, circle_collect[i].position.y,
				circle_collect[i].circleRadius, 0, 2 * Math.PI, false)
			ctx.fill()
        	ctx.closePath()

			// 画id
			ctx.beginPath()
			ctx.fillStyle = circle_collect[i].fontColor
			ctx.font = circle_collect[i].fontStyle
			ctx.fillText(circle_collect[i].id, circle_collect[i].position.x, circle_collect[i].position.y)
			ctx.closePath()
        }

        for (var i = 0; i < circle_file.length; ++i)
        {
			ctx.beginPath()
        	ctx.fillStyle = circle_file[i].circleColor
            ctx.moveTo(circle_file[i].position.x, circle_file[i].position.y)
            ctx.arc(circle_file[i].position.x, circle_file[i].position.y, circle_file[i].circleRadius, 0, 2 * Math.PI, false)
			ctx.fill()
        	ctx.closePath()

			ctx.beginPath()
        	ctx.fillStyle = circle_file[i].circlePointColor
            ctx.moveTo(circle_file[i].position.x, circle_file[i].position.y)
            ctx.arc(circle_file[i].position.x, circle_file[i].position.y,
				(5 / casimulation_window_idvas.canvas_scale > circle_file[i].circleRadius / 10 ?
					circle_file[i].circleRadius / 10 : 5 / simulation_window_id.canvas_scale), 0, 2 * Math.PI, false)
			ctx.fill()
        	ctx.closePath()
        }
    }

	function onPressed(mouseX, mouseY)
	{
		if (!left_down)
		{
			left_down = true
			circle_id++
			var realMapPoint = simulation_window_id.canvasPointToRealMap(Qt.point(mouseX, mouseY))
        	var realPoint = simulation_window_id.realMapPointToNoScaleContext(realMapPoint);
        	setData(circle_id, realPoint, realMapPoint, 0)
		}
    }

	function setData(circle_id, realPoint, realMapPoint, radius)
	{
		circle_collect.push(
		{
			"id":  circle_id,
			"position": realPoint,
			"mapPosition": realMapPoint,
			"circleRadius": radius,
			"circleColor": "rgba(255, 255, 0, 0.5)",
			"circlePointColor": "rgba(255, 255, 0, 0.5)",
			"fontColor": "red",
			"fontStyle": "2px serif",
		})
		circle_ids.push(circle_id)
		circle_points.push(realMapPoint)
		circle_radius.push(radius)
	}

	function onReleased()
	{
		if (left_down)
		{
			left_down = false
			if (circle_collect.length != 1) { return }
			ScenarioControl.copyToBoard(circle_collect[0].mapPosition.x + "," + circle_collect[0].mapPosition.y + "," +
				circle_collect[0].circleRadius)
		}
    }

	function onDoubleClicked() {
        console.log("circle_id onDoubleClicked")
		// console.log("onDoubleClicked: ", circle_collect[0].mapPosition.x + "," + circle_collect[0].mapPosition.y + "," +
		// 		circle_collect[0].circleRadius)
		if (circle_points.length < 1 && circle_radius.length > 1) {return; }
		ScenarioControl.addParkingArea(circle_ids, circle_points, circle_radius)
		event_bus_id.addParkingArea(circle_ids, circle_points, circle_radius)
		add_finished = true
    }

	function onPositionChanged(mouseX, mouseY)
	{
		var last_index = circle_collect.length - 1
		var realPoint = simulation_window_id.realMapPointToNoScaleContext(simulation_window_id.canvasPointToRealMap(Qt.point(mouseX, mouseY)));
		var circleRadius = Math.pow((realPoint.x - circle_collect[last_index].position.x) * (realPoint.x - circle_collect[last_index].position.x) +
			(realPoint.y - circle_collect[last_index].position.y) * (realPoint.y - circle_collect[last_index].position.y), 0.5);
		circle_collect[last_index].circleRadius = circleRadius

		var current_index = circle_radius.length - 1
		circle_radius[current_index] = circleRadius
		canvas_circle.requestPaint()
	}

	function onWheel(scale_value)
	{
		console.log("CircleDrawer: onWheel: ", scale_value)
		// for (var i = 0; i < circle_collect.length; ++i)
        // {
		// 	var circle = circle_collect[i]
		// 	console.log("circle = ", circle)
		// 	var realMapPoint = circle.mapPosition;
		// 	console.log("realMapPoint: ", realMapPoint.x, realMapPoint.y)
        //     var canvasPoint = simulation_window_id.realMapPointToCanvas(Qt.point(realMapPoint.x, realMapPoint.y))
		// 	console.log("canvasPoint: ", canvasPoint.x, canvasPoint.y)
        // }
		canvas_circle.requestPaint()
	}

	function onMove(move_x, move_y)
	{
		console.log("CircleDrawer onMove: ", move_x, move_y)
		canvas_circle.requestPaint()
	}

	Connections
    {
        target: ScenarioControl

		function onNotifySetSimulationTestInfo(id, name, circleInfo)
		{
			if (circleInfo.length % 5 != 0)
			{
				return
			}
			for (var index = 0; index < circleInfo.length;)
			{
				var realPoint = simulation_window_id.realMapPointToNoScaleContext(
					Qt.point(circleInfo[index], circleInfo[index + 1]));
        		circle_file.push(
				{
					"position": realPoint,
					"circleRadius": circleInfo[index + 2],
					"circleColor": circleInfo[index + 3],
					"circlePointColor": circleInfo[index + 4]
				})
				index = index + 5
			}
			if (config_id.isDebugLog) { 
				console.log("canvas_map.requestPaint SetSimulationTestInfo")
			}
			canvas_map.requestPaint()
		}

        function onNotifyClearSimulationTestInfo()
		{
			circle_file = []
			if (config_id.isDebugLog) { 
				console.log("canvas_map.requestPaint ClearSimulationTestInfo")
				}
			canvas_map.requestPaint()
		}

		function onNotifySetParkingArea(ids, points, raduii)
		{
			console.log("onNotifySetParkingArea, id:", ids, "points:", points)
			if (points.length < 1 || ids.length != points.length) { return; }
			circle_ids = []
			circle_points = []
			circle_radius = []
			if (circle_collect.length != points.length) { circle_collect = [] }
			// 比较新旧routing point， 相等不用重新渲染
            var area_is_equal = true
			for (var i = 0; i < points.length; ++i) 
			{
				var canvas_point = simulation_window_id.realMapPointToNoScaleContext(points[i])
				if (circle_collect.length == points.length)
				{
					if ((circle_collect[i].mapPosition.x != points[i].x ||
						circle_collect[i].mapPosition.y != points[i].y)) 
					{
						console.log("update data: ", circle_collect[i])
						area_is_equal = false
						// 更新circle_collect
						circle_collect[i].mapPosition.x = points[i].x
						circle_collect[i].mapPosition.y = points[i].y
						circle_collect[i].position.x = canvas_point.x
						circle_collect[i].position.y = canvas_point.y
						circle_ids[i] = ids[i]
						circle_points[i] = points[i]
						circle_radius = raduii[i]
					}
				}
				else
				{
					console.log("set data")
					area_is_equal = false
					setData(ids[i], canvas_point, points[i], raduii[i])
				}
			}
			circle_id = ids[ids.length - 1]
           
            if (!area_is_equal) {
                if (config_id.isDebugLog) { 
                    console.log("canvas_map.requestPaint routing.")
                }
                canvas_circle.requestPaint()
            }
		}

		function onNotifyDeleteCircleById(id)
		{
			console.log("onNotifyDeleteParkingCircle, id = ", id)
			if (circle_ids.length < 1 || circle_ids.length != circle_points.length) { return; }
			var index = circle_ids.indexOf(id)
			if (index == -1) { return; }
			circle_ids.splice(circle_ids.indexOf(id), 1)
			circle_points.splice(index, 1)
			circle_radius.splice(index, 1)
			circle_collect.splice(index, 1)
			canvas_circle.requestPaint()
		}

		function onNotifyDeleteParkingArea()
		{
			console.log("onNotifyDeleteParkingArea")
			circle_collect = []
			circle_ids = []
			circle_points = []
			circle_radius = []
			canvas_circle.requestPaint()
		}
	}
}