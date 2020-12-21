# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-paketti

CONFIG += sailfishapp

SOURCES += src/harbour-paketti.cpp \
    src/dhlapi.cpp \
    src/laposteapi.cpp

DISTFILES += qml/harbour-paketti.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    qml/pages/plug_dhl.js \
    rpm/harbour-paketti.changes.in \
    rpm/harbour-paketti.changes.run.in \
    rpm/harbour-paketti.spec \
    rpm/harbour-paketti.yaml \
    translations/*.ts \
    harbour-paketti.desktop \
    rpm/harbour-paketti.changes

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-paketti-fi.ts \
    translations/harbour-paketti-sv.ts \
    translations/harbour-paketti-fr.ts \
    translations/harbour-paketti-de.ts \
    translations/harbour-paketti-pl.ts \
    translations/harbour-paketti-nb_NO.ts \

HEADERS += \
    src/dhlapi.h \
    src/laposteapi.h
