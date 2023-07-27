import QtQuick 2.15

QtObject {
    /*
    * simulator page 的信号
    * 回到home页面
    * 由主页面main page接收,负责切换到 仿真页面 
    */
    signal backToHome()

    /*
    * home page 的信号
    * 创建工程信号 , 由 home page里发出.  参数 工程类型, 工程的地图
    * 由主页面main page接收,负责切换到 仿真页面 
    */
    signal createProject(string type, string name)

    /* 
    *  编辑框 edit_control 的信号
    * 场景添加障碍物的信号
    * 参数  1障碍物类型(暂时名字）
    * 由 仿真页面simulator page接收,  修改鼠标,显示icon图片
    */
    signal getIconSourceToMoveCar(int obs_type)
    
    /*
    * 仿真页面simulator page 的信号
    * 释放鼠标的icon
    * 参数  1. 位置是simulation_page页面的鼠标位置  2障碍物类型
    * 由 canvas绘制页面simulation_window获取
    */
    signal editControlSendMousePosAndImageSource(real mouseX,real mouseY, int obstacle_type)

    /*
    * simulation_window 的信号
    * 鼠标在  canvas绘制页面移动
    * 参数  1. 鼠标位置 在映射到 地图后的 坐标
    * 由 底部的bottom_tip获取并显示
    */
    signal mouseMoveOnCanvas(double x, double y)

    /*
    * simulation_window 的信号
    * 鼠标选中工具栏某一个按钮
    * 参数  1. 工具类型
    * tool_type: 1 鼠标移动状态，此时不可编辑
    *            2 选中折线状态
    */
    signal selectTool(int tool_type)

    /*
    * simulation_window 的信号
    * 选中主车
    */
    signal selectHeroCar()

    /*
    * simulation_window 的信号
    * 选中障碍物
    * 参数  1. 障碍物id
    */
    signal selectObstacle(int id)

    /*
    * simulation_window 的信号
    * 选中垃圾
    * 参数  1. 垃圾id
    */
    signal selectGarbage(int id)

    /*
    * simulation_window 的信号
    * 选中路线
    * 参数  1. 路线id
    */
    signal selectLineCurve(int id)

    /*
    * simulation_window 的信号
    * 选中小巴停车区域
    */
    signal selectParkingArea()

    /*
    * simulation_window 的信号
    * 添加小巴停车区域
    * 参数  1. circle ids, circle 圆心, circle 半径, 
    */
    signal addParkingArea(var ids, var points, var radii)

    /*
    * simulation_window 的信号
    * 清空展示列表
    */
    signal emptyEditDisplay()

    /*
    * simulation_window 的信号
    * 通知主车属性发生变化
    */
    signal notifyUpdateHeroCar()

    /*
    * simulation_window 的信号
    * 通知障碍物属性发生变化
    * 参数  1. 障碍物id
    */
    signal notifyUpdateObstacle(int id)

    /*
    * simulation_window 的信号
    * 通知垃圾属性发生变化
    * 参数  1. 垃圾id
    */
    signal notifyUpdateGarbage(int id)

    /*
    * main_page_rect_id 的信号
    * 拦截全局的 键盘事件, 所有模块需要键盘事件都收敛到eventbus
    * 参数  1. event
    */
    signal keyPressed(int key)

    /*
    * main_page_rect_id 的信号
    * 拦截全局的 键盘事件, 所有模块需要键盘事件都收敛到eventbus
    * 参数  1. event
    */
    signal locateObstacle(int id)

    /*
    * bottom_tip 的信号
    * 跳转到指定坐标
    * 参数  1. x, y 地图坐标
    */
    signal locateAxies(double x, double y)

    /*
    * 跳转到指定红绿灯
    */
    signal locateTrafficLight(string traffic_id)
    /*
    * 重置场景 的信号
    */
    signal reset()

    /*
    * canvas上元素按下的信号
    * 参数  1. 元素id  2.按下的点相对元素左上角横轴占比  3.按下的点相对元素左上角纵轴占比
    */
    signal canvasElementPressed(int element_id, real x_percent, real y_percent)

    /*
    * simulation left side button按下的信号
    * 参数：1.元素名字
    * 暂时用于测试
    */
    signal simulationLeftSideTabBarPressed(var name)

    /*
    * 红绿灯面板显示的信号
    * 参数：1.元素id
    */
    signal showLightInfo(string element_id)

    /*
    * 红绿灯面板隐藏的信号
    * 参数：1.元素id
    */
    signal hideLightInfo(string element_id)

    /*
    * 选中红绿灯的信号
    * 参数：1.元素id
    */
    signal selectLight(string element_id)

    /*
    * 显示仿真测试文件模板的信号
    */
    signal showSimulationTestBoard()

    /*
    * 设置全局变量，是否是在仿真运行时的状态
    */
    property bool is_playing : false

    signal notifyStartSimulator()
}