QT += quick

SOURCES += main.cpp
RESOURCES += mactouchbar.qrc

INCLUDEPATH = ../../src ../../src/quick
LIBS += -F../../lib -framework KDMacTouchBarQuick
QMAKE_LFLAGS = '-Wl,-rpath,\'$$OUT_PWD/../../lib\',-rpath,\'$$INSTALL_PREFIX/lib\''

target.path = "$${INSTALL_PREFIX}/examples/mactouchbar_quick"
INSTALLS += target
