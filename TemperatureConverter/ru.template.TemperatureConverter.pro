TARGET = ru.template.TemperatureConverter

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
    src/main.cpp \

HEADERS += \

DISTFILES += \
    rpm/ru.template.TemperatureConverter.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.TemperatureConverter.ts \
    translations/ru.template.TemperatureConverter-ru.ts \
