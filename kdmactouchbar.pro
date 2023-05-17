TEMPLATE = subdirs

include(kdmactouchbar.pri)

DEFAULT_INSTALL_PREFIX = /usr/local/KDAB/KDMacTouchBar-$$VERSION

isEmpty( KDMACTOUCHBAR_INSTALL_PREFIX ): KDMACTOUCHBAR_INSTALL_PREFIX=$$PREFIX

isEmpty( KDMACTOUCHBAR_INSTALL_PREFIX ): KDMACTOUCHBAR_INSTALL_PREFIX=$$DEFAULT_INSTALL_PREFIX

# if the default was either set by configure or set by the line above:
equals( KDMACTOUCHBAR_INSTALL_PREFIX, $$DEFAULT_INSTALL_PREFIX ){
    INSTALL_PREFIX=$$DEFAULT_INSTALL_PREFIX
    message( "No install prefix given, using default of" $$DEFAULT_INSTALL_PREFIX)
} else {
    INSTALL_PREFIX=$$KDMACTOUCHBAR_INSTALL_PREFIX
}

# This file is in the build directory (because "somecommand >> somefile" puts it there)
QMAKE_CACHE = "$${OUT_PWD}/.qmake.cache"

MESSAGE = '\\'$$LITERAL_HASH\\' KDAB qmake cache file: following lines autogenerated during qmake run'
system('echo $${MESSAGE} > $${QMAKE_CACHE}')

TMP_SOURCE_DIR = $${PWD}
TMP_BUILD_DIR = $${OUT_PWD}
system('echo TOP_SOURCE_DIR=$${TMP_SOURCE_DIR} >> $${QMAKE_CACHE}')
system('echo TOP_BUILD_DIR=$${TMP_BUILD_DIR} >> $${QMAKE_CACHE}')
system('echo INSTALL_PREFIX=$$INSTALL_PREFIX >> $${QMAKE_CACHE}')

SUBDIRS += src examples features

examples.depends = src
