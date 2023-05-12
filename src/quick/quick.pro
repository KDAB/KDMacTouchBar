TEMPLATE = lib
TARGET = KDMacTouchBarQuick
QT += quick

include($${TOP_SOURCE_DIR}/kdmactouchbar.pri)

INCLUDEPATH += $${TOP_SOURCE_DIR}/src

CONFIG += lib_bundle

DESTDIR = $${TOP_SOURCE_DIR}/lib

SOURCES = kdmactouchbarquick.mm

HEADERS = kdmactouchbarquick.h ../kdmactouchbar_global.h
    
RESOURCES += qml.qrc

LIBS += -framework Cocoa
QMAKE_LFLAGS_SONAME = -Wl,-install_name,@rpath/

DEFINES += KDMACTOUCHBAR_BUILD_KDMACTOUCHBAR_LIB QT_NO_CAST_TO_ASCII QT_ASCII_CAST_WARNING

target.path = "$${INSTALL_PREFIX}/lib"

INSTALLS += target

FRAMEWORK_HEADERS.version = Versions
FRAMEWORK_HEADERS.files = $$HEADERS
FRAMEWORK_HEADERS.path = Headers
QMAKE_BUNDLE_DATA += FRAMEWORK_HEADERS
QMAKE_TARGET_BUNDLE_PREFIX = "com.kdab"
