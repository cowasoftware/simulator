import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "./ShortcutToolBar"

Control{
    id: control
    leftPadding: 10 * config_id.screenScale

    ButtonGroup{
        id: canvalToolGroup
    }

    contentItem: RowLayout{
        spacing: 10 * config_id.screenScale

        Loader {             
            id: project_page_toolbar_loader_id
            source:  config_id.simulatorType === "record" ? 
                "qrc:///resource/qml/simulation_page/ShortcutToolBar/PlaybackTool.qml" 
                : "qrc:///resource/qml/simulation_page/ShortcutToolBar/SimulateTool.qml" 
        }

        ToolSeparator{
            Layout.leftMargin: 24 * config_id.screenScale
            Layout.rightMargin: 24 * config_id.screenScale
        }

        CanvasTool{}

        ToolSeparator{
            Layout.leftMargin: 24 * config_id.screenScale
            Layout.rightMargin: 24 * config_id.screenScale
        }

        ScenarioTool{
            visible : config_id.simulatorType === "simulate" ? true : false
        }

        Item{
            Layout.fillWidth: true
        }
    }
}
