TARGET = ru.omstu.goloslov

CONFIG += \
    auroraapp \
    c++11

QT += multimedia qml quick

PKGCONFIG += \

SOURCES += \
    src/main.cpp \
    src/speechrecognizer.cpp \
    src/voskworker.cpp \

HEADERS += \
    src/speechrecognizer.h \
    src/voskworker.h \
INCLUDEPATH += $$PWD/vosk
LIBS += -L$$PWD/vosk/lib -lvosk
QMAKE_RPATHDIR += /usr/share/$${TARGET}/lib

# Ship libvosk.so with the package.
vosklib.files = vosk/lib/libvosk.so
vosklib.path = /usr/share/$${TARGET}/lib
INSTALLS += vosklib

exists($$PWD/vosk/lib/libatomic.so.1) {
    voskatomic.files = vosk/lib/libatomic.so.1
    voskatomic.path = /usr/share/$${TARGET}/lib
    INSTALLS += voskatomic
    QMAKE_LFLAGS += -L$$PWD/vosk/lib -Wl,--no-as-needed,-l:libatomic.so.1 -Wl,--as-needed
}

voskmodel.files = models/vosk-model-small-ru-0.22
voskmodel.path = /usr/share/$${TARGET}/models
INSTALLS += voskmodel

DISTFILES += \
    rpm/ru.omstu.voicenotes.spec \
    qml/voicenotes.qml \
    qml/Database.js \
    qml/cover/DefaultCoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/RecordingPage.qml \
    qml/pages/NoteViewPage.qml \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.omstu.goloslov.ts \
    translations/ru.omstu.goloslov-ru.ts \
