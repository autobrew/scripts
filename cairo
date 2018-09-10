export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

if [ "$DISABLE_AUTOBREW" ]; then return 0; fi
AUTOBREW=${TMPDIR-/tmp}
export HOMEBREW_TEMP="$AUTOBREW/hbtmp"
BREWDIR="$AUTOBREW/build-$PKG_BREW_NAME"
BREW="$BREWDIR/bin/brew"
rm -Rf $BREWDIR
mkdir -p $BREWDIR
echo "Auto-brewing $PKG_BREW_NAME in $BREWDIR..."
curl -fsSL https://github.com/Homebrew/brew/tarball/1.7.1 | tar xz --strip 1 -C $BREWDIR
export HOMEBREW_NO_ANALYTICS=1
$BREW update
BREW_DEPS=$($BREW deps -n $PKG_BREW_NAME)
HOMEBREW_CACHE="$AUTOBREW" $BREW install pkg-config 2>&1 | perl -pe 's/Warning/Note/gi'
HOMEBREW_CACHE="$AUTOBREW" $BREW install --force-bottle $BREW_DEPS $PKG_BREW_NAME 2>&1 | perl -pe 's/Warning/Note/gi'

# Fontconfig needs to be rebuid for Mavericks
if [ $(sw_vers -productVersion | grep -F "10.9") ]; then
  HOMEBREW_CACHE="$AUTOBREW" $BREW reinstall fontconfig | perl -pe 's/Warning/Note/gi'
fi

$BREW link --force libffi gettext
PKG_CFLAGS=$($BREWDIR/opt/pkg-config/bin/pkg-config --cflags ${PKG_CONFIG_NAME})
PKG_LIBS=$($BREWDIR/opt/pkg-config/bin/pkg-config --libs-only-l --static ${PKG_CONFIG_NAME})
rm -f $BREWDIR/opt/*/lib/*.dylib
rm -f $BREWDIR/Cellar/*/*/lib/*.dylib

# Prevent CRAN builder from linking against old libs in /usr/local/lib
for FILE in $BREWDIR/lib/*.a; do
  BASENAME=$(basename $FILE)
  LIBNAME=$(echo "${BASENAME%.*}" | cut -c4-)
  cp -f $FILE $BREWDIR/lib/libbrew$LIBNAME.a
  echo "created $BREWDIR/lib/libbrew$LIBNAME.a"
  PKG_LIBS=$(echo $PKG_LIBS | sed "s/-l$LIBNAME /-lbrew$LIBNAME /g")
done
rm -f $BREWDIR/lib/*.dylib
PKG_LIBS="-L$BREWDIR/lib $PKG_LIBS"
