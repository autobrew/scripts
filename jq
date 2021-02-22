# Find a bundle
if [ $(arch | grep arm) ]; then
bottle="https://autobrew.github.io/archive/arm64_big_sur/jq-1.6-arm64_big_sur.tar.xz"
elif [[ ${OSTYPE:6} -ge 20 ]]; then
bottle="https://autobrew.github.io/archive/big_sur/jq-1.6-big_sur.tar.xz"
elif [[ ${OSTYPE:6} -ge 17 ]]; then
bottle="https://autobrew.github.io/archive/high_sierra/jq-1.6-high_sierra.tar.xz"
else
bottle="https://autobrew.github.io/archive/el_capitan/jq-1.6-el_capitan.tar.xz"
fi

# Skip if disabled
if [ "$DISABLE_AUTOBREW" ]; then return 0; fi

# General setup
BREWDIR="$PWD/.deps"
mkdir -p $BREWDIR
curl -sSL $bottle -o libs.tar.xz
tar -xf libs.tar.xz --strip 1 -C $BREWDIR
rm -f libs.tar.xz

# package may look under /opt
mkdir -p $BREWDIR/opt/jq
ln -s $BREWDIR/{include,lib} $BREWDIR/opt/jq/

# Hardcoded flags
PKG_CFLAGS="-I$BREWDIR/include"
PKG_LIBS="-L$BREWDIR/lib -ljq -lonig"

# Cleanup
echo "rm -Rf .deps" >> cleanup
chmod +x cleanup
