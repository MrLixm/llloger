# Katana launcher script

cd ..

KATANA_VERSION="4.5v1"
KATANA_HOME="C:\Program Files\Katana$KATANA_VERSION"
KATANA_TAGLINE="llloger DEV"

export PATH="$PATH;$KATANA_HOME\bin"
export KATANA_CATALOG_RECT_UPDATE_BUFFER_SIZE=1
#export FNLOGGING_CONFIG=".\dev\KatanaResources\log.conf"

export KATANA_USER_RESOURCE_DIRECTORY=".\dev\_prefs"
#export KATANA_RESOURCES="$KATANA_RESOURCES;.\dev\KatanaResources"

export LUA_PATH="$LUA_PATH;.\?.lua"

"$KATANA_HOME\bin\katanaBin.exe"
