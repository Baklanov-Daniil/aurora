TARGET = ru.omstu.goloslov
CONFIG += auroraapp
PKGCONFIG += auroraapp

SOURCES += \
    src/audiorecorder.cpp \
    src/main.cpp \

HEADERS += \
    src/audiorecorder.h

DISTFILES += \
    qml/pages/RecordPage.qml \
    rpm/ru.omstu.goloslov.spec

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

PKGCONFIG += Qt5Multimedia
