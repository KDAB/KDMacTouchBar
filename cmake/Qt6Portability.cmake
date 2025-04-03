if(QT_USE_QTNETWORK)
  find_package(QtNetwork REQUIRED)
  list(APPEND QT_LIBRARIES Qt::Network)
endif()

if(QT_USE_QTXML)
  find_package(QtXml REQUIRED)
  list(APPEND QT_LIBRARIES Qt::Xml)
endif()

if(QT_USE_QTTEST)
  find_package(QtTest REQUIRED)
  list(APPEND QT_LIBRARIES Qt::Test)
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
