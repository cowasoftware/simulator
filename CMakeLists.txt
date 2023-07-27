cmake_minimum_required(VERSION 3.10)

set(CMAKE_BUILD_TYPE Release)
set(PROJECT_NAME sim_new_client)

project(${PROJECT_NAME} VERSION 1.0 LANGUAGES CXX)
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

# generate proto files
message("CMAKE_CURRENT_SOURCE_DIR : " ${CMAKE_CURRENT_SOURCE_DIR})
set(PROTO_DIR ${CMAKE_CURRENT_SOURCE_DIR}/sim-proto)
message("PROTO_DIR : " ${PROTO_DIR})
execute_process(COMMAND bash ${PROTO_DIR}/generate_by_conan.sh ${CONAN_PROTOBUF_ROOT} ${PROTO_DIR}
    TIMEOUT 3
    RESULT_VARIABLE result_var
    OUTPUT_VARIABLE output_var
    ERROR_VARIABLE error_var
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE)
message(STATUS "generate proto files result: ${result_var}")
message(STATUS "generate proto files output: ${output_var}")
message(STATUS "generate proto files have no error: ${error_var}")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

ADD_DEFINITIONS(-DQT_NO_KEYWORDS)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall -O0 -Wno-unused-variable -pthread")

include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})

# 增加版本信息
# 版本编译时间
string(TIMESTAMP COMPILE_TIME %Y/%m/%d)
set(BUILD_TIME  ${COMPILE_TIME})
add_definitions(-DSIM_CLIENT_BUILD_VERSION="${PROJECT_VERSION}")
add_definitions(-DSIM_CLIENT_BUILD_TIME="${BUILD_TIME}")

find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick)
message(STATUS "Qt Version: ${QT_VERSION_MAJOR}")

aux_source_directory("${PROJECT_SOURCE_DIR}" MAIN_SRC)
message("source files from ${PROJECT_SOURCE_DIR}:${MAIN_SRC}")
aux_source_directory(./model MODEL_SRC)
aux_source_directory(./model/qml MODEL_SRC)
aux_source_directory(./client CLIENT_SRC)
aux_source_directory(./control CONTROL_SRC)
aux_source_directory(./sim-proto CONTROL_SRC)
aux_source_directory(./common COMMON_SRC)
aux_source_directory(./vmodel VMODEL_SRC)

include_directories(
    .
    common
    control
    model
    model/qml
    client
    sim-proto
)
FILE (GLOB HEADERS "*.h" "common/*.h" "control/*.h" "model/*.h" "model/qml/*.h" "client/*.h" "sim-proto/*.h")

set(PROJECT_SOURCES
    main.cc
    qml.qrc
    ${HEADERS}
    ${MAIN_SRC}
    ${CONTROL_SRC}
    ${MODEL_SRC}
    ${CLIENT_SRC}
    ${COMMON_SRC}
    ${VMODEL_SRC}
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )

# Define target properties for Android with Qt 6 as:
# set_property(TARGET DEMO APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
# ${CMAKE_CURRENT_SOURCE_DIR}/android)
# For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation
else()
    if(ANDROID)
        add_library(${PROJECT_NAME} SHARED
            ${PROJECT_SOURCES}
        )

    # Define properties for Android with Qt 5 after find_package() calls as:
    # set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else()
        add_executable(${PROJECT_NAME}
            ${PROJECT_SOURCES}
        )
    endif()
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME}
    PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Quick)

set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE ${CMAKE_THREAD_LIBS_INIT}
    PRIVATE ${CONAN_LIBS}
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(${PROJECT_NAME})
    qt_finalize_executable(${PROJECT_NAME})
endif()
