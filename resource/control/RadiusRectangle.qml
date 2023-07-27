import QtQuick 2.0

Item {
    property color color
    property real topLeftRadius
    property real topRightRadius
    property real bottomLeftRadius
    property real bottomRightRadius

    id: control
    Canvas {
        id: canvas1
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.fillStyle = control.color
            ctx.beginPath();
            ctx.arc(control.topLeftRadius,control.topLeftRadius,control.topLeftRadius, Math.PI*1, Math.PI*1.5,false)
            ctx.lineTo(control.width-control.topRightRadius,0)
            ctx.arc(control.width - control.topRightRadius,control.topRightRadius,control.topRightRadius,Math.PI*1.5,Math.PI*2,false)
            ctx.lineTo(control.width,control.height-control.bottomRightRadius)
            ctx.arc(control.width - control.bottomRightRadius,control.height - control.bottomRightRadius,control.bottomRightRadius, 0 ,Math.PI * 0.5, false)
            ctx.lineTo(control.bottomLeftRadius,control.height)
            ctx.arc(control.bottomLeftRadius,control.height - control.bottomLeftRadius,control.bottomLeftRadius,Math.PI*0.5,Math.PI,false)
            ctx.lineTo(0,control.topLeftRadius)
            ctx.fill()
            ctx.closePath()
        }

        Connections{
            target: control
            function onColorChanged(){
                canvas1.requestPaint()
            }
            function onTopLeftRadiusChanged(){
                canvas1.requestPaint()
            }
            function onTopRightRadiusChanged(){
                canvas1.requestPaint()
            }
            function onBottomLeftRadiusChanged(){
                canvas1.requestPaint()
            }
            function onBottomRightRadiusChanged(){
                canvas1.requestPaint()
            }
        }
    }
}
