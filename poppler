BREWDIR="$TMPDIR/homebrew"
BREW="$BREWDIR/bin/brew"
rm -Rf $BREWDIR
mkdir -p $BREWDIR
echo "Auto-brewing $PKG_BREW_NAME in $BREWDIR..."

# Revert to Sept 16, 2016, last day of homebrew support for OSX 10.9 Mavericks
if [ $(sw_vers -productVersion | grep -F "10.9") ]; then
  curl -fsSL https://github.com/legacybrew/brew/tarball/master | tar xz --strip 1 -C $BREWDIR
  mkdir -p $BREWDIR/Library/Taps/homebrew
  (cd $BREWDIR/Library/Taps/homebrew; git clone --depth=1 https://github.com/legacybrew/homebrew-core)
else
  curl -fsSL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $BREWDIR
fi

HOMEBREW_CACHE="/tmp" $BREW install pkg-config 2>&1 | perl -pe 's/Warning/Note/gi'
HOMEBREW_CACHE="/tmp" $BREW install --force-bottle openssl freetype fontconfig gettext glib \
  cairo python gobject-introspection ${PKG_BREW_NAME}  2>&1 | perl -pe 's/Warning/Note/gi'
HOMEBREW_CACHE="/tmp" $BREW reinstall openjpeg --with-static  2>&1 | perl -pe 's/Warning/Note/gi'
PKG_CFLAGS=`$BREWDIR/opt/pkg-config/bin/pkg-config --cflags ${PKG_CONFIG_NAME}`
PKG_LIBS=`$BREWDIR/opt/pkg-config/bin/pkg-config --libs --static ${PKG_CONFIG_NAME} cairo lcms2 libopenjp2 libtiff-4`
PKG_LIBS="-L${BREWDIR}/lib ${PKG_LIBS}"

# Prevent CRAN builder from linking against old libs in /usr/local/lib
for FILE in $BREWDIR/Cellar/*/*/lib/*.a; do
  BASENAME=`basename $FILE`
  LIBNAME=`echo "${BASENAME%.*}" | cut -c4-`
  cp -f $FILE $BREWDIR/lib/libbrew$LIBNAME.a
  echo "created $BREWDIR/lib/libbrew$LIBNAME.a"
  PKG_LIBS=`echo $PKG_LIBS | sed "s/-l$LIBNAME /-lbrew$LIBNAME /g"`
done
rm -f $BREWDIR/lib/*.dylib
rm -f $BREWDIR/Cellar/*/*/lib/*.dylib
