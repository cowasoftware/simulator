import QtQuick 2.0
import QtQuick.Window 2.12
QtObject {

    // hero car type
    property int hero_car_type_start : 101
    property int hero_car_X3 : 101
    property int hero_car_EQ5 : 102
    property int hero_car_unicorn : 103
    property int hero_car_minu_bus : 104
    property int hero_car_type_end : hero_car_minu_bus
    // ObstacleType
    property int obstacle_type_start : 0
    property int unknown : 0
    property int car : 3    // 小轿车，SUV
    property int bus : 4    // 大巴车
    property int truck : 5  // 卡车
    property int special : 6  //特种车辆，如工程车

    property int cyclist : 10    // 自行车
    property int tricycle : 11   // 三轮车
    property int motorcyclist : 12 // 摩托车

    property int pedestrian : 20    // 行人
    property int wheelchair : 21    // 轮椅
    property int babycar : 22       // 婴儿车

    property int obstacle_type_static : 30
    property int roadblock : 30    // 路障
    property int tree_trunk : 31 // 圆形，树躯干, hdmap.proto同定义
    property int pole : 32       // 圆形，电线杆、路灯杆等, hdmap.proto同定义
    property int piles : 33     // 圆形，固定的路桩(或者逻辑上可以认为路桩的障碍物，如圆形石墩), hdmap.proto同定义
    property int dustbin : 35    // 多边形，垃圾桶，果皮箱, hdmap.proto同定义
    property int block : 36      // 多边形，小型的石墩，如园区外墙的方形柱子, hdmap.proto同定义
    property int curb_line : 37 // bounding_contours 为按排序的点组成的线(非凸)

    property int trafficlight : 40  // 红绿灯，主要用于合并红绿灯以及障碍物检测
    property int obstacle_type_end : trafficlight

    // garbage type 
    property int garbage_type_start : 200
    property int crack : 200
    property int pothole : 201
    property int lineblur : 202
    property int roaddirt : 203
    property int big_garbage : 204
    property int ponding : 205
    property int snow : 206
    property int fallen_leaves : 207
    property int white_trash : 208
    property int other_garbage : 209
    property int garbage_type_end : other_garbage


    property int line_curves : 101  // 用户自定义轨迹线

    //以下数值不影响业务逻辑
    property int edit_obstacle : 1  // 物体
    property int hero_car : 11  // 主车
    property int dynamic_obstacle : 12  // 可动的障碍物
    property int static_obstacle : 13  // 静止的障碍物
    property int garbage : 15  // 垃圾

    property var element_type: ["herocar", "obstacle", "garbage", "curvepoints", "light", "area"]

    property var propertyConfig : ({})
    property var scenoriaConfig : ({})
    Component.onCompleted: {
        propertyConfig[edit_obstacle] = {name: qsTr("编辑物体")}
        propertyConfig[hero_car] = {name: qsTr("主车")}
        propertyConfig[dynamic_obstacle] = {name: qsTr("动态障碍物")}
        propertyConfig[static_obstacle] = {name: qsTr("静态障碍物")}
        propertyConfig[garbage] = {name: qsTr("垃圾")}

        scenoriaConfig[hero_car_X3] = {
            name: qsTr("X3"),
            name_en : qsTr(""),
            image_source: "qrc:///resource/image/simulation_page/hero_car_X3.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_hero_car_X3.png",
            property1: edit_obstacle,
            property2: hero_car,
            is_show_in_edit_control: true
        }
        scenoriaConfig[hero_car_EQ5] = {
            name: qsTr("EQ5"),
            name_en : qsTr(""),
            image_source: "qrc:///resource/image/simulation_page/hero_car_EQ5.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_hero_car_EQ5.png",
            property1: edit_obstacle,
            property2: hero_car,
            is_show_in_edit_control: true
        }
        scenoriaConfig[hero_car_unicorn] = {
            name: qsTr("UNICORN"),
            name_en : qsTr(""),
            image_source: "qrc:///resource/image/simulation_page/hero_car_unicorn.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_hero_car_unicorn.png",
            property1: edit_obstacle,
            property2: hero_car,
            is_show_in_edit_control: true
        }
        scenoriaConfig[hero_car_minu_bus] = {
            name: qsTr("MINI_BUS"),
            name_en : qsTr(""),
            image_source: "qrc:///resource/image/simulation_page/hero_car_minibus.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_hero_car_minibus.png",
            property1: edit_obstacle,
            property2: hero_car,
            is_show_in_edit_control: true
        }
        scenoriaConfig[unknown] = {
            name: qsTr("未知类型"),
            name_en : qsTr("UNKNOWN"),
            image_source: "qrc:///resource/image/simulation_page/vertical_unknown.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_unknown.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[car] = {
            name: qsTr("小汽车"),
            name_en : qsTr("CAR"),
            image_source: "qrc:///resource/image/simulation_page/car.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_car.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[truck] = {
            name: qsTr("卡车"),
            name_en : qsTr("TRUCK"),
            image_source: "qrc:///resource/image/simulation_page/truck.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_truck.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[motorcyclist] = {
            name: qsTr("摩托车"),
            name_en : qsTr("MOTORCYCLIST"),
            image_source: "qrc:///resource/image/simulation_page/motorcyclist.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_motorcyclist.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[pedestrian] = {
            name: qsTr("行人"),
            name_en : qsTr("PEDESTRIAN"),
            image_source: "qrc:///resource/image/simulation_page/pedestrian.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_pedestrian.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[cyclist] = {
            name: qsTr("自行车"),
            name_en : qsTr("CYCLIST"),
            image_source: "qrc:///resource/image/simulation_page/vertical_cyclist.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_cyclist.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[dustbin] = {
            name: qsTr("垃圾箱"),
            name_en : qsTr("DUSTBIN"),
            image_source: "qrc:///resource/image/simulation_page/vertical_dustbin.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_dustbin.png",
            property1: edit_obstacle,
            property2: static_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[tree_trunk] = {
            name: qsTr("树木"),
            name_en : qsTr("TREE_TRUNK"),
            image_source: "qrc:///resource/image/simulation_page/vertical_tree_trunk.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_tree_trunk.png",
            property1: edit_obstacle,
            property2: static_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[piles] = {
            name: qsTr("石墩"),
            name_en : qsTr("PILES"),
            image_source: "qrc:///resource/image/simulation_page/vertical_piles.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_piles.png",
            property1: edit_obstacle,
            property2: static_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[special] = {
            name: qsTr("特殊车辆"),
            name_en : qsTr("SPECIAL"),
            image_source: "qrc:///resource/image/simulation_page/vertical_special.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_special.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[pole] = {
            name: qsTr("路灯"),
            name_en : qsTr("POLE"),
            image_source: "qrc:///resource/image/simulation_page/vertical_pole.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_pole.png",
            property1: edit_obstacle,
            property2: static_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[roadblock] = {
            name: qsTr("路障"),
            name_en : qsTr("ROADBLOCK"),
            image_source: "qrc:///resource/image/simulation_page/vertical_roadblock.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_roadblock.png",
            property1: edit_obstacle,
            property2: static_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[wheelchair] = {
            name: qsTr("轮椅"),
            name_en : qsTr("WHEELCHAIR"),
            image_source: "qrc:///resource/image/simulation_page/vertical_wheelchair.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_wheelchair.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[babycar] = {
            name: qsTr("婴儿车"),
            name_en : qsTr("BABYCAR"),
            image_source: "qrc:///resource/image/simulation_page/vertical_babycar.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_babycar.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[block] = {
            name: qsTr("方形石墩"),
            name_en : qsTr("BLOCK"),
            image_source: "qrc:///resource/image/simulation_page/vertical_block.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_block.png",
            property1: edit_obstacle,
            property2: static_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[bus] = {
            name: qsTr("大巴"),
            name_en : qsTr("BUS"),
            image_source: "qrc:///resource/image/simulation_page/vertical_bus.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_bus.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[tricycle] = {
            name: qsTr("三轮车"),
            name_en : qsTr("TRICYCLE"),
            image_source: "qrc:///resource/image/simulation_page/vertical_tricycle.png",
            vertical_image_source: "qrc:///resource/image/simulation_page/vertical_tricycle.png",
            property1: edit_obstacle,
            property2: dynamic_obstacle,
            is_show_in_edit_control: true
        }
        scenoriaConfig[fallen_leaves] = {
            name: qsTr("落叶"),
            name_en : qsTr("FALLENLEAVES"),
            image_source: "qrc:///resource/image/simulation_page/leaf.jpeg",
            vertical_image_source: "qrc:///resource/image/simulation_page/leaf.jpeg",
            property1: edit_obstacle,
            property2: garbage,
            is_show_in_edit_control: true
        }
        scenoriaConfig[white_trash] = {
            name: qsTr("白色垃圾"),
            name_en : qsTr("WHITETRASH"),
            image_source: "qrc:///resource/image/simulation_page/white_trash.jpeg",
            vertical_image_source: "qrc:///resource/image/simulation_page/white_trash.jpeg",
            property1: edit_obstacle,
            property2: garbage,
            is_show_in_edit_control: true
        }
        scenoriaConfig[other_garbage] = {
            name: qsTr("其他垃圾"),
            name_en : qsTr("OTHERGARBAGE"),
            image_source: "qrc:///resource/image/simulation_page/other_waste.jpeg",
            vertical_image_source: "qrc:///resource/image/simulation_page/other_waste.jpeg",
            property1: edit_obstacle,
            property2: garbage,
            is_show_in_edit_control: true
        }
    }

    property bool isLocalHost : true
    property bool isUsingAI : false
    property bool isDebugLog : false
    property var simulatorType : "" // new ; local; record 
    property var screenScale : parseInt(Screen.width/1920)
}