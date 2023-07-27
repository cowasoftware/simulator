import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2

import COWA.Simulator 1.0


Item {
    id : canvas_element_id


    property var element_map: ({})
    property var current_select_element_id: 0
    property var current_select_element_x_percent: 0
    property var current_select_element_y_percent: 0

    property var is_clicked_element: false

    property var hero_car_planning_curve_points: []
    property var hero_car_last_planning_curves: []
    property var hero_car_routing_points: []
    property var hero_car_reference_points: []
    property var hero_car_poisition_err : false


    // property var obstacle_prediction_curve_points: []
    property var obstacle_prediction_curve_points_map: ({})

    function onPaint(ctx) {
        drawHeroCarCurve(ctx)
        drawObstacleCurve(ctx)
    }

    function onMoveSelected(mouseX, mouseY) {
        if (current_select_element_id != 0)
        {
            var element = element_map[current_select_element_id]
            element.x = mouseX - current_select_element_x_percent * element.width
            element.y = mouseY - current_select_element_y_percent * element.height
            var element_x = element.x + element.width / 2
            var element_y = element.y + element.height / 2
            var realMapElementPoint = simulation_window_id.canvasPointToRealMap(Qt.point(element_x, element_y))
            element.map_x = realMapElementPoint.x
            element.map_y = realMapElementPoint.y

            if (element.type == config_id.element_type[0])
            {
                //console.log("add addHeroCar ", obstacle_type, realMapPoint.x, realMapPoint.y)
                var heroCarModel = ScenarioControl.findHeroCarModel()
                heroCarModel.x = realMapElementPoint.x
                heroCarModel.y = realMapElementPoint.y
                event_bus_id.notifyUpdateHeroCar()
                SimulatorControl.syncSceneToServer();
            }
            else if (element.type == config_id.element_type[1])
            {
                var obstacleModel = ScenarioControl.findObstacleModel(current_select_element_id)
                obstacleModel.x = realMapElementPoint.x
                obstacleModel.y = realMapElementPoint.y
                event_bus_id.notifyUpdateObstacle(current_select_element_id)
            } else if (element.type == config_id.element_type[2]) {
                var garbageModel = ScenarioControl.findGarbageModel(current_select_element_id)
                garbageModel.x = realMapElementPoint.x
                garbageModel.y = realMapElementPoint.y
                event_bus_id.notifyUpdateGarbage(current_select_element_id)
            }
        }
    }

    function onMoveAll(move_x, move_y) {
        for (var key in element_map)
        {
            element_map[key].x += move_x
            element_map[key].y += move_y
        }
    }

    function onWheel(scale_value) {
        for (var key in element_map)
        {
            var element = element_map[key]
            var canvasPoint = simulation_window_id.realMapPointToCanvas(Qt.point(element.map_x, element.map_y))
            // console.log("onWheel map_point", element.map_x, element.map_y)
            element_map[key].width = element_map[key].width * scale_value
            element_map[key].height = element_map[key].height * scale_value
            if (element_map[key].car_length_b)
                element_map[key].car_length_b = element_map[key].car_length_b * scale_value
            if (element_map[key].car_bridge_width1)
                element_map[key].car_bridge_width1 = element_map[key].car_bridge_width1 * scale_value
            if (element_map[key].car_bridge_width2)
                element_map[key].car_bridge_width2 = element_map[key].car_bridge_width2 * scale_value

            element_map[key].x = canvasPoint.x - element_map[key].width/2
            element_map[key].y = canvasPoint.y - element_map[key].height/2

            // console.log("onWheel !light_board", element_map[key].width, element_map[key].height)
        }
    }

    function onReleased() {
        if (current_select_element_id != 0)
        {
            current_select_element_id = 0
            current_select_element_x_percent = 0
            current_select_element_y_percent = 0
        }
    }

    function addObstacleElement(element_id, element_type, x, y, map_point, width, height, image_url, rotate)
    {
        if (element_map[element_id] != undefined)
        {
            return
        }
        var component = Qt.createComponent("qrc:///resource/qml/simulation_page/element.qml")
        if (component.status === Component.Ready)
        {
            var element = component.createObject(canvas_element, 
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
                "type": element_type,
            })
            element_map[element_id] = element
        }
    }

    function addGarbageElement(element_id, element_type, x, y, map_point, width, height, image_url, rotate)
    {
        if (element_map[element_id] != undefined)
        {
            return
        }
        var component = Qt.createComponent("qrc:///resource/qml/simulation_page/element.qml")
        if (component.status === Component.Ready)
        {
            var element = component.createObject(canvas_element, 
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
                "type": element_type,
            })
            element_map[element_id] = element
        }
    }


    function addHeroElement(element_id, element_type, x, y, map_point, length_b, width, height, image_url, rotate, vehicle_type)
    {
        if (element_map[element_id] != undefined)
        {
            return
        }
        var component = Qt.createComponent("qrc:///resource/qml/simulation_page/hero_element.qml")
        if (component.status === Component.Ready)
        {
            var element = component.createObject(canvas_element, 
            {
                "x": x,
                "y": y,
                "map_x" : map_point.x,
                "map_y" : map_point.y,
                "width": width,
                "height": height,
                "car_image_source": image_url,
                "car_image_rotate": rotate,
                "car_length_b": length_b,
                "element_id": element_id,
                "type": element_type,
                "vehicle_type": vehicle_type,
                'car_bridge_width1': 1.62 * simulation_window_id.canvas_scale,
                'car_bridge_width2': 2.1 * simulation_window_id.canvas_scale
            })
            element_map[element_id] = element
        }
    }

    function drawHeroCarCurve(ctx) {
        if (hero_car_planning_curve_points.length > 0) {
            ctx.beginPath()
            // ctx.strokeStyle = "#00CCCC"
            ctx.strokeStyle = 'rgba(0, 255, 255, 0.8)'
            ctx.lineWidth =  config_id.screenScale / 2
            ctx.moveTo(hero_car_planning_curve_points[0].x, hero_car_planning_curve_points[0].y)
            for (var i = 1; i < hero_car_planning_curve_points.length; ++i)
            {
                ctx.lineTo(hero_car_planning_curve_points[i].x, hero_car_planning_curve_points[i].y)
            }
            ctx.stroke()
            ctx.closePath()
        }
        if (hero_car_last_planning_curves.length > 0) {
            ctx.beginPath()
            ctx.strokeStyle = 'rgba(255, 0, 0, 1.0)'
            ctx.lineWidth = config_id.screenScale / simulation_window_id.canvas_scale
            ctx.moveTo(hero_car_last_planning_curves[0].x, hero_car_last_planning_curves[0].y)
            for (var i = 1; i < hero_car_last_planning_curves.length; ++i)
            {
                ctx.lineTo(hero_car_last_planning_curves[i].x, hero_car_last_planning_curves[i].y)
            }
            ctx.stroke()
            ctx.closePath()
        }
        if (hero_car_routing_points.length > 0) {
            ctx.beginPath()
            ctx.strokeStyle = "red"
            ctx.lineWidth = 1 / simulation_window_id.canvas_scale
            ctx.moveTo(hero_car_routing_points[0].x, hero_car_routing_points[0].y)
            for (var i = 1; i < hero_car_routing_points.length; ++i)
            {
                ctx.lineTo(hero_car_routing_points[i].x, hero_car_routing_points[i].y)
            }
            ctx.stroke()
            ctx.closePath()
        }

        if (hero_car_reference_points.length > 0) {
            ctx.beginPath()
            ctx.strokeStyle = "#3333FF"
            ctx.lineWidth = 1 / simulation_window_id.canvas_scale
            ctx.moveTo(hero_car_reference_points[0].x, hero_car_reference_points[0].y)
            for (var i = 1; i < hero_car_reference_points.length; ++i)
            {
                ctx.lineTo(hero_car_reference_points[i].x, hero_car_reference_points[i].y)
            }
            ctx.stroke()
            ctx.closePath()
        }
    }

    function drawObstacleCurve(ctx) {
        for (var key in canvas_element_id.obstacle_prediction_curve_points_map) {
        
            // console.log("drawObstacleCurve--------------------123")
            var curve = canvas_element_id.obstacle_prediction_curve_points_map[key]
            if (curve.length == 0) continue
            ctx.beginPath()
            ctx.strokeStyle = "yellow"
            ctx.lineWidth = 3 / simulation_window_id.canvas_scale

            ctx.moveTo(curve[0].x, curve[0].y)
            for (var i = 1; i < curve.length; ++i)
            {
                ctx.lineTo(curve[i].x, curve[i].y)
            }
            ctx.stroke()
            ctx.closePath()
        }
    }

    Connections
    {
        target: ScenarioControl
        function onNotifyAddHeroCar(model)
        {
            console.log("111onNotifyAddHeroCar:", model.x, model.y, model.theta)
            onNotifyDeleteHeroCar()

            var map_point = Qt.point(model.x, model.y)
            var canvasPoint = simulation_window_id.realMapPointToCanvas(map_point)
            addHeroElement(-1, config_id.element_type[0],
                canvasPoint.x - model.length * simulation_window_id.canvas_scale / 2,
                canvasPoint.y - model.width * simulation_window_id.canvas_scale / 2, 
                map_point,
                model.length_b * simulation_window_id.canvas_scale,
                model.length * simulation_window_id.canvas_scale,
                model.width * simulation_window_id.canvas_scale, 
                config_id.scenoriaConfig[model.type].vertical_image_source, 
                -model.theta * 180 / Math.PI,
                model.type
                )
            if (config_id.isDebugLog) { console.log("canvas_element.requestPaint 169")}
            canvas_element.requestPaint()
        }

        function onNotifyDeleteHeroCar()
        {
            var heroCarElement = element_map[-1]
            if (heroCarElement == undefined)
            {
                return
            }
            heroCarElement.destroy()
            delete element_map[-1]
            SimulatorControl.syncSceneToServer()
        }

        function onNotifyAddObstacle(id, model)
        {
            // console.log("111onNotifyAddObstacle:", model.x, model.y)
            var map_point = Qt.point(model.x, model.y)
            var canvasPoint = simulation_window_id.realMapPointToCanvas(map_point)
            addObstacleElement(id, config_id.element_type[1],
                canvasPoint.x - model.length * simulation_window_id.canvas_scale / 2,
                canvasPoint.y - model.width * simulation_window_id.canvas_scale / 2, 
                map_point, 
                model.length * simulation_window_id.canvas_scale,
                model.width * simulation_window_id.canvas_scale,
                config_id.scenoriaConfig[model.type].vertical_image_source, 
                -model.theta * 180 / Math.PI)
            if (config_id.isDebugLog) { console.log("canvas_element.requestPaint 192")}
            canvas_element.requestPaint()
        }

        function onNotifyDeleteObstacle(id)
        {
            // console.log("onNotifyDeleteObstacle line 231， id", id)
            var obstacleCarElement = element_map[id]
            if (obstacleCarElement == undefined)
            {
                return
            }
            obstacleCarElement.destroy()
            delete element_map[id]
            delete obstacle_prediction_curve_points_map[id]
            canvas_element.requestPaint()
        }

        function onNotifyAddGarbage(id, model) {
            console.log("onNotifyAddGarbage:", model.type, model.x, model.y)
            var map_point = Qt.point(model.x, model.y)
            var canvasPoint = simulation_window_id.realMapPointToCanvas(map_point)
            addGarbageElement(id, config_id.element_type[2],
                canvasPoint.x - model.length * simulation_window_id.canvas_scale / 2,
                canvasPoint.y - model.width * simulation_window_id.canvas_scale / 2, 
                map_point, 
                model.length * simulation_window_id.canvas_scale,
                model.width * simulation_window_id.canvas_scale,
                config_id.scenoriaConfig[model.type].vertical_image_source, 
                -model.theta * 180 / Math.PI,)
            if (config_id.isDebugLog) { 
                console.log("canvas_element paint garbage")
            }
            canvas_element.requestPaint()
        }

        function onNotifyDeleteGarbage(id) {
            console.log("onNotifyDeleteGarbage, id: ", id)
            var garbageElement = element_map[id]
            if (garbageElement == undefined)
            {
                return
            }
            garbageElement.destroy()
            delete element_map[id]
            canvas_element.requestPaint()
        }

        // all object should redraw
        function onNotifyUpdateAll()
        {
            // . . .
        }

        function onNotifyUpdateRecordHeroCar(x, y, timestamp_ns) {
            var canvasPoint = simulation_window_id.realMapPointToCanvas(Qt.point(x, y))
            var width = 4
            var length = 4
            var heroCarElement = element_map[-2]
            if (heroCarElement != undefined)
            {
                heroCarElement.x = canvasPoint.x - length * simulation_window_id.canvas_scale / 2
                heroCarElement.y = canvasPoint.y - width * simulation_window_id.canvas_scale / 2
            } else {
                var map_point = simulation_window_id.canvasPointToRealMap(Qt.point(x,y))
                addHeroElement(-2, config_id.element_type[0],
                    canvasPoint.x - length * simulation_window_id.canvas_scale / 2,
                    canvasPoint.y - width * simulation_window_id.canvas_scale / 2, 
                    map_point, 
                    model.length_b * simulation_window_id.canvas_scale,
                    length * simulation_window_id.canvas_scale,
                    width * simulation_window_id.canvas_scale, 
                    "", 
                    0,
                    model.type)
                    if (config_id.isDebugLog) { console.log("simulation_window_id.requestPaint 227")}
                canvas_element.requestPaint()
                // canvas.markDirty(Qt.rect(canvasPoint.x, canvasPoint.y, 20, 20))
            }
        }

        function onNotifyUpdateObstacle(id, model)
        {
            var element = element_map[id]
            if (element == undefined)
            {
                // console.log("cannot find obstacle, id = " + id)
                return
            }
            var canvasPoint = simulation_window_id.realMapPointToCanvas(Qt.point(model.x, model.y))
            element.x = canvasPoint.x - model.length * simulation_window_id.canvas_scale / 2
            element.y = canvasPoint.y - model.width * simulation_window_id.canvas_scale / 2
            element.map_x = model.x
            element.map_y = model.y
            element.width = model.length * simulation_window_id.canvas_scale
            element.height = model.width * simulation_window_id.canvas_scale
            element.car_image_rotate = -model.theta * 180 / Math.PI

            var curve = model.findPredictionCurvePoints()
            if (curve.length < 2) {return}
            for (var i = 0; i < curve.length; ++i)
            {
                curve[i] = simulation_window_id.realMapPointToNoScaleContext(curve[i])
            }
            delete canvas_element_id.obstacle_prediction_curve_points_map[id]
            canvas_element_id.obstacle_prediction_curve_points_map[id] = curve
            if (config_id.isDebugLog) { console.log("canvas_element.requestPaint 300")}
            canvas_element.requestPaint()
            // canvas.markDirty(Qt.rect(element.x, element.y, element.width + element.height, element.width + element.height))

            // var minx = Math.min(curve[0].x, curve[curve.length - 1].x);
            // var maxx = Math.max(curve[0].x, curve[curve.length - 1].x);
            // var miny = Math.min(curve[0].y, curve[curve.length - 1].y);
            // var maxy = Math.max(curve[0].y, curve[curve.length - 1].y);
            // canvas.markDirty(Qt.rect(minx, miny, maxx - minx, maxy - miny))
        }

        function onNotifyUpdateObstacleVisible(id, visible) {
            var element = element_map[id]
            if (element == undefined)
            {
                return
            }
            element.obstacle_opacity = visible == true ? 0.8 : 0.3;
            
            if (config_id.isDebugLog) { console.log("canvas_element.requestPaint 443")}
            canvas_element.requestPaint()
        }

        function onNotifyUpdateHeroCar(model)
        {
            var element = element_map[-1]
            if (element == undefined)
            {
                console.log("cannot find hero car, id = -1")
                return
            }

            if (hero_car_poisition_err) {
                return
            }

            var heroCarPos = Qt.point(model.x, model.y)

            var canvasPoint = simulation_window_id.realMapPointToCanvas(heroCarPos)
            element.x = canvasPoint.x - model.length * simulation_window_id.canvas_scale / 2
            element.y = canvasPoint.y - model.width * simulation_window_id.canvas_scale / 2
            element.map_x = model.x
            element.map_y = model.y
            element.width = model.length * simulation_window_id.canvas_scale
            element.height = model.width * simulation_window_id.canvas_scale
            element.car_image_rotate = -model.theta * 180 / Math.PI

            // canvas.markDirty(Qt.rect(canvasPoint.x - element.width, canvasPoint.y - element.height, element.width + element.height, element.width + element.height))


            // console.log("onNotifyUpdateHeroCar", model.x, model.y)

            var new_trajectory = model.findPredictionCurvePoints()
            if (new_trajectory.length > 0) {
                canvas_element_id.hero_car_last_planning_curves =  canvas_element_id.hero_car_planning_curve_points
                canvas_element_id.hero_car_planning_curve_points = new_trajectory
                for (var i = 0; i < canvas_element_id.hero_car_planning_curve_points.length; ++i)
                {
                    canvas_element_id.hero_car_planning_curve_points[i] = simulation_window_id.realMapPointToNoScaleContext(canvas_element_id.hero_car_planning_curve_points[i])
                }
                model.clearPredictionCurvePoints()
                canvas_element.requestPaint();
            }

            var new_routing_response = model.findRoutingResponsePoints()
            if (new_routing_response.length > 0) {
                canvas_element_id.hero_car_routing_points = new_routing_response
                for (var i = 0; i < new_routing_response.length; ++i)
                {
                    canvas_element_id.hero_car_routing_points[i] = simulation_window_id.realMapPointToNoScaleContext(new_routing_response[i])
                }
                model.clearRoutingResponsePoints();
                canvas_element.requestPaint();
            }

            canvas_element_id.hero_car_reference_points = model.findReferencePoints()
            for (var i = 0; i < canvas_element_id.hero_car_reference_points.length; ++i)
            {
                canvas_element_id.hero_car_reference_points[i] = simulation_window_id.realMapPointToNoScaleContext(canvas_element_id.hero_car_reference_points[i])
            }

            // if (config_id.isDebugLog) { console.log("canvas.requestPaint 334, ")}
            canvas_element.requestPaint()
        }

        function onNotifyUpdateGarbage(id, model) {
            var element = element_map[id]
            if (element != undefined) { return }
            // 垃圾被清理了
            console.log("garbage be detected, id = " + id)
            var map_point = Qt.point(model.x, model.y)
            var canvasPoint = simulation_window_id.realMapPointToCanvas(map_point)
            addGarbageElement(id, config_id.element_type[2],
            canvasPoint.x - model.length * simulation_window_id.canvas_scale / 2,
            canvasPoint.y - model.width * simulation_window_id.canvas_scale / 2, 
            map_point, 
            model.length * simulation_window_id.canvas_scale,
            model.width * simulation_window_id.canvas_scale,
            config_id.scenoriaConfig[model.type].vertical_image_source, 
            -model.theta * 180 / Math.PI,)
            
            // var canvasPoint = simulation_window_id.realMapPointToCanvas(Qt.point(model.x, model.y))
            // element.x = canvasPoint.x - model.length * simulation_window_id.canvas_scale / 2
            // element.y = canvasPoint.y - model.width * simulation_window_id.canvas_scale / 2
            // element.map_x = model.x
            // element.map_y = model.y
            // element.width = model.length * simulation_window_id.canvas_scale
            // element.height = model.width * simulation_window_id.canvas_scale
            // element.car_image_rotate = -model.theta * 180 / Math.PI
            
            if (config_id.isDebugLog) { 
                console.log("canvas_element.requestPaint garbage")
            }
            canvas_element.requestPaint()
        }

        function onNotifyUpdateHeroCarError(old_x, old_y, x, y, distance) {
            console.log("hero car 位置飘逸 ", old_x, old_y, x, y, distance)
            // hero_car_poisition_err = true
        }

        function onNotifyClear()
        {
            onNotifyDeleteHeroCar();

            for (var key in element_map)
            {
                var element = element_map[key]
                if (element.type === config_id.element_type[1]) {
                    onNotifyDeleteObstacle(key);
                } else if(element.type === config_id.element_type[2]) {
                    onNotifyDeleteGarbage(key);
                }
            }
        }
    }


    Connections
    {
        target: event_bus_id
        function onSelectHeroCar()
        {
            onSelectObstacle(-1)
        }

        function onSelectGarbage(element_id) {
            console.log("onSelectGarbage " , element_id)
            onSelectObstacle(element_id)
        }

        function onSelectObstacle(element_id)
        {
            console.log("onSelectObstacle " , element_id)
            if (canvas_element_id.is_clicked_element)
            {
                canvas_element_id.is_clicked_element = false
                return
            }

            var element = canvas_element_id.element_map[element_id]
            if (element == undefined)
            {
                return
            }

            smooth_scroller.smoothScrollTo(Qt.point(element.x + simulation_window_id.offset_x, element.y + simulation_window_id.offset_y -simulation_window_id.height))
        }

        function onCanvasElementPressed(element_id, x_percent, y_percent)
        {
            console.log("onCanvasElementPressed", element_id, x, y)
            canvas_element_id.current_select_element_id = element_id
            canvas_element_id.is_clicked_element = true

            var element = canvas_element_id.element_map[element_id]
            if (element == undefined) {
                return
            }

            // notify to other qml
            if (element.type == config_id.element_type[0]) {
                event_bus_id.selectHeroCar()
            } else if (element.type == config_id.element_type[1]) {
                event_bus_id.selectObstacle(element_id)
            } else if (element.type == config_id.element_type[2]) {
                event_bus_id.selectGarbage(element_id)
            }

            canvas_element_id.current_select_element_x_percent = x_percent
            canvas_element_id.current_select_element_y_percent = y_percent
        }

        function onReset() {
            for (var key in obstacle_prediction_curve_points_map) {
                delete obstacle_prediction_curve_points_map[key]
            }
            canvas_element.requestPaint()
            console.log("reset--------------------")
        }

        function onNotifyStartSimulator() {
            canvas_element_id.hero_car_poisition_err = false
        }
    }
}