import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2

import COWA.Simulator 1.0

Item {
    id : line_id
    property var line_map: ({})

    property var line_point_collect: []
    property var hero_car_routing_point : []
    property var cursor_point: null
    property int tool_type: 1


    function onPaint(ctx) {
        // draw hero car routing target
        ctx.beginPath()
        ctx.fillStyle = "red"
        for (var i = 0; i < hero_car_routing_point.length; ++i)
        {
            ctx.moveTo(hero_car_routing_point[i].x, hero_car_routing_point[i].y)
            ctx.arc(hero_car_routing_point[i].x, hero_car_routing_point[i].y, 8 / simulation_window_id.canvas_scale, 0, 2 * Math.PI, false)
            // console.log("onPaint", hero_car_routing_point[i].x, hero_car_routing_point[i].y) 
        }
        ctx.fill()
        ctx.closePath()
        // draw line of other obstacle
        for (var key in line_map)
        {   var line = line_map[key].points
            if (line.length == 0) {
                continue
            }
            ctx.beginPath()
            ctx.strokeStyle = "black"
            ctx.lineWidth = 1 / simulation_window_id.canvas_scale
            
            ctx.moveTo(line[0].x, line[0].y)
            for (var j = 1; j < line.length; ++j)
            {
                ctx.lineTo(line[j].x, line[j].y)
            }
            ctx.stroke()
            ctx.closePath()
            
        }

        // draw line which is editing    
        if (line_point_collect.length > 0 && cursor_point != null) {
            // draw line length
            var p = line_point_collect[line_point_collect.length - 1]
            var length_of_line = Math.sqrt((cursor_point.x - p.x)*(cursor_point.x - p.x) + (cursor_point.y - p.y)*(cursor_point.y - p.y))
            length_of_line = length_of_line.toFixed(2)
            if (length_of_line > 0.01) {
                ctx.beginPath()
                ctx.lineWidth = 1
                ctx.fillStyle = "red"
                ctx.font = "1px sans-serif" 
                ctx.fillText(length_of_line, (cursor_point.x + p.x) / 2.0, (cursor_point.y + p.y)/2.0);
                ctx.closePath()
            }

            // draw line
            line_point_collect.push(cursor_point)
            ctx.beginPath()
            if (tool_type == 2)
            {
                ctx.strokeStyle = "grey"
            }
            else if (tool_type == 3)
            {
                ctx.strokeStyle = "orange"
            }
            ctx.lineWidth = 1 / simulation_window_id.canvas_scale
            ctx.moveTo(line_point_collect[0].x, line_point_collect[0].y)
            for (var i = 1; i < line_point_collect.length; i++)
            {
                ctx.lineTo(line_point_collect[i].x, line_point_collect[i].y)
            }
            ctx.stroke()
            ctx.closePath()
            line_point_collect.pop()
        }
    }

    function onDoubleClicked() {
        console.log("line_id onDoubleClicked")
        if (line_point_collect.length > 2) {
            line_point_collect.pop()
            //是每一次收集的画线组，在信号里存入lineArray的集合里，在这里调用control层添加路线
            for (var i = 0; i < line_point_collect.length; ++i)
            {
                line_point_collect[i] = simulation_window_id.noScaleContextPointToRealMap(line_point_collect[i])
            }
            if (tool_type == 2)
            {
                var speed_point_collect = []
                for (var j = 0; j < line_point_collect.length; ++j) { speed_point_collect.push(5.0) }
                ScenarioControl.addObstacleCurveModel(line_point_collect, speed_point_collect)
            }
            else if (tool_type == 3)
            {
                
                ScenarioControl.setHeroRoutingPoints(line_point_collect)
            }
            line_point_collect = []
        }  
    }

    function onClick(mouseX, mouseY) {
        console.log("line_id onPressed")
        var realPoint = simulation_window_id.realMapPointToNoScaleContext(simulation_window_id.canvasPointToRealMap(Qt.point(mouseX, mouseY)));
        line_point_collect.push(realPoint)
    }

    function onPositionChanged(mouseX, mouseY) {
        // console.log("line_id onPositionChanged")
        var realPoint = simulation_window_id.realMapPointToNoScaleContext(simulation_window_id.canvasPointToRealMap(Qt.point(mouseX, mouseY)));
        cursor_point = realPoint
        if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 121")}
        canvas_map.requestPaint()
    }

    Connections
    {
        target: ScenarioControl

        function onNotifyAddCurveModel(id)
        {
            var model = ScenarioControl.findCurveModel(id)
            var points = model.line_curve
            for (var i = 0; i < points.length; ++i)
            {
                points[i] = simulation_window_id.realMapPointToNoScaleContext(points[i])
            }

            line_id.line_map[id] = 
            {
                "element_id": id,
                "points": points
            }
            if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 143")}
            canvas_map.requestPaint()
        }

        function onNotifyDeleteCurveModel(id)
        {
            delete line_id.line_map[id]
            if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 150")}
            canvas_map.requestPaint()
        }

        function onNotifyClear()
        {
            line_point_collect = []
            for (var key in line_id.line_map)
            {
                delete line_id.line_map[key]
            }
            if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 161")}
            canvas_map.requestPaint()
        }

        function onNotifySetHeroRoutingPoints(points) {
            var new_hero_car_routing_point = []
            for (var j = 0; j < points.length; ++j) {
                var canvas_point = simulation_window_id.realMapPointToNoScaleContext(points[j])
                new_hero_car_routing_point.push(canvas_point)
            }
            
             // 比较新旧routing point， 相等不用重新渲染
            var routing_is_equal = true
            if (hero_car_routing_point.length == new_hero_car_routing_point.length) {
                for (var j = 0; j < points.length; ++j) {
                    if (hero_car_routing_point[j].x != new_hero_car_routing_point[j].x ||
                    hero_car_routing_point[j].y != new_hero_car_routing_point[j].y) {
                        routing_is_equal = false
                        break
                    }
                }
            } else {
                routing_is_equal = false
            }
            
            if (!routing_is_equal) {
                hero_car_routing_point = new_hero_car_routing_point
                if (config_id.isDebugLog) { 
                    console.log("canvas_map.requestPaint routing.")
                }
                canvas_map.requestPaint()
            }
        }
    }
}