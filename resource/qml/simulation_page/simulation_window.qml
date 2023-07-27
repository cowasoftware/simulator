import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2

import COWA.Simulator 1.0

import "qrc:/resource/qml/simulation_page/CanvasContent"

Item
{
    id: simulation_window_id

    property bool show_all_lane_id : false
    property bool hightlight_one_road : false
    property var highlight_road : ""
    property bool hightlight_point : false
    property var highlight_points : []

    property bool show_CITY_DRIVING : true
    property bool show_BIKING : true
    property bool show_SIDEWALK : true
    property bool show_WAITINGAREA : true
    property bool show_HYBRID : true
    // property bool show_PARKING : true
    property bool show_EMERGENCY_LINE : true
    property bool show_BUS : true

    property bool show_LANE_MARK : true
    property bool show_CROSSWALK : false
    property bool show_CROSSROAD: false
    property bool show_RAMP : false
    property bool show_OBJECT: true
    property bool show_CURB: false
    property bool show_STRIP: false

    property bool keep_trafficlight_green : false


    property double canvas_scale_delta: 0.3
    property double init_canvas_scale : 1.0
    property double canvas_scale: init_canvas_scale

    property int offset_x: 0
    property int offset_y: parent.height

    property int current_mouseX: 0
    property int current_mouseY: 0
    property bool canvas_map_move : false

    MouseArea
    {
        id: canvas_window_mouse_id
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        property bool canvas_window_mouse_press_and_hold: false
        property var last_mouse_x: 0
        property var last_mouse_y: 0

        onDoubleClicked:
        {
            if (!map_drawer.is_receive_map) {
                mouse.accepted = true
                return
            }
            if ((line_drawer.tool_type == 2 || line_drawer.tool_type == 3) && (pressedButtons & Qt.LeftButton)) {
                line_drawer.onDoubleClicked()
            }
            if (circle_drawer.tool_type == 4 && (pressedButtons & Qt.RightButton))
            {
                circle_drawer.onDoubleClicked()
            }
            console.log("simulation_window_id, onDoubleClicked")
            event_bus_id.selectTool(1)
        }

        onPressed:
        {   
            if (!map_drawer.is_receive_map) {
                mouse.accepted = true
                return
            }
            if (pressedButtons & Qt.RightButton)
            {
                canvas_window_mouse_press_and_hold = true
                last_mouse_x = mouseX
                last_mouse_y = mouseY
            }
            if (pressedButtons & Qt.LeftButton) {// 鼠标左键 记录坐标到剪切板
                var realMapPoint = simulation_window_id.canvasPointToRealMap(Qt.point(mouseX - canvas_map.x, mouseY - canvas_map.y))
                ScenarioControl.copyToBoard(qsTr("" + realMapPoint.x.toFixed(2) + "," + realMapPoint.y.toFixed(2)))
            }

            if ((line_drawer.tool_type == 2 || line_drawer.tool_type == 3) && (pressedButtons & Qt.LeftButton)) {
                line_drawer.onClick(mouseX, mouseY)
                if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 91")}
                canvas_map.requestPaint()
            }

            if ((circle_drawer.tool_type == 4) && (pressedButtons & Qt.LeftButton))
            {
                circle_drawer.onPressed(mouseX, mouseY)
                if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 98")}
                console.log("canvas_map.requestPaint 98")
                // canvas_map.requestPaint()
            }
        }

        onReleased:
        {
            if (!(pressedButtons & Qt.LeftButton)) {
                element_drawer.onReleased()
            }

            if ((circle_drawer.tool_type == 4) && !(pressedButtons & Qt.LeftButton))
            {
                circle_drawer.onReleased()
            }

            if (canvas_window_mouse_press_and_hold)
            {
                canvas_window_mouse_press_and_hold = false
                last_mouse_x = 0
                last_mouse_y = 0
            }
        }

        onPositionChanged:
        {
            if (!map_drawer.is_receive_map) {
                mouse.accepted = true
                return
            }
            // move  map
            if (canvas_window_mouse_press_and_hold &&
                (pressedButtons & Qt.RightButton))
            {
                var move_x = mouseX - last_mouse_x
                var move_y = mouseY - last_mouse_y
                last_mouse_x = mouseX
                last_mouse_y = mouseY
                simulation_window_id.offset_x += move_x
                simulation_window_id.offset_y += move_y
                map_drawer.onMove(move_x, move_y)
                element_drawer.onMoveAll(move_x, move_y)
                if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 140")}
                canvas_map_move = true
                canvas_map.requestPaint()
                canvas_element.requestPaint()
                canvas_circle.requestPaint()
            }
            else if ((pressedButtons & Qt.LeftButton)) {
                // move element such as car
                element_drawer.onMoveSelected(mouseX, mouseY)
                if (config_id.isDebugLog) { console.log("canvas.requestPaint 136")}
                canvas_element.requestPaint()
            }

            if (line_drawer.tool_type == 2 || line_drawer.tool_type == 3) {
                line_drawer.onPositionChanged(mouseX, mouseY)
            }
            if ((pressedButtons & Qt.LeftButton) && (circle_drawer.tool_type == 4))
            {
                circle_drawer.onPositionChanged(mouseX, mouseY)
            }

            simulation_window_id.current_mouseX = mouseX
            simulation_window_id.current_mouseY = mouseY
            
            if (map_drawer.is_receive_map) {
                //发布鼠标所在地图的坐标
                var realMapPoint = simulation_window_id.canvasPointToRealMap(Qt.point(mouseX - canvas_map.x, mouseY - canvas_map.y))
                event_bus_id.mouseMoveOnCanvas(realMapPoint.x, realMapPoint.y)
            }
        }

        onWheel:
        {
            if (!map_drawer.is_receive_map) {
                return
            }
            //console.log("canvas onWheel")
            var old_scale_value = simulation_window_id.canvas_scale
            if (wheel.angleDelta.y > 0)
            {
                simulation_window_id.canvas_scale = simulation_window_id.canvas_scale * (1 + simulation_window_id.canvas_scale_delta)
            }
            else if (wheel.angleDelta.y < 0)
            {
                simulation_window_id.canvas_scale = simulation_window_id.canvas_scale / (1 + simulation_window_id.canvas_scale_delta)
            }

            //当前的缩放倍数
            var move_delta = simulation_window_id.canvas_scale_delta
            if (wheel.angleDelta.y < 0)
            {
                move_delta = -(1 - 1 / (1 + simulation_window_id.canvas_scale_delta))
            }
            var validMouseX = (simulation_window_id.current_mouseX != 0 ? simulation_window_id.current_mouseX : mouseX)
            var validMouseY = (simulation_window_id.current_mouseY != 0 ? simulation_window_id.current_mouseY : mouseY)

            var move_x = (validMouseX - simulation_window_id.offset_x) * move_delta
            var move_y = (validMouseY - simulation_window_id.offset_y) * move_delta
            simulation_window_id.offset_x -= move_x
            simulation_window_id.offset_y -= move_y
            map_drawer.onWheel(simulation_window_id.canvas_scale / old_scale_value)
            element_drawer.onWheel(simulation_window_id.canvas_scale / old_scale_value)
            if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 203")}
            canvas_map.requestPaint()
            canvas_element.requestPaint()
            canvas_circle.requestPaint()
        }
    }

    Canvas
    {
        id: canvas_map
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        onPaint:
        {
            // console.log("canvas_scale", canvas_scale)
            var ctx = getContext("2d");
            ctx.reset()
            // ctx.clearRect(0, 0, parent.width, parent.height)
            ctx.translate(simulation_window_id.offset_x, simulation_window_id.offset_y)
            ctx.scale(simulation_window_id.canvas_scale, simulation_window_id.canvas_scale)
            map_drawer.onPaint(ctx)
            line_drawer.onPaint(ctx)
        }
    }

    Canvas {
        id: canvas_circle 
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.translate(simulation_window_id.offset_x, simulation_window_id.offset_y)
            ctx.scale(simulation_window_id.canvas_scale, simulation_window_id.canvas_scale)
            circle_drawer.onPaint(ctx)
        }
    }

    Canvas
    {
        id: canvas_element
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        onPaint:
        {
            // console.log("canvas_scale", canvas_scale)
            var ctx = getContext("2d");
            ctx.reset()
            // ctx.clearRect(0, 0, parent.width, parent.height)
            ctx.translate(simulation_window_id.offset_x, simulation_window_id.offset_y)
            ctx.scale(simulation_window_id.canvas_scale, simulation_window_id.canvas_scale)

            element_drawer.onPaint(ctx)
        }

        onImageLoaded:
        {
            if (config_id.isDebugLog) { console.log("canvas_element.requestPaint 210")}
            canvas_element.requestPaint()
        }

        Component.onCompleted:
        {
            for(var key in config_id.scenoriaConfig)
            {
                canvas_element.loadImage(config_id.scenoriaConfig[key].vertical_image_source)
            }
            canvas_element.loadImage("qrc:///resource/image/simulation_page/light/light.png")
        }
    }

    
    
    RoadSettings{}

    MapDrawer {
        id : map_drawer    
    }

    ElementDrawer{
        id : element_drawer
    }
    
    LineDrawer{ 
        id : line_drawer
    }

    CircleDrawer{ 
        id : circle_drawer
    }

    SmoothScoller {
        id : smooth_scroller
    }

    Connections
    {
        target: event_bus_id
        // when user drag a obstacle to canvas
        function onEditControlSendMousePosAndImageSource(mouseX, mouseY, obstacle_type)
        {
            console.log("onEditControlSendMousePosAndImageSource:", mouseX, mouseY)
            // invoke ScenarioControl, add a obstacle or hero car
            if (map_drawer.is_receive_map)
            {
                simulation_window_id.current_mouseX = mouseX
                simulation_window_id.current_mouseY = mouseY

                var realMapPoint = simulation_window_id.canvasPointToRealMap(Qt.point(mouseX, mouseY))
                //console.log("onEditControlSendMousePosAndImageSource2:", realMapPoint.x, realMapPoint.y)

                console.log("add obstacle_type ", obstacle_type, realMapPoint.x, realMapPoint.y)
                if (obstacle_type >= config_id.hero_car_type_start && obstacle_type <= config_id.hero_car_type_end)
                {
                    console.log("add addHeroCar ", obstacle_type, realMapPoint.x, realMapPoint.y)
                    ScenarioControl.deleteHeroCar()
                    ScenarioControl.addHeroCar(obstacle_type, realMapPoint.x, realMapPoint.y)
                }
                else if (obstacle_type >= config_id.obstacle_type_start && obstacle_type <= config_id.obstacle_type_end)
                {
                    if (obstacle_type  < config_id.obstacle_type_static) {
                        ScenarioControl.addObstacle(obstacle_type, realMapPoint.x, realMapPoint.y)
                    } else {
                        ScenarioControl.addObstacleStatic(obstacle_type, realMapPoint.x, realMapPoint.y)
                    }
                } else if(obstacle_type >= config_id.garbage_type_start && obstacle_type <= config_id.garbage_type_end) {
                    ScenarioControl.addGarbage(obstacle_type, realMapPoint.x, realMapPoint.y)
                }
            }
        }
        function onSelectTool(tool_type)
        {
            //console.log("onSelectTool", tool_type)
            line_drawer.line_point_collect = []
            line_drawer.tool_type = tool_type
            // circle_drawer.circle_collect = []
            circle_drawer.tool_type = tool_type
            //本来适用于拖拽物体后改变形状的，现在复用在划线改变形状
            if (tool_type == 1)
            {
                canvas_window_mouse_id.cursorShape = Qt.ArrowCursor
            }
            else if (tool_type == 2)
            {
                var mouse_source = "qrc:///resource/image/simulation_page/paintLineIcon.png"
                simulation_page_mouse_cursor.setMyCursor(canvas_window_mouse_id, mouse_source.slice(3), 25* config_id.screenScale, 25* config_id.screenScale) 
            }
            else if (tool_type == 3)
            {
                var mouse_source = "qrc:///resource/image/simulation_page/main_car_target_pos.png"
                simulation_page_mouse_cursor.setMyCursor(canvas_window_mouse_id, mouse_source.slice(3), 25* config_id.screenScale, 25* config_id.screenScale) 
            }
            else if (tool_type == 4)
            {
                var mouse_source = "qrc:///resource/image/simulation_page/main_car_target_pos.png"
                simulation_page_mouse_cursor.setMyCursor(canvas_window_mouse_id, mouse_source.slice(3), 25* config_id.screenScale, 25* config_id.screenScale) 
            }
            if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 359")}
            // canvas_map.requestPaint()
        }
    }

    function canvasPointToRealMap(canvasPoint)
    {
        return Qt.point((canvasPoint.x - simulation_window_id.offset_x) / simulation_window_id.canvas_scale + map_drawer.xmapmin,
            -(canvasPoint.y - simulation_window_id.offset_y) / simulation_window_id.canvas_scale + map_drawer.ymapmin)
    }

    function realMapPointToNoScaleContext(realMapPoint)
    {
        return Qt.point(realMapPoint.x - map_drawer.xmapmin, -(realMapPoint.y - map_drawer.ymapmin))
    }

    function noScaleContextPointToRealMap(noScaleContextPoint)
    {
        return Qt.point(noScaleContextPoint.x + map_drawer.xmapmin, -noScaleContextPoint.y + map_drawer.ymapmin)
    }

    function realMapPointToCanvas(realMapPoint)
    {
        return Qt.point((realMapPoint.x - map_drawer.xmapmin) * simulation_window_id.canvas_scale + simulation_window_id.offset_x,
            -(realMapPoint.y - map_drawer.ymapmin) * simulation_window_id.canvas_scale + simulation_window_id.offset_y)
    }

    function noScaleContextPointToCanvas(contextPoint)
    {
        return Qt.point(contextPoint.x * simulation_window_id.canvas_scale  + simulation_window_id.offset_x,
            contextPoint.y * simulation_window_id.canvas_scale  + simulation_window_id.offset_y)
    }

    function scaleContextPointToCanvas(contextPoint)
    {
        return Qt.point(contextPoint.x + simulation_window_id.offset_x,
            contextPoint.y + simulation_window_id.offset_y)
    }

    function canvasPointToScaleContext(canvasPoint)
    {
        return Qt.point(canvasPoint.x - simulation_window_id.offset_x,
            canvasPoint.y - simulation_window_id.offset_y)
    }

    function resetCanvas() {
        var old_scale = simulation_window_id.canvas_scale
        simulation_window_id.canvas_scale =  simulation_window_id.init_canvas_scale
        simulation_window_id.offset_x = 0
        simulation_window_id.offset_y = parent.height

        map_drawer.onHideAllLightBoard()
        map_drawer.onWheel( simulation_window_id.canvas_scale / old_scale)
        element_drawer.onWheel(simulation_window_id.canvas_scale / old_scale)

        if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 414")}
        canvas_map.requestPaint()
        canvas_element.requestPaint()
    }
    function requestPaint() {
        if (config_id.isDebugLog) { console.log("canvas_map.requestPaint 419")}
        canvas_map.requestPaint()
        canvas_element.requestPaint()
    }
}
