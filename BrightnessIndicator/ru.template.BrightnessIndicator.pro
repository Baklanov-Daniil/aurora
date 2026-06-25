TARGET = ru.template.BrightnessIndicator

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
    src/imageprocessor.cpp \
    src/main.cpp \
    src/processingworker.cpp \
    src/resultimageprovider.cpp

HEADERS += \
    src/imageprocessor.h \
    src/processingworker.h \
    src/resultimageprovider.h

DISTFILES += \
    rpm/ru.template.BrightnessIndicator.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.BrightnessIndicator.ts \
    translations/ru.template.BrightnessIndicator-ru.ts \

RESOURCES += \
    translations/qml.qrc \
    translations/translations.qrc
