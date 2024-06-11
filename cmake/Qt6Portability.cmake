
include_directories(${QtWidgets_INCLUDE_DIRS})

if(QT_USE_QTNETWORK)
  find_package(QtNetwork REQUIRED)
  list(APPEND QT_LIBRARIES Qt::Network)
  include_directories(${QtNetwork_INCLUDE_DIRS})
endif()

if(QT_USE_QTXML)
  find_package(QtXml REQUIRED)
  list(APPEND QT_LIBRARIES Qt::Xml)
  include_directories(${QtXml_INCLUDE_DIRS})
endif()

if(QT_USE_QTTEST)
  find_package(QtTest REQUIRED)
  list(APPEND QT_LIBRARIES Qt::Test)
  include_directories(${QtTest_INCLUDE_DIRS})
endif()

macro(qt4_wrap_ui)
  qt_wrap_ui(${ARGN})
endmacro()

macro(qt4_wrap_cpp)
  qt_wrap_cpp(${ARGN})
endmacro()

macro(qt4_add_resources)
  qt_add_resources(${ARGN})
endmacro()
