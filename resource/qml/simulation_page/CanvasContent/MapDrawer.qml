import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2

import COWA.Simulator 1.0
import "qrc:/resource/qml/config"


Item {
    id : map_id

    property var min_visible_x : simulation_window_id.canvas_scale > 15 ? -simulation_window_id.width*4 :  0
    property var max_visible_x : simulation_window_id.canvas_scale > 15 ? simulation_window_id.width*5 : simulation_window_id.width
    property var min_visible_y : simulation_window_id.canvas_scale > 15 ? -simulation_window_id.height*4 :  0
    property var max_visible_y : simulation_window_id.canvas_scale > 15 ? simulation_window_id.height*5 : simulation_window_id.height

    property int enum_CITY_DRIVING : 2
    property int enum_BIKING : 3
    property int enum_SIDEWALK : 4
    property int enum_WAITINGAREA : 5
    property int enum_HYBRID : 6
    property int enum_PARKING : 7
    // property int enum_EMERGENCY_LINE : 8
    // property int enum_LANE_MARK : 9
    property int enum_BUS : 9

    property var xmapmin: 0
    property var ymapmin: 0
    property var xmapmax: 0
    property var ymapmax: 0


    property int sample_rate : 1

    property var lane_visible_flag : []
    property var lane_strip_visible_flag : []
    property var object_visible_flag : []
    property var ramp_visible_flag : []
    property var crossroad_visible_flag: []
    property var crosswalk_visible_flag: []

    property var lane_id: []
    property var lane_type: []  // 车道类型
    property var lane_polygons: []
    property var lane_mark_polygons: []
    property var lane_strips: []
    property var left_lane: []
    property var right_lane: []

    property var signals_id : []
    property var signals_stop_line: []

    property var crosswalksid: []
    property var crosswalks: []
    property var crossroadsid: []
    property var crossroads: []
    property var rampsid: []
    property var ramps: []
    property var spObjects: []

    property var is_receive_map: false


    property var light_map: ({}) // signal line
    property var light_elements_map: ({}) // signal map
    property var light_board_elements_map: ({}) // board map

    property var mid_pos: []
    property var coveragePaths: []
    property var debugPoints: []

    HdMapType {
        id: hd_map_type
    }

    function clear() {
        for (var key in light_elements_map) {
            delete light_elements_map[key]
        }
        for (var key in light_board_elements_map) {
            delete light_board_elements_map[key]
        }
    }

    function onPaint(ctx) {
        var scope_x = (map_id.xmapmax - map_id.xmapmin) / simulation_window_id.canvas_scale
        var scope_y = (map_id.ymapmax - map_id.ymapmin) / simulation_window_id.canvas_scale

        if (scope_x < 1500 || scope_y < 1500) {
            map_id.sample_rate = 1
        } else {
         map_id.sample_rate = parseInt((scope_x / 1500) * (scope_y / 1500))
        }

        if (config_id.isDebugLog) {
            console.log("map_drawer on paint ", simulation_window_id.canvas_scale, ", scope: ",scope_x, scope_y, ", sample_rate:" , map_id.sample_rate)
        }
        
        var will_keep_road =  scope_x < 5000 && scope_y < 5000
        if (will_keep_road) {
            drawPolygon(ctx, lane_polygons, lane_id, lane_type)
        }

        drawLane(ctx, left_lane)
        drawLane(ctx, right_lane)

        var will_keep_lanemark =  scope_x < 5000 && scope_y < 5000
        if (will_keep_lanemark) {
            drawPolygonByLaneMark(ctx, lane_mark_polygons, "#ffffff")
        }

        if (simulation_window_id.show_CROSSROAD) {
            draw2dPolygon(ctx, crossroads, crossroad_visible_flag, "rgba(24, 111, 240, 0.3)")
            var need_draw_id =  scope_x < 1000 && scope_y < 1000
            if (need_draw_id) {
                drawId(ctx, crossroads, crossroadsid, crossroad_visible_flag)
            }
        }

        var will_keep_ramp =  scope_x < 2000 && scope_y < 2000
        if (will_keep_ramp && simulation_window_id.show_RAMP) {
            drawLine(ctx, ramps, "#660033", ramp_visible_flag)
            var need_draw_id =  scope_x < 1000 && scope_y < 1000
            if (need_draw_id) {
                drawId(ctx, ramps, rampsid, ramp_visible_flag)
            }
        }
        var will_keep_strip =  scope_x < 5000 && scope_y < 5000
        if (will_keep_strip && simulation_window_id.show_STRIP) {
            drawLaneStrip(ctx, lane_strips, "#0066cc")
        }

        var will_keep_some_unused =  scope_x < 3000 && scope_y < 3000
        if (will_keep_some_unused) {
            drawSignalsLine(ctx, "red")
        }

        var will_keep_crosswalk =  scope_x < 5000 && scope_y < 5000
        if (will_keep_crosswalk && simulation_window_id.show_CROSSWALK) {
            draw2dPolygon(ctx, crosswalks, crosswalk_visible_flag, "rgba(223, 244, 255, 0.7)")
            var need_draw_id =  scope_x < 1000 && scope_y < 1000
            if (need_draw_id) {
                drawId(ctx, crosswalks, crosswalksid, crosswalk_visible_flag)
            }
        }

        var need_draw_object =  scope_x < 2500 && scope_y < 2500
        if (need_draw_object && simulation_window_id.show_OBJECT) {
            draw2dPolygon(ctx, spObjects, object_visible_flag, "#9400D3")
        }
        // to do
        var need_draw_laneid =  scope_x < 500 && scope_y < 500
        if (need_draw_laneid && simulation_window_id.show_all_lane_id) {
            drawLaneLabel(ctx, left_lane, right_lane)
        }

        // highlight points
        if (simulation_window_id.hightlight_point && simulation_window_id.highlight_points.length > 0) {
            var x = simulation_window_id.highlight_points[0]
            var y = simulation_window_id.highlight_points[1]
                        // console.log("drawPointHighlight", x, y)
            drawPointHighlight(ctx, x, y, "yellow")
        }

        drawCoveragePath(ctx, coveragePaths, "rgb(255, 0, 0)", "rgb(0, 0, 255)");
        drawDebugPoint(ctx, debugPoints);
    }

    function onMove(move_x, move_y) {
        for (var key in light_elements_map)
        {
            light_elements_map[key].x += move_x
            light_elements_map[key].y += move_y
        }
        for (var key in light_board_elements_map)
        {
            light_board_elements_map[key].x += move_x
            light_board_elements_map[key].y += move_y
        }
        setVisisbleFlags()
    }

    function onWheel(scale_value) {
        for (var key in light_elements_map)
        {
            var element = light_elements_map[key]
            var canvasPoint = simulation_window_id.realMapPointToCanvas(Qt.point(element.map_x, element.map_y))
            element.x = canvasPoint.x
            element.y = canvasPoint.y
            element.width = element.width * scale_value
            element.height = element.height * scale_value
        }
        for (var key in light_board_elements_map) {
            var light = light_elements_map[key]
            var element = light_board_elements_map[key]
            element.x = light.x + light.width/2 - element.width/2
            element.y = light.y - element.height - 3

            // console.log("onWheel light_board_elements_map ", element.x, element.y)
        }
        setVisisbleFlags()
    }

    function onHideAllLightBoard() {
         for (var key in light_board_elements_map) {
            var element = light_board_elements_map[key]
            element.visible = false
        }
    }

    function drawLine(ctx, lines, target_color, visibleFlags) {
        if (visibleFlags != undefined && visibleFlags.length != 0 && visibleFlags.length != lines.length) {
            return;
        }
        for(var i = 0; i < lines.length; ++i) {
            var line = lines[i];
            if(line.length <= 0) {
                continue;
            }
            if (visibleFlags.length > 0 && visibleFlags[i] == false) {
                continue
            }
            ctx.beginPath();
            ctx.strokeStyle = target_color;
            ctx.fillStyle = target_color;
            ctx.lineWidth = config_id.screenScale * 4 / simulation_window_id.canvas_scale
            ctx.moveTo(line[0][0], line[0][1]);
            for(var j = 0; j < line.length; ++j) {
                ctx.lineTo(line[j][0], line[j][1]);
            }
            ctx.stroke()
            // ctx.fill()
            ctx.closePath();
        }
    }

    function drawLane(ctx, lanes) {
        for (var i = 0; i < lanes.length; ++i)
        {   
            if (!lane_visible_flag[i]) continue;
            var line = lanes[i]
            var is_reality = line[0]
            ctx.beginPath()
            if (is_reality === false) {
                ctx.strokeStyle = 'rgb(160,160,160)'
                ctx.lineWidth = config_id.screenScale / simulation_window_id.canvas_scale
            } else {
                ctx.strokeStyle = "white"
                ctx.lineWidth = config_id.screenScale * 2 / simulation_window_id.canvas_scale
            }
            var target_color = ctx.strokeStyle
            var line_width = ctx.lineWidth

            ctx.moveTo(line[1][0], line[1][1])
            // var step = Math.min(sample_rate, line.length - 1)
            var step = 1
            for (var j = 2; j < line.length; j = j + step)
            {
                if(simulation_window_id.show_CURB && line[j][2] === HdMapType.LanePointType.CURB) {
                    ctx.strokeStyle = "#FFA07A"
                    ctx.lineWidth = config_id.screenScale * 3 / simulation_window_id.canvas_scale
                } else {
                    ctx.strokeStyle = target_color
                    ctx.lineWidth = line_width
                }
                ctx.lineTo(line[j][0], line[j][1])
            }
            ctx.stroke()
            ctx.closePath()
        }
    }

    function drawLaneLabel(ctx, left_lane, right_lane) {
        ctx.beginPath()
        ctx.lineWidth = config_id.screenScale
        ctx.fillStyle = "red"
        ctx.font = "1px sans-serif"
        // console.log(map_id.right_mid_pos.length)

        if(map_id.mid_pos != undefined && map_id.mid_pos.length > 0) {
            for(var i = 0; i < map_id.mid_pos.length; ++i) {
                if (!lane_visible_flag[i]) {
                    continue;
                }
                var mid_pos_ = map_id.mid_pos[i]
                ctx.fillText(lane_id[i], mid_pos_.x, mid_pos_.y);
            }
        }
        ctx.closePath()
    }

    function drawPolygon(ctx, lane_polygons, lane_ids, lane_types)
    {
        if (simulation_window_id.show_BIKING) {
            drawPolygonByLaneType(ctx, lane_polygons, lane_ids, lane_types, enum_BIKING, "#8ca2aa")
        }
        if (simulation_window_id.show_CITY_DRIVING) {
            drawPolygonByLaneType(ctx, lane_polygons, lane_ids, lane_types, enum_CITY_DRIVING, "#505559")
        }
        if (simulation_window_id.show_SIDEWALK) {
            drawPolygonByLaneType(ctx, lane_polygons, lane_ids, lane_types, enum_SIDEWALK, "#bdbdbd")
        }
        if (simulation_window_id.show_WAITINGAREA) {
            drawPolygonByLaneType(ctx, lane_polygons, lane_ids, lane_types, enum_WAITINGAREA, "rgba(255, 255, 200, 0.5)")
        }
        if (simulation_window_id.show_HYBRID) {
            drawPolygonByLaneType(ctx, lane_polygons, lane_ids, lane_types, enum_HYBRID, "#7FFFD4")
        }
        // if (simulation_window_id.show_PARKING) {
        //     drawPolygonByLaneType(ctx, lane_polygons, lane_ids, lane_types, enum_PARKING, "#2F4F4F")
        // }
        if (simulation_window_id.show_BUS) {
            drawPolygonByLaneType(ctx, lane_polygons, lane_ids, lane_types, enum_BUS, "#2F4F4F")
        }
        
        // highlight road
        if (simulation_window_id.hightlight_one_road && simulation_window_id.highlight_road !=="") {
            simulation_window_id.highlight_road
            drawPolygonHighlight(ctx, lane_polygons, lane_ids, simulation_window_id.highlight_road, "yellow")
        }
    }

    function drawPolygonByLaneType(ctx, lane_polygons, lane_id, lane_type, target_type, target_color) {
        for (var i = 0; i < lane_polygons.length; ++i)
        {
            if (!lane_visible_flag[i]) {
                continue;
            }
            var polygon = lane_polygons[i]
            if (lane_type[i] != target_type){ // 机动车 最后再画，避免被覆盖
                continue
            }
            ctx.beginPath()
            ctx.fillStyle = target_color; 
            ctx.lineWidth = config_id.screenScale / simulation_window_id.canvas_scale
            ctx.moveTo(polygon[0][0], polygon[0][1])
            for (var j = 1; j < polygon.length; j = j + 1)
            {
                ctx.lineTo(polygon[j][0], polygon[j][1])
            }
            ctx.fill(); //多边形填充
            ctx.closePath()
        }
    }

    function drawPolygonByLaneMark(ctx, lane_mark_polygons, target_color) {
        if(!simulation_window_id.show_LANE_MARK) {
            return;
        }
        for(var lane_index = 0; lane_index < lane_mark_polygons.length; ++lane_index) {
            if (!lane_visible_flag[lane_index]) {
                continue;
            }
            var polygons_for_lane = lane_mark_polygons[lane_index];
            if(polygons_for_lane.length <= 0) {
                continue;
            }
            for (var i = 0; i < polygons_for_lane.length; ++i) {
                var polygon = polygons_for_lane[i]
                ctx.beginPath();
                ctx.fillStyle = target_color;
                ctx.lineWidth = config_id.screenScale / simulation_window_id.canvas_scale;
                ctx.moveTo(polygon[0][0], polygon[0][1]);
                for(var j = 1; j < polygon.length; j = j + 1) {
                    ctx.lineTo(polygon[j][0], polygon[j][1]);
                }
                ctx.fill(); //多边形填充
                ctx.closePath();
            }
            // console.log("land mark polygon-----------")
        }
    }

    function drawPolygonHighlight(ctx, lane_polygons, lane_id, target_id, target_color) {
        for (var i = 0; i < lane_id.length; ++i)
        {
            if (lane_id[i] != target_id){ // 机动车 最后再画，避免被覆盖
                continue
            }
            var polygon = lane_polygons[i]
            ctx.beginPath()
            ctx.fillStyle = target_color; 
            ctx.lineWidth = config_id.screenScale / simulation_window_id.canvas_scale
            ctx.moveTo(polygon[0][0], polygon[0][1])
            for (var j = 1; j < polygon.length; j = j + sample_rate)
            {
                ctx.lineTo(polygon[j][0], polygon[j][1])
            }
            ctx.fill(); //多边形填充
            ctx.closePath()
        }
    }

    function drawPointHighlight(ctx, x, y, target_color) {
        ctx.beginPath()
        ctx.fillStyle = target_color; 
        ctx.lineWidth = config_id.screenScale / simulation_window_id.canvas_scale
        ctx.moveTo(x, y)
        var pointRadius = config_id.screenScale * 6 / simulation_window_id.canvas_scale
        ctx.arc(x, y, pointRadius, 0 * Math.PI / 180, 359 * Math.PI / 180,  false)
        ctx.fill(); //填充
        ctx.closePath()
    }

    function drawSignalsLine(ctx, signalsColor)
    {
        for (var i = 0; i < signals_stop_line.length; ++i)
        {
            var line = signals_stop_line[i]
            if (line.length < 4){
                console.log("----------stopline should contains 2 points")
                continue
            }
            // console.log("----------drawSignalsLine", line[0], line[1])
            ctx.beginPath()
            ctx.fillStyle = signalsColor
            ctx.strokeStyle = signalsColor
            ctx.lineWidth = config_id.screenScale / simulation_window_id.canvas_scale
            var lightRadius = 4 / simulation_window_id.canvas_scale
            ctx.moveTo(line[0], line[1])
            ctx.lineTo(line[line.length-2], line[line.length-1])
            ctx.stroke()
            ctx.closePath()
        }
    }

    function drawLaneStrip(ctx, lane_strips, target_color) {
        for(var lane_index = 0; lane_index < lane_strips.length; ++lane_index) {
            var lane_strip_for_lane = lane_strips[lane_index]
            if(lane_strip_for_lane.length <= 0) {
                continue;
            }
            if (lane_strip_visible_flag[lane_index] == false) {
                continue;
            }
            
            for (var i = 0; i < lane_strip_for_lane.length; ++i) {
                var lane_strip = lane_strip_for_lane[i];
                if (lane_strip.length <= 0) {
                    continue;
                }
                ctx.beginPath();
                ctx.strokeStyle = target_color;
                ctx.lineWidth = config_id.screenScale * 2 / simulation_window_id.canvas_scale;
                ctx.moveTo(lane_strip[0][0], lane_strip[0][1]);
                var step = Math.min(sample_rate, lane_strip.length - 1)
                for(var j = 1; j < lane_strip.length; j = j + step) {
                    ctx.lineTo(lane_strip[j][0], lane_strip[j][1]);
                }
                ctx.stroke()
                ctx.closePath();
            }
        }
    }

    function draw2dPolygon(ctx, crosses, visibleFlags, target_color) {

        if (visibleFlags != undefined && visibleFlags.length != 0 && visibleFlags.length != crosses.length) {
            return;
        }
        for(var i = 0; i < crosses.length; ++i) {
            var cross = crosses[i];
            if(cross.length <= 0) {
                continue;
            }
            if (visibleFlags.length > 0 && visibleFlags[i] == false) {
                continue
            }
            ctx.beginPath();
            ctx.fillStyle = target_color;
            ctx.lineWith = 6 / simulation_window_id.canvas_scale;
            ctx.moveTo(cross[0][0], cross[0][1]);
            for(var j = 0; j < cross.length; ++j) {
                ctx.lineTo(cross[j][0], cross[j][1]);
            }
            ctx.fill();
            ctx.closePath();
        }
    }

    function drawId(ctx, crosses, ids, visibleFlags) {
        if (visibleFlags != undefined && visibleFlags.length != 0 && visibleFlags.length != crosses.length) {
            return;
        }
        for(var i = 0; i < crosses.length; ++i) {
            var cross = crosses[i];
            if(cross.length <= 0) {
                continue;
            }
            if (visibleFlags.length > 0 && visibleFlags[i] == false) {
                continue
            }
            ctx.beginPath()
            ctx.fillStyle = "red"
            ctx.font = "2px sans-serif"
            ctx.fillText(ids[i], cross[0][0], cross[0][1]);
            ctx.closePath()
        }
    }

    function drawCoveragePath(ctx, coverage_paths, first_color, second_color) {
        for(var i = 0; i < coverage_paths.length; ++i) {
            var coverage_path = coverage_paths[i];
            ctx.beginPath();
            if(i % 2 === 0) {
                // 画start
                ctx.fillStyle = first_color;
            } else {
                // 画end
                ctx.fillStyle = second_color;
            }
            ctx.lineWidth = config_id.screenScale / simulation_window_id.canvas_scale
            var pointRadius = config_id.screenScale * 4 / simulation_window_id.canvas_scale
            ctx.moveTo(coverage_path[0],coverage_path[1])
            ctx.arc(coverage_path[0],coverage_path[1], pointRadius, 0 * Math.PI / 180, 2 * Math.PI, false);
            ctx.fill();
            ctx.closePath();
        }
    }

    function drawDebugPoint(ctx, debugpoints) {
        
        for(var i = 0; i < debugpoints.length; ++i) {
            var point = debugpoints[i];
            ctx.beginPath();
            ctx.fillStyle = "rgb(255, 0, 0)";
            ctx.lineWidth = config_id.screenScale / simulation_window_id.canvas_scale
            var pointRadius = config_id.screenScale * 4 / simulation_window_id.canvas_scale
            ctx.moveTo(point[0],point[1])
            ctx.arc(point[0],point[1], pointRadius, 0 * Math.PI / 180, 2 * Math.PI, false);
            ctx.fill();
            ctx.closePath();
        }
        
    }

    // 判断点是否在地图范围内
    function isPointVisible(x, y) {
        var p_b = Qt.point(x, y)
        p_b = simulation_window_id.noScaleContextPointToCanvas(p_b)
        if (!isPointInVisibleArea(p_b.x, p_b.y)) {
            return false;
        } else {
            return true;
        }
    }

    function addLightElement(element_id, x, y, width, height, image_url, rotate)
    {
        if (light_elements_map[element_id] != undefined)
        {
            return
        }

        var component = Qt.createComponent("qrc:///resource/qml/simulation_page/element.qml")
        if (component.status === Component.Ready)
        {
            var map_point = simulation_window_id.canvasPointToRealMap(Qt.point(x,y))
            var element = component.createObject(canvas_map, 
            {
                "x": x,
                "y": y,
                "map_x" : map_point.x,
                "map_y" : map_point.y,
                "width": width,
                "height": height,
                "car_image_source": image_url,
                "car_image_rotate": rotate,
                "element_id": element_id,
                "type":"light",
            })
            light_elements_map[element_id] = element
        }
    }
    

    function addLightBoard(light_id, model, x, y, width, height)
    {
        console.log("addLightBoard1", light_id)
        var component = Qt.createComponent("qrc:///resource/qml/simulation_page/TrafficLight/LightBoard.qml")
        console.log("addLightBoard2", light_id)
        if (component.status === Component.Ready)
        {
            console.log("light_id=", light_id)
            var map_point = simulation_window_id.canvasPointToRealMap(Qt.point(x,y))
            var element = component.createObject(canvas_map,
            {
                "x": x,
                "y": y,
                "map_x" : map_point.x,
                "map_y" : map_point.y,
                "width" : width,
                "height": height,
                "signal_id": light_id,
                "model" : model,
            })
            light_board_elements_map[light_id] = element
        }
        console.log("addLightBoard3", light_id)
    }

    function isPointInVisibleArea(x, y) {
        return x > min_visible_x && x < max_visible_x && y > min_visible_y && y < max_visible_y
    }

    function setVisisbleFlags() {
        // 判断车道是否可见
        var visible_line = 0;
        var non_visible_line = 0;
        for (var i = 0; i < lane_visible_flag.length; ++i)
        {   
            var line = left_lane[i]
            var p_b = Qt.point(line[1][0], line[1][1])
            var p_e = Qt.point(line[line.length - 1][0], line[line.length - 1][1])
            var p_m = Qt.point((line[1][0] + line[line.length - 1][0]) / 2.0, (line[1][1] + line[line.length - 1][1]) / 2.0)

            p_b = simulation_window_id.noScaleContextPointToCanvas(p_b)
            p_e = simulation_window_id.noScaleContextPointToCanvas(p_e)
            p_m = simulation_window_id.noScaleContextPointToCanvas(p_m)

            // console.log("drawLane1 ", p_b.x, p_b.y,  p_e.x, p_e.y)
            if (!isPointInVisibleArea(p_b.x, p_b.y) && !isPointInVisibleArea(p_e.x, p_e.y) && !isPointInVisibleArea(p_m.x, p_m.y)) {
                non_visible_line = non_visible_line + 1
                lane_visible_flag[i] = false
            } else {
                visible_line = visible_line + 1
                lane_visible_flag[i] = true
            }
        }
        // console.log("visible_line ", visible_line, "non_visible_line",  non_visible_line)
        // 判断Object是否可见
        for (var i = 0; i < object_visible_flag.length; ++i)
        {   
            var polygon = spObjects[i]
            if (polygon.length == 0) {
                object_visible_flag[i] = false
                continue
            }
            var p_b = Qt.point(polygon[0][0], polygon[0][1])
            p_b = simulation_window_id.noScaleContextPointToCanvas(p_b)
            // console.log("drawLane1 ", p_b.x, p_b.y)
            if (!isPointInVisibleArea(p_b.x, p_b.y) ) {
                object_visible_flag[i] = false
            } else {
                object_visible_flag[i] = true
            }
        }

        // 判断lane strip是否可见
        for(var lane_index = 0; lane_index < lane_strips.length; ++lane_index) {
            var lane_strip_for_lane = lane_strips[lane_index]
            if(lane_strip_for_lane.length <= 0) {
                lane_strip_visible_flag[lane_index] = false
                continue;
            }
            var lane_strip = lane_strip_for_lane[0];
            if (lane_strip.length == 0) {
                lane_strip_visible_flag[lane_index] = false
                continue;
            }
            var p_b = Qt.point(lane_strip[0][0], lane_strip[0][1])
            // console.log("lane_strip_visible_flag ", p_b.x, p_b.y)
            p_b = simulation_window_id.noScaleContextPointToCanvas(p_b)
            if (!isPointInVisibleArea(p_b.x, p_b.y) ) {
                lane_strip_visible_flag[lane_index] = false
            } else {
                lane_strip_visible_flag[lane_index] = true
            }
        }

        // 判断ramp是否可见
        for (var i = 0; i < ramps.length; ++i) {
            var ramp_for_lane = ramps[i]
            if(ramp_for_lane.length <= 0) {
                ramp_visible_flag[i] = false
                continue;
            }
            var ramp = ramp_for_lane[0];
            if (ramp.length == 0) {
                ramp_visible_flag[i] = false
                continue;
            }
            var p_b = Qt.point(ramp[0], ramp[1])
            p_b = simulation_window_id.noScaleContextPointToCanvas(p_b)
            if (!isPointInVisibleArea(p_b.x, p_b.y) ) {
                ramp_visible_flag[i] = false
            } else {
                ramp_visible_flag[i] = true
            }
        }

        // 判断Crossroad是否可见
        for(var lane_index = 0; lane_index < crossroads.length; ++lane_index) {
            var crossroad_for_lane = crossroads[lane_index] 
            if(crossroad_for_lane.length <= 0) {
                crossroad_visible_flag[lane_index] = false
                continue;
            }
            var crossroad = crossroad_for_lane[0];
            if (crossroad.length == 0) {
                crossroad_visible_flag[lane_index] = false
                continue;
            }
            var p_b = Qt.point(crossroad[0], crossroad[1])
            p_b = simulation_window_id.noScaleContextPointToCanvas(p_b)
            if (!isPointInVisibleArea(p_b.x, p_b.y) ) {
                crossroad_visible_flag[lane_index] = false
            } else {
                crossroad_visible_flag[lane_index] = true
            }
        }
        // 判断crosswalks是否可见
        for(var index = 0; index < crosswalks.length; ++index) {
            var crosswalk_for_lane = crosswalks[index] 
            if(crosswalk_for_lane.length <= 0) {
                crosswalk_visible_flag[index] = false
                continue;
            }
            var crosswalk = crosswalk_for_lane[0];
            if (crosswalk.length == 0) {
                crosswalk_visible_flag[index] = false
                continue;
            }
            var p_b = Qt.point(crosswalk[0], crosswalk[1])
            p_b = simulation_window_id.noScaleContextPointToCanvas(p_b)
            if (!isPointInVisibleArea(p_b.x, p_b.y) ) {
                crosswalk_visible_flag[index] = false
            } else {
                crosswalk_visible_flag[index] = true
            }
        }

        
    }

    Connections
    {
        target: SimulatorControl
        function onNotifyMap(lane_id, 
                            lane_polygons, 
                            lane_mark_polygons, 
                            lane_strips, 
                            lane_type,
                            left_lane, 
                            right_lane, 
                            signals_id, 
                            signals_stop_line, 
                            crosswalksid, 
                            crosswalks, 
                            crossroadsid, 
                            crossroads, 
                            rampsid, 
                            ramps, 
                            spObjects,
                            x_min, y_min, x_max, y_max)
        {
            console.log("time0.0:" + Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss.zzz ddd"))
            map_id.lane_visible_flag = []
            for (var i = 0; i < left_lane.length; ++i){
                map_id.lane_visible_flag.push(true)
            }

            map_id.xmapmin = x_min
            map_id.ymapmin = y_min
            map_id.xmapmax = x_max
            map_id.ymapmax = y_max
            //console.log(xmapmin, ymapmin)
            map_id.lane_id = lane_id
            map_id.lane_type = lane_type
            map_id.lane_polygons = lane_polygons
            map_id.lane_mark_polygons = lane_mark_polygons
            map_id.lane_strips = lane_strips
            map_id.lane_strip_visible_flag = []
            for (var i = 0; i < lane_strips.length; ++i){
                map_id.lane_strip_visible_flag.push(true)
            }
            map_id.ramp_visible_flag = []
            for(var i = 0; i < ramps.length; ++i) {
                map_id.ramp_visible_flag.push(true)
            }

            map_id.crossroad_visible_flag = []
            for(var i = 0; i < crossroads.length; ++i) {
                map_id.crossroad_visible_flag.push(true)
            }
            map_id.crosswalk_visible_flag = []
            for(var i = 0; i < crosswalks.length; ++i) {
                map_id.crosswalk_visible_flag.push(true)
            }



            map_id.left_lane = left_lane
            map_id.right_lane = right_lane

            map_id.crosswalksid = crosswalksid
            map_id.crosswalks = crosswalks
            map_id.crossroadsid = crossroadsid
            map_id.crossroads = crossroads
            map_id.rampsid = rampsid
            map_id.ramps = ramps
            map_id.spObjects = spObjects
            map_id.object_visible_flag = []
            for (var i = 0; i < spObjects.length; ++i){
                map_id.object_visible_flag.push(true)
            }

            map_id.mid_pos  = []
            for (var i = 0; i < left_lane.length; ++i)
            {
                var left_line = left_lane[i]
                var right_line = right_lane[i]
                var mid_index1 = parseInt(left_line.length / 2);
                var mid_index2 = parseInt(right_line.length / 2);
                map_id.mid_pos.push(Qt.point((left_line[mid_index1][0] + right_line[mid_index2][0]) /2, (left_line[mid_index1][1] + right_line[mid_index2][1]) /2))
            }
            
            map_id.signals_id = signals_id
            map_id.signals_stop_line = signals_stop_line // 红绿灯的停止线

            map_id.is_receive_map = true

            simulation_window_id.canvas_scale = Math.min(simulation_window_id.width / (x_max - x_min) ,simulation_window_id.height/(y_max - y_min));
            simulation_window_id.init_canvas_scale = simulation_window_id.canvas_scale

            // clear map cache
            map_id.clear()

            for (var i = 0; i < signals_id.length; ++i)
            {
                // console.log("traffic id =", signals_id[i])
                if (signals_id[i] != 0) {
                    var trafficLightModel = SimulatorControl.acquireTrafficLight(signals_id[i])
                    if (trafficLightModel != undefined) {
                        addTraffigLight(trafficLightModel)
                    } else {
                        if (config_id.isDebugLog) { console.log("traffic id =", signals_id[i], " is not found") }
                    }
                }
            }
            if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 254")}
            canvas_map.requestPaint()
        }

        function addTraffigLight(trafficLightModel)
        {
            // console.log("onAddLightInfo id", trafficLightModel.id, "pos", trafficLightModel.x, trafficLightModel.y)
            var pos = Qt.point(trafficLightModel.x, trafficLightModel.y)
            var id = trafficLightModel.id
            map_id.light_map[id] = pos

            var canvasPoint = simulation_window_id.realMapPointToCanvas(pos)
            map_id.addLightElement(id,  canvasPoint.x - 2 * simulation_window_id.canvas_scale / 2,
                canvasPoint.y - 2 * simulation_window_id.canvas_scale / 2, 2 * simulation_window_id.canvas_scale,
                2 * simulation_window_id.canvas_scale, "qrc:///resource/image/simulation_page/light/light.png", 0)
        }


        function onNotifyTrafficLightModel(trafficLightModel)
        {
            var id = trafficLightModel.id
            var lightBoardElement = light_board_elements_map[id]
            if (lightBoardElement == undefined)
            {
                return
            }

            // console.log("onNotifyTrafficLightModel");
            //    for (var sublight in trafficLightModel.sublights) {
            for (var i = 0; i < trafficLightModel.sublights.length; ++i)
            {
                var sublight = trafficLightModel.sublights[i]
                // console.log("sublight", sublight,  "type", sublight.type, "remain_time", sublight.remain_time)
                if (sublight.type == TrafficLightModel.FORWARD)
                {   
                    lightBoardElement.forward_color = sublight.color
                    lightBoardElement.forward_remain_time = sublight.remain_time
                }
                else if (sublight.type == TrafficLightModel.LEFT)
                {
                    lightBoardElement.left_color = sublight.color
                    lightBoardElement.left_remain_time = sublight.remain_time
                }
                else if (sublight.type == TrafficLightModel.RIGHT)
                {
                    lightBoardElement.right_color = sublight.color
                    lightBoardElement.right_remain_time = sublight.remain_time
                }
                else if (sublight.type == TrafficLightModel.UTURN)
                {
                    lightBoardElement.uturn_color = sublight.color
                    lightBoardElement.uturn_remain_time = sublight.remain_time
                }
            }
            if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 888")}
        }

        function onNotifyConveragePaths(coveragePaths) {
            console.log("Converage length: ", coveragePaths.length)
            map_id.coveragePaths = coveragePaths;
        }

        function onNotifyDebugPoints(points) {
            console.log("onNotifyDebugPoints length: ", points.length)
            map_id.debugPoints = points;
        }
    }

    Connections
    {
        target: event_bus_id
        function onShowLightInfo(light_id)
        {
            var lightElement = map_id.light_elements_map[light_id]
            if (lightElement == undefined) return
            console.log("onShowLightInfo", light_id)
            var lightBoardElement = map_id.light_board_elements_map[light_id]
            if (lightBoardElement == undefined) {
                var model = SimulatorControl.acquireTrafficLight(light_id)
                console.log("onShowLightInfo2, model: ", model)
                var light_board_width = (model.sublights.length * 70 + 20) * config_id.screenScale
                var light_board_height = 124 * config_id.screenScale
                addLightBoard(light_id, model, 
                    lightElement.x - (light_board_width - 2) / 2,
                    lightElement.y - light_board_height - 3, light_board_width, light_board_height)
            } else {
                // console.log("onShowLightInfo3", light_id)
                lightBoardElement.visible = true
            }
        }

        function onHideLightInfo(light_id)
        {
            console.log("onHideLightInfo", light_id)
            var lightBoardElement = map_id.light_board_elements_map[light_id]
            if (lightBoardElement == undefined)
            {
                return
            }
            lightBoardElement.visible = false
        }

        function onLocateAxies(x, y)
        {
            var selectedMapPoint = Qt.point(x, y)
            var canvasPoint = simulation_window_id.realMapPointToCanvas(selectedMapPoint)
            console.log("onLocateAxies", x, y , canvasPoint.x,  canvasPoint.y)
            smooth_scroller.smoothScrollTo(Qt.point(canvasPoint.x + simulation_window_id.offset_x, canvasPoint.y + simulation_window_id.offset_y -simulation_window_id.height))
        }


        function onLocateTrafficLight(traffic_id) 
        {   
            for (var i =0 ; i < map_id.signals_id.length; ++i) {
                if (map_id.signals_id[i] == traffic_id) {
                    var line = map_id.signals_stop_line[i];
                    var selectedMapPoint = Qt.point(line[0], line[1])
                    var canvasPoint = simulation_window_id.noScaleContextPointToCanvas(selectedMapPoint)
                    console.log("onLocateTrafficLight",traffic_id, line[0], line[1], canvasPoint.x, canvasPoint.y)
                    smooth_scroller.smoothScrollTo(Qt.point(canvasPoint.x + simulation_window_id.offset_x, canvasPoint.y + simulation_window_id.offset_y -simulation_window_id.height))
                }
            }
        }
    }

    Component.onCompleted:
    {
        if (!is_receive_map)
        {
            SimulatorControl.acquireMap()
        }
        if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 954")}
        canvas_map.requestPaint()
    }
}