export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# Offical Homebrew no longer supports El-Capitain
UPSTREAM_ORG="autobrew"

if [ "$DISABLE_AUTOBREW" ]; then return 0; fi
AUTOBREW=${TMPDIR-/tmp}
export HOMEBREW_TEMP="$AUTOBREW/hbtmp"
BREWDIR="$AUTOBREW/build-$PKG_BREW_NAME"
BREW="$BREWDIR/bin/brew"
rm -Rf $BREWDIR
mkdir -p $BREWDIR
echo "$(date): Auto-brewing $PKG_BREW_NAME in $BREWDIR..."
curl -fsSL https://github.com/$UPSTREAM_ORG/brew/tarball/master | tar xz --strip 1 -C $BREWDIR

# Do not build pkg-config from source, so need to override hardcoded paths
export HOMEBREW_CACHE="$AUTOBREW"
$BREW install --force-bottle pkg-config 2>&1 | perl -pe 's/Warning/Note/gi'
PKG_CONFIG="$BREWDIR/opt/pkg-config/bin/pkg-config"
PC_PATH=$($PKG_CONFIG --variable pc_path pkg-config)
PC_PATH=$(echo $PC_PATH | perl -pe "s#/usr/local/Homebrew#${BREWDIR}#gi") #HOMEBREW_LIBRARY
PC_PATH=$(echo $PC_PATH | perl -pe "s#/usr/local#${BREWDIR}#gi") #HOMEBREW_PREFIX
echo "PC_PATH=$PC_PATH"

$BREW deps -n $PKG_BREW_NAME
BREW_DEPS=$($BREW deps -n $PKG_BREW_NAME)
$BREW install --force-bottle $BREW_DEPS $PKG_BREW_NAME 2>&1 | perl -pe 's/Warning/Note/gi'

export PKG_CONFIG_PATH=$PC_PATH
export PKG_CONFIG_LIBDIR=$PC_PATH
PKG_CFLAGS=$($PKG_CONFIG --cflags ${PKG_CONFIG_NAME})
PKG_LIBS=$($PKG_CONFIG --libs-only-l --static ${PKG_CONFIG_NAME})
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
