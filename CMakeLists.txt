cmake_minimum_required(VERSION 3.12)

if("${CMAKE_INSTALL_PREFIX}" STREQUAL "")
  set(USE_DEFAULT_INSTALL_LOCATION True)
else()
  set(USE_DEFAULT_INSTALL_LOCATION False)
endif()

project(KDMacTouchBar CXX)

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "" FORCE)
endif()

set(${PROJECT_NAME}_VERSION_MAJOR 1)
set(${PROJECT_NAME}_VERSION_MINOR 1)
set(${PROJECT_NAME}_VERSION_PATCH 0)
set(${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH})

set(CMAKE_CXX_STANDARD 11)

if(USE_DEFAULT_INSTALL_LOCATION)
    set(CMAKE_INSTALL_PREFIX "/usr/local/KDAB/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}" CACHE STRING "" FORCE)
endif()

message(STATUS "Building ${PROJECT_NAME} ${${PROJECT_NAME}_VERSION} in ${CMAKE_BUILD_TYPE} mode. Installing to ${CMAKE_INSTALL_PREFIX}")

find_package(QT NAMES Qt6 Qt5)
if("${QT_VERSION_MAJOR}" STREQUAL "5")
  set(QT_REQUIRED_VERSION "5.15.2")
else()
  set(QT_REQUIRED_VERSION "6.4.0")
endif()

find_package(Qt${QT_VERSION_MAJOR} ${QT_REQUIRED_VERSION}
    COMPONENTS Core Widgets
    REQUIRED)

set(CMAKE_AUTOMOC TRUE)
set(QT_LIBRARIES Qt${QT_VERSION_MAJOR}::Widgets)
set(QT_USE_FILE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Qt${QT_VERSION_MAJOR}Portability.cmake")

install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/KDMacTouchBarConfig.cmake"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake")

add_subdirectory(src)
add_subdirectory(examples)
