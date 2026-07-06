cmake_minimum_required(VERSION 3.21)

project(JozetBackend LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Network)

qt6_add_qml_module(JozetPlugin
    URI Jozet.System
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Jozet/System 
    SOURCES
        System/SystemManager.cpp
        System/SystemManager.h
)
target_include_directories(JozetPlugin PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/System
)
target_link_libraries(JozetPlugin PRIVATE Qt6::Core Qt6::Qml Qt6::Network)