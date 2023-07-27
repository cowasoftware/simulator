import QtQuick 2.0

QtObject {

    enum LanePointType {
        UNKNOWN = 0,
        DOTTED_YELLOW = 1,
        DOTTED_WHITE = 2,
        SOLID_YELLOW = 3,
        SOLID_WHITE = 4,
        DOUBLE_YELLOW = 5,
        CURB = 6,            // 路牙
        BLANK = 7,          // 无边界，如路与旁边的泥土混在一起且无印刷线
        VIRTUAL = 9        // 虚拟线，如虚拟出来的左转线
    }
}