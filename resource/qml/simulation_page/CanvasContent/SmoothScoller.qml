import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2

import COWA.Simulator 1.0


Timer
{
    id: slideMapTimer
    interval: 20
    repeat: true
    property var targetCanvasPoint: undefined
    property int slideTime: 80
    property int remainTime: 80
    property var move_delta_x_per_step
    property var move_delta_y_per_step
    onTriggered:
    {
        simulation_window_id.offset_x += move_delta_x_per_step
        simulation_window_id.offset_y += move_delta_y_per_step

        if (config_id.isDebugLog) { console.log("canvas all.requestPaint 23")}
        canvas_map.requestPaint()
        canvas_element.requestPaint()

        remainTime -= interval
        if (remainTime <= 0)
        {
            map_drawer.onWheel(1.0)
            element_drawer.onWheel(1.0)
            slideMapTimer.stop()

            console.log("-----", "simulation_window_id.offset_x ", simulation_window_id.offset_x, "simulation_window_id.offset_y ", simulation_window_id.offset_y)
        }
    }

    function smoothScrollTo(point) {
        // mid point 791 458
        console.log("canvas.smoothScrollTo " , point.x, point.y)
        targetCanvasPoint = point
        remainTime = slideTime
        var times = remainTime / interval

        var mid_point_x = (simulation_window_id.width/2 + simulation_window_id.offset_x)
        var mid_point_y = (-simulation_window_id.height / 2 + simulation_window_id.offset_y)
        var move_delta_x = mid_point_x - targetCanvasPoint.x
        var move_delta_y = mid_point_y - targetCanvasPoint.y  


        move_delta_x_per_step = move_delta_x / times
        move_delta_y_per_step = move_delta_y / times
        slideMapTimer.start()
    }
}