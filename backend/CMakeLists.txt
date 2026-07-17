cmake_minimum_required(VERSION 3.21)
project(JozetBackend LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -march=native -mtune=native -flto -ffast-math")

find_package(Qt6 REQUIRED COMPONENTS Core Qml Network DBus)

qt6_add_qml_module(JozetPlugin
    URI Jozet.System
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Jozet/System 
    SOURCES
        System/SystemManager.cpp
        System/SystemManager.h
        System/Readers/CpuReader.cpp
        System/Readers/CpuReader.h
        System/Readers/RamReader.cpp
        System/Readers/RamReader.h
        System/Readers/DiskReader.cpp
        System/Readers/DiskReader.h
        System/Readers/TempReader.cpp
        System/Readers/TempReader.h
        System/Readers/NetworkReader.cpp
        System/Readers/NetworkReader.h
        System/Readers/BluetoothReader.cpp
        System/Readers/BluetoothReader.h
        System/Readers/VolumeReader.cpp
        System/Readers/VolumeReader.h
        System/Readers/ProcessReader.cpp
        System/Readers/ProcessReader.h
        System/Readers/AgendaReader.cpp
        System/Readers/AgendaReader.h
        System/Readers/EventsReader.cpp
        System/Readers/EventsReader.h
        System/Readers/StatsReader.cpp
        System/Readers/StatsReader.h
        System/Readers/HyprlandReader.cpp
        System/Readers/HyprlandReader.h
)
target_include_directories(JozetPlugin PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/System
)
target_link_libraries(JozetPlugin PRIVATE Qt6::Core Qt6::Qml Qt6::Network Qt6::DBus)

set_target_properties(JozetPlugin PROPERTIES INTERPROCEDURAL_OPTIMIZATION TRUE)